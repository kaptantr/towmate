import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ServiceDescriptionSelector extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final Function(String) onDescriptionSelected;

  const ServiceDescriptionSelector({
    Key? key,
    required this.serviceId,
    required this.serviceName,
    required this.onDescriptionSelected,
  }) : super(key: key);

  @override
  State<ServiceDescriptionSelector> createState() =>
      _ServiceDescriptionSelectorState();
}

class _ServiceDescriptionSelectorState
    extends State<ServiceDescriptionSelector> {
  String? _selectedDescription;
  final TextEditingController _customController = TextEditingController();

  final Map<String, List<String>> _serviceDescriptions = {
    'towing': [
      'Vehicle won\'t start',
      'Accident - need towing',
      'Flat tire - can\'t change',
      'Engine problems',
      'Overheating',
      'Other',
    ],
    'battery_jump': [
      'Car won\'t start',
      'Battery completely dead',
      'Lights left on',
      'Cold weather battery issue',
      'Other',
    ],
    'tire_change': [
      'Flat tire - front left',
      'Flat tire - front right',
      'Flat tire - rear left',
      'Flat tire - rear right',
      'Multiple flat tires',
      'Other',
    ],
    'fuel_delivery': [
      'Completely out of gas',
      'Nearly empty tank',
      'Wrong fuel type',
      'Fuel system issue',
      'Other',
    ],
    'lockout_service': [
      'Keys locked inside',
      'Key broken in lock',
      'Lost keys',
      'Electronic lock malfunction',
      'Other',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final descriptions = _serviceDescriptions[widget.serviceId] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.serviceName,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),

          // Description Options
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: descriptions.map((description) {
              final isSelected = _selectedDescription == description;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDescription = description;
                  });

                  if (description == 'Other') {
                    // Show text input for custom description
                    _showCustomDescriptionDialog();
                  } else {
                    widget.onDescriptionSelected(description);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withAlpha(26)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Show custom text if "Other" is selected
          if (_selectedDescription == 'Other' &&
              _customController.text.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                _customController.text,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCustomDescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Describe Your Situation',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _customController,
          decoration: const InputDecoration(
            hintText: 'Please describe your situation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_customController.text.trim().isNotEmpty) {
                widget.onDescriptionSelected(_customController.text.trim());
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }
}
