import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';

class DamageAssessmentWidget extends StatefulWidget {
  final List<XFile> images;
  final Function(Map<String, dynamic>) onAssessmentComplete;

  const DamageAssessmentWidget({
    Key? key,
    required this.images,
    required this.onAssessmentComplete,
  }) : super(key: key);

  @override
  State<DamageAssessmentWidget> createState() => _DamageAssessmentWidgetState();
}

class _DamageAssessmentWidgetState extends State<DamageAssessmentWidget> {
  String _damageSeverity = 'moderate';
  List<String> _damageAreas = [];
  double _estimatedCost = 0.0;
  String _repairTimeframe = '';
  bool _isAnalyzing = false;

  final List<Map<String, String>> _severityLevels = [
    {
      'value': 'minor',
      'label': 'Minor',
      'description': 'Cosmetic damage, easily repairable'
    },
    {
      'value': 'moderate',
      'label': 'Moderate',
      'description': 'Significant damage requiring professional repair'
    },
    {
      'value': 'severe',
      'label': 'Severe',
      'description': 'Major structural damage, may be total loss'
    },
  ];

  final List<Map<String, String>> _damageAreaOptions = [
    {'value': 'front_bumper', 'label': 'Front Bumper'},
    {'value': 'rear_bumper', 'label': 'Rear Bumper'},
    {'value': 'driver_door', 'label': 'Driver Door'},
    {'value': 'passenger_door', 'label': 'Passenger Door'},
    {'value': 'hood', 'label': 'Hood'},
    {'value': 'trunk', 'label': 'Trunk'},
    {'value': 'windshield', 'label': 'Windshield'},
    {'value': 'headlights', 'label': 'Headlights'},
    {'value': 'taillights', 'label': 'Taillights'},
    {'value': 'wheels_tires', 'label': 'Wheels/Tires'},
    {'value': 'side_panels', 'label': 'Side Panels'},
    {'value': 'roof', 'label': 'Roof'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.images.isNotEmpty) {
      _performAIAnalysis();
    }
  }

  void _performAIAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
        // Mock AI results
        _damageSeverity = 'moderate';
        _damageAreas = ['front_bumper', 'headlights', 'hood'];
        _estimatedCost = 8500.0;
        _repairTimeframe = '5-7 business days';
      });
      _updateAssessment();
    });
  }

  void _updateAssessment() {
    widget.onAssessmentComplete({
      'severity': _damageSeverity,
      'damageAreas': _damageAreas,
      'estimatedCost': _estimatedCost,
      'repairTimeframe': _repairTimeframe,
      'analysisDate': DateTime.now(),
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'minor':
        return Colors.green[700]!;
      case 'moderate':
        return Colors.orange[700]!;
      case 'severe':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Damage Assessment',
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900])),
          SizedBox(height: 8.h),
          Text(
              'AI-powered analysis to estimate repair costs and categorize damage severity',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: Colors.grey[600], height: 1.4)),
          SizedBox(height: 24.h),
          if (_isAnalyzing) ...[
            Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!)),
                child: Column(children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue[700])),
                  SizedBox(height: 16.h),
                  Text('Analyzing Damage...',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700])),
                  SizedBox(height: 8.h),
                  Text(
                      'Our AI is examining your photos to assess damage severity and estimate repair costs.',
                      style: GoogleFonts.inter(
                          fontSize: 13.sp, color: Colors.blue[600])),
                ])),
          ] else ...[
            // Analysis Results
            Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: Offset(0, 2)),
                ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.psychology,
                            color: Colors.blue[700], size: 20.sp),
                        SizedBox(width: 8.w),
                        Text('AI Analysis Results',
                            style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900])),
                      ]),
                      SizedBox(height: 16.h),

                      // Damage Severity
                      Row(children: [
                        Text('Damage Severity:',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, color: Colors.grey[700])),
                        SizedBox(width: 8.w),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                                color: _getSeverityColor(_damageSeverity)
                                    .withAlpha(26)),
                            child: Text(_damageSeverity.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _getSeverityColor(_damageSeverity)))),
                      ]),
                      SizedBox(height: 12.h),

                      // Estimated Cost
                      Row(children: [
                        Text('Estimated Repair Cost:',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, color: Colors.grey[700])),
                        SizedBox(width: 8.w),
                        Text('₺${_estimatedCost.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700])),
                      ]),
                      SizedBox(height: 12.h),

                      // Repair Timeframe
                      Row(children: [
                        Text('Estimated Timeframe:',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, color: Colors.grey[700])),
                        SizedBox(width: 8.w),
                        Text(_repairTimeframe,
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[900])),
                      ]),
                    ])),
            SizedBox(height: 24.h),

            // Damage Areas
            Text('Affected Areas',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900])),
            SizedBox(height: 12.h),
            Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _damageAreaOptions.map((area) {
                  final isSelected = _damageAreas.contains(area['value']);
                  return FilterChip(
                      label: Text(area['label']!,
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700])),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _damageAreas.add(area['value']!);
                          } else {
                            _damageAreas.remove(area['value']);
                          }
                        });
                        _updateAssessment();
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.red[700],
                      checkmarkColor: Colors.white);
                }).toList()),
            SizedBox(height: 24.h),

            // Manual Severity Override
            Text('Override Severity Assessment',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900])),
            SizedBox(height: 12.h),
            ..._severityLevels.map((severity) {
              final isSelected = _damageSeverity == severity['value'];
              return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? _getSeverityColor(severity['value']!).withAlpha(26)
                          : Colors.grey[50],
                      border: Border.all(
                          color: isSelected
                              ? _getSeverityColor(severity['value']!)
                              : Colors.grey[300]!)),
                  child: RadioListTile<String>(
                      value: severity['value']!,
                      groupValue: _damageSeverity,
                      onChanged: (value) {
                        setState(() {
                          _damageSeverity = value!;
                        });
                        _updateAssessment();
                      },
                      title: Text(severity['label']!,
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[900])),
                      subtitle: Text(severity['description']!,
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, color: Colors.grey[600])),
                      activeColor: _getSeverityColor(severity['value']!)));
            }),

            SizedBox(height: 24.h),
            Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber[200]!)),
                child: Row(children: [
                  Icon(Icons.warning_amber,
                      color: Colors.amber[700], size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: Text(
                          'This is an AI-generated estimate. Final costs may vary based on actual inspection by certified professionals.',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.amber[700],
                              height: 1.4))),
                ])),
          ],
        ]));
  }
}
