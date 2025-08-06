import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/driver_registration_service.dart';
import './widgets/document_upload_card.dart';
import './widgets/personal_info_form.dart';
import './widgets/vehicle_info_form.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form data
  final Map<String, dynamic> _personalInfo = {};
  final Map<String, dynamic> _vehicleInfo = {};
  final Map<String, Map<String, dynamic>> _documents = {};

  String? _driverProfileId;
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkExistingRegistration();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingRegistration() async {
    try {
      final service = DriverRegistrationService.instance;
      final userId = service.getCurrentUserId();

      if (userId != null) {
        final existingProfile = await service.getDriverProfileByUserId(userId);
        if (existingProfile != null) {
          setState(() {
            _driverProfileId = existingProfile['id'];
            _isSubmitted = true;
          });
          _loadExistingData();
        }
      }
    } catch (error) {
      debugPrint('Check existing registration error: $error');
    }
  }

  Future<void> _loadExistingData() async {
    if (_driverProfileId == null) return;

    try {
      final service = DriverRegistrationService.instance;

      // Load documents
      final documents = await service.getDriverDocuments(_driverProfileId!);
      final documentsMap = <String, Map<String, dynamic>>{};

      for (final doc in documents) {
        documentsMap[doc['document_type']] = doc;
      }

      setState(() {
        _documents.addAll(documentsMap);
      });
    } catch (error) {
      debugPrint('Load existing data error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: Text('Driver Registration',
                style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            backgroundColor: Colors.orange[600],
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.inter(
                    fontSize: 12.sp, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Personal Info'),
                  Tab(text: 'Vehicle Info'),
                  Tab(text: 'Documents'),
                ])),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                // Progress Indicator
                _buildProgressIndicator(),

                // Tab Content
                Expanded(
                    child: TabBarView(controller: _tabController, children: [
                  PersonalInfoForm(
                      initialData: _personalInfo,
                      onDataChanged: (data) {
                        setState(() => _personalInfo.addAll(data));
                      },
                      onNext: () => _tabController.animateTo(1)),
                  VehicleInfoForm(
                      initialData: _vehicleInfo,
                      onDataChanged: (data) {
                        setState(() => _vehicleInfo.addAll(data));
                      },
                      onNext: _registerDriver,
                      onPrevious: () => _tabController.animateTo(0)),
                  _buildDocumentsTab(),
                ])),
              ]));
  }

  Widget _buildProgressIndicator() {
    return Container(
        padding: EdgeInsets.all(4.w),
        color: Colors.white,
        child: Column(children: [
          Row(children: [
            _buildProgressStep(0, 'Personal', _tabController.index >= 0),
            Expanded(
                child: Container(
                    height: 2,
                    color: _tabController.index >= 1
                        ? Colors.orange[600]
                        : Colors.grey[300])),
            _buildProgressStep(1, 'Vehicle', _tabController.index >= 1),
            Expanded(
                child: Container(
                    height: 2,
                    color: _tabController.index >= 2
                        ? Colors.orange[600]
                        : Colors.grey[300])),
            _buildProgressStep(2, 'Documents', _tabController.index >= 2),
          ]),
          SizedBox(height: 2.h),
          Text(_getProgressText(),
              style:
                  GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(children: [
      Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
              color: isActive ? Colors.orange[600] : Colors.grey[300],
              shape: BoxShape.circle),
          child: Center(
              child: Text('${step + 1}',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey[600])))),
      SizedBox(height: 1.h),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.orange[600] : Colors.grey[600])),
    ]);
  }

  Widget _buildDocumentsTab() {
    if (_driverProfileId == null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.description, size: 15.w, color: Colors.orange[600]),
        SizedBox(height: 2.h),
        Text('Complete personal and vehicle information first',
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center),
      ]));
    }

    final requirements =
        DriverRegistrationService.instance.getDocumentRequirements();

    return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Required Documents',
              style: GoogleFonts.inter(
                  fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 1.h),
          Text('Upload all required documents for verification',
              style:
                  GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 3.h),

          // Document Upload Cards
          ...requirements.entries.map((entry) {
            final documentType = entry.key;
            final requirement = entry.value;
            final uploadedDoc = _documents[documentType];

            return DocumentUploadCard(
                documentType: documentType,
                requirement: requirement,
                uploadedDocument: uploadedDoc,
                onUpload: () => _uploadDocument(documentType, requirement),
                onDelete: uploadedDoc != null
                    ? () => _deleteDocument(uploadedDoc['id'])
                    : null);
          }).toList(),

          SizedBox(height: 4.h),

          // Submit Button
          if (_driverProfileId != null)
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _canSubmitForVerification()
                        ? _submitForVerification
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Submit for Verification',
                        style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)))),
        ]));
  }

  String _getProgressText() {
    switch (_tabController.index) {
      case 0:
        return 'Enter your personal information and driver license details';
      case 1:
        return 'Provide your vehicle information and insurance details';
      case 2:
        return 'Upload required documents for verification';
      default:
        return '';
    }
  }

  Future<void> _registerDriver() async {
    if (_personalInfo.isEmpty || _vehicleInfo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete all required information')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = DriverRegistrationService.instance;
      final driverProfile = await service.registerDriver(
          driverData: _personalInfo, vehicleData: _vehicleInfo);

      setState(() {
        _driverProfileId = driverProfile['id'];
        _isSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver profile created successfully')));

      // Move to documents tab
      _tabController.animateTo(2);
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration failed: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument(
      String documentType, Map<String, dynamic> requirement) async {
    try {
      final service = DriverRegistrationService.instance;

      final document = await service.pickAndUploadDocument(
          driverId: _driverProfileId!, documentType: documentType);

      if (document != null) {
        setState(() {
          _documents[documentType] = document;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete Document'),
                content: const Text(
                    'Are you sure you want to delete this document?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.white))),
                ]));

    if (confirmed == true) {
      try {
        await DriverRegistrationService.instance
            .deleteDriverDocument(documentId);

        // Remove from local state
        final documentTypeToRemove = _documents.entries
            .firstWhere((entry) => entry.value['id'] == documentId)
            .key;

        setState(() {
          _documents.remove(documentTypeToRemove);
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted successfully')));
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $error')));
      }
    }
  }

  bool _canSubmitForVerification() {
    final requirements =
        DriverRegistrationService.instance.getDocumentRequirements();
    final requiredTypes = requirements.entries
        .where((entry) => entry.value['required'] == true)
        .map((entry) => entry.key);

    return requiredTypes.every((type) => _documents.containsKey(type));
  }

  Future<void> _submitForVerification() async {
    try {
      await DriverRegistrationService.instance
          .submitForVerification(_driverProfileId!);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Application submitted for verification')));

      // Navigate to driver dashboard
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.driverDashboard, (route) => false);
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Submission failed: $error')));
    }
  }
}