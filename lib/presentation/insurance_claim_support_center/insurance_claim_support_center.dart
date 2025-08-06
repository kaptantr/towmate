
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import './widgets/claim_timeline_widget.dart';
import './widgets/claim_wizard_widget.dart';
import './widgets/damage_assessment_widget.dart';
import './widgets/document_manager_widget.dart';
import './widgets/incident_report_form_widget.dart';
import './widgets/insurance_company_selector_widget.dart';
import './widgets/photo_documentation_widget.dart';

class InsuranceClaimSupportCenter extends StatefulWidget {
  const InsuranceClaimSupportCenter({Key? key}) : super(key: key);

  @override
  State<InsuranceClaimSupportCenter> createState() => _InsuranceClaimSupportCenterState();
}

class _InsuranceClaimSupportCenterState extends State<InsuranceClaimSupportCenter> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _wizardController;
  final SpeechToText _speechToText = SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();
  
  int _currentWizardStep = 0;
  bool _isListening = false;
  List<XFile> _capturedImages = [];
  List<PlatformFile> _uploadedDocuments = [];
  Map<String, dynamic> _claimData = {};
  String _selectedInsuranceCompany = '';
  
  final List<String> _wizardSteps = [
    'Incident Details',
    'Photo Documentation', 
    'Insurance Information',
    'Damage Assessment',
    'Submit Claim'
  ];

  final List<Map<String, dynamic>> _insuranceCompanies = [
{ 'name': 'Allianz Sigorta',
'logo': 'https://images.unsplash.com/photo-1560472354-b7c632a7af0b?w=100',
'claimPhone': '+90 850 222 78 78',
'onlinePortal': 'https://allianz.com.tr',
'supportedLanguages': ['tr', 'en'],
},
{ 'name': 'Axa Sigorta',
'logo': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=100',
'claimPhone': '+90 444 1 999',
'onlinePortal': 'https://axa.com.tr',
'supportedLanguages': ['tr', 'en', 'fr'],
},
{ 'name': 'Mapfre Sigorta',
'logo': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=100',
'claimPhone': '+90 444 62 73',
'onlinePortal': 'https://mapfre.com.tr',
'supportedLanguages': ['tr', 'en', 'es'],
},
];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _wizardController = PageController();
    _requestPermissions();
    _loadExistingClaims();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  void _loadExistingClaims() {
    // Mock existing claims data
    setState(() {
      _claimData = {
        'existingClaims': [
          {
            'id': 'CLM-2024-001',
            'status': 'Under Review',
            'submittedDate': DateTime.now().subtract(Duration(days: 3)),
            'estimatedAmount': '₺12,500',
            'insuranceCompany': 'Allianz Sigorta',
            'vehicleInfo': '2020 Toyota Corolla - 34 ABC 123',
            'incidentType': 'Collision',
            'progress': 0.6,
            'timeline': [
              {'step': 'Claim Submitted', 'date': DateTime.now().subtract(Duration(days: 3)), 'completed': true},
              {'step': 'Documents Reviewed', 'date': DateTime.now().subtract(Duration(days: 2)), 'completed': true},
              {'step': 'Damage Assessment', 'date': DateTime.now().subtract(Duration(days: 1)), 'completed': true},
              {'step': 'Insurance Approval', 'date': DateTime.now().add(Duration(days: 1)), 'completed': false},
              {'step': 'Payment Processing', 'date': DateTime.now().add(Duration(days: 3)), 'completed': false},
            ],
          },
          {
            'id': 'CLM-2024-002',
            'status': 'Approved',
            'submittedDate': DateTime.now().subtract(Duration(days: 10)),
            'estimatedAmount': '₺8,750',
            'insuranceCompany': 'Axa Sigorta',
            'vehicleInfo': '2019 Honda Civic - 06 DEF 456',
            'incidentType': 'Weather Damage',
            'progress': 1.0,
            'timeline': [
              {'step': 'Claim Submitted', 'date': DateTime.now().subtract(Duration(days: 10)), 'completed': true},
              {'step': 'Documents Reviewed', 'date': DateTime.now().subtract(Duration(days: 8)), 'completed': true},
              {'step': 'Damage Assessment', 'date': DateTime.now().subtract(Duration(days: 6)), 'completed': true},
              {'step': 'Insurance Approval', 'date': DateTime.now().subtract(Duration(days: 3)), 'completed': true},
              {'step': 'Payment Processing', 'date': DateTime.now().subtract(Duration(days: 1)), 'completed': true},
            ],
          },
        ],
      };
    });
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          // Handle voice input for incident description
        });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _capturePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080);
    
    if (image != null) {
      setState(() {
        _capturedImages.add(image);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080);
    
    setState(() {
      _capturedImages.addAll(images);
    });
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      allowMultiple: true);

    if (result != null) {
      setState(() {
        _uploadedDocuments.addAll(result.files);
      });
    }
  }

  void _nextWizardStep() {
    if (_currentWizardStep < _wizardSteps.length - 1) {
      setState(() {
        _currentWizardStep++;
      });
      _wizardController.animateToPage(
        _currentWizardStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  void _previousWizardStep() {
    if (_currentWizardStep > 0) {
      setState(() {
        _currentWizardStep--;
      });
      _wizardController.animateToPage(
        _currentWizardStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  void _submitClaim() {
    // Handle claim submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Claim Submitted Successfully',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your claim has been submitted with the following details:',
              style: GoogleFonts.inter(fontSize: 14.sp)),
            SizedBox(height: 12.h),
            Text(
              'Claim ID: CLM-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500)),
            Text(
              'Insurance Company: $_selectedInsuranceCompany',
              style: GoogleFonts.inter(fontSize: 14.sp)),
            Text(
              'Photos: ${_capturedImages.length} uploaded',
              style: GoogleFonts.inter(fontSize: 14.sp)),
            Text(
              'Documents: ${_uploadedDocuments.length} uploaded',
              style: GoogleFonts.inter(fontSize: 14.sp)),
          ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentWizardStep = 0;
                _capturedImages.clear();
                _uploadedDocuments.clear();
                _selectedInsuranceCompany = '';
              });
              _wizardController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            child: Text('Start New Claim')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1); // Go to tracking tab
            },
            child: Text('Track Claim')),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Insurance Claim Center',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Claim'),
            Tab(icon: Icon(Icons.track_changes), text: 'Track Claims'),
            Tab(icon: Icon(Icons.folder_open), text: 'Documents'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white)),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewClaimTab(),
          _buildTrackClaimsTab(),
          _buildDocumentsTab(),
        ]));
  }

  Widget _buildNewClaimTab() {
    return Column(
      children: [
        ClaimWizardWidget(
          currentStep: _currentWizardStep,
          steps: _wizardSteps,
          onStepTapped: (step) {
            setState(() {
              _currentWizardStep = step;
            });
            _wizardController.animateToPage(
              step,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut);
          }),
        Expanded(
          child: PageView(
            controller: _wizardController,
            onPageChanged: (page) {
              setState(() {
                _currentWizardStep = page;
              });
            },
            children: [
              IncidentReportFormWidget(
                isListening: _isListening,
                onStartListening: _startListening,
                onStopListening: _stopListening,
                onDataChanged: (data) {
                  _claimData.addAll(data);
                }),
              PhotoDocumentationWidget(
                capturedImages: _capturedImages,
                onCapturePhoto: _capturePhoto,
                onPickFromGallery: _pickFromGallery,
                onRemoveImage: (index) {
                  setState(() {
                    _capturedImages.removeAt(index);
                  });
                }),
              InsuranceCompanySelectorWidget(
                companies: _insuranceCompanies,
                selectedCompany: _selectedInsuranceCompany,
                onCompanySelected: (company) {
                  setState(() {
                    _selectedInsuranceCompany = company;
                  });
                }),
              DamageAssessmentWidget(
                images: _capturedImages,
                onAssessmentComplete: (assessment) {
                  _claimData['damageAssessment'] = assessment;
                }),
              _buildSubmitClaimStep(),
            ])),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: Offset(0, -2)),
            ]),
          child: Row(
            children: [
              if (_currentWizardStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousWizardStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green[700]!),
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.symmetric(vertical: 12.h)),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700])))),
              if (_currentWizardStep > 0) SizedBox(width: 12.w),
              Expanded(
                flex: _currentWizardStep == 0 ? 1 : 1,
                child: ElevatedButton(
                  onPressed: _currentWizardStep == _wizardSteps.length - 1 
                      ? _submitClaim 
                      : _nextWizardStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(),
                    padding: EdgeInsets.symmetric(vertical: 12.h)),
                  child: Text(
                    _currentWizardStep == _wizardSteps.length - 1 
                        ? 'Submit Claim' 
                        : 'Next',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)))),
            ])),
      ]);
  }

  Widget _buildTrackClaimsTab() {
    final existingClaims = _claimData['existingClaims'] as List<Map<String, dynamic>>? ?? [];
    
    if (existingClaims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No claims found',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey[600])),
            SizedBox(height: 8.h),
            Text(
              'Submit your first claim to start tracking',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[500])),
          ]));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: existingClaims.length,
      itemBuilder: (context, index) {
        final claim = existingClaims[index];
        return ClaimTimelineWidget(
          claim: claim,
          onTap: () {
            // Navigate to detailed claim view
          });
      });
  }

  Widget _buildDocumentsTab() {
    return DocumentManagerWidget(
      uploadedDocuments: _uploadedDocuments,
      onUploadDocument: _uploadDocument,
      onRemoveDocument: (index) {
        setState(() {
          _uploadedDocuments.removeAt(index);
        });
      },
      onShareDocument: (document) async {
        if (document.path != null) {
          await Share.shareXFiles([XFile(document.path!)]);
        }
      });
  }

  Widget _buildSubmitClaimStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900])),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: Offset(0, 2)),
              ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Claim Summary',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900])),
                SizedBox(height: 12.h),
                _buildSummaryItem('Insurance Company', _selectedInsuranceCompany),
                _buildSummaryItem('Photos Captured', '${_capturedImages.length} images'),
                _buildSummaryItem('Documents Uploaded', '${_uploadedDocuments.length} files'),
                _buildSummaryItem('Incident Type', _claimData['incidentType'] ?? 'Not specified'),
                _buildSummaryItem('Location', _claimData['location'] ?? 'Not specified'),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    
                    border: Border.all(color: Colors.green[200]!)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'All required information has been provided. Your claim is ready for submission.',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.green[700]))),
                    ])),
              ])),
        ]));
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[600]))),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[900]))),
        ]));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wizardController.dispose();
    _speechToText.stop();
    super.dispose();
  }
}