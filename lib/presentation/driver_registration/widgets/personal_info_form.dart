import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onNext;

  const PersonalInfoForm({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licenseNumberController;
  late TextEditingController _licenseExpiryController;
  late TextEditingController _experienceYearsController;

  @override
  void initState() {
    super.initState();
    _licenseNumberController = TextEditingController(
      text: widget.initialData['license_number'] ?? '',
    );
    _licenseExpiryController = TextEditingController(
      text: widget.initialData['license_expiry_date'] ?? '',
    );
    _experienceYearsController = TextEditingController(
      text: widget.initialData['experience_years']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Provide your driver license and professional details',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),

            // License Number
            Text(
              'Driver License Number *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _licenseNumberController,
              decoration: _inputDecoration('Enter your license number'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'License number is required';
                }
                if (value.length < 6) {
                  return 'Please enter a valid license number';
                }
                return null;
              },
              onChanged: (value) {
                widget.onDataChanged({'license_number': value});
              },
            ),
            SizedBox(height: 3.h),

            // License Expiry Date
            Text(
              'License Expiry Date *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _licenseExpiryController,
              decoration: _inputDecoration('DD/MM/YYYY').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectLicenseExpiryDate,
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'License expiry date is required';
                }
                return null;
              },
            ),
            SizedBox(height: 3.h),

            // Years of Experience
            Text(
              'Years of Driving Experience *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _experienceYearsController,
              decoration: _inputDecoration('Enter years of experience'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Experience is required';
                }
                final years = int.tryParse(value);
                if (years == null || years < 1) {
                  return 'Please enter valid years of experience';
                }
                if (years < 3) {
                  return 'Minimum 3 years of driving experience required';
                }
                return null;
              },
              onChanged: (value) {
                final years = int.tryParse(value);
                if (years != null) {
                  widget.onDataChanged({'experience_years': years});
                }
              },
            ),
            SizedBox(height: 4.h),

            // Professional Information
            Text(
              'Professional Information',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),

            // Experience with Towing
            Text(
              'Do you have previous towing experience?',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Yes'),
                    value: true,
                    groupValue: widget.initialData['has_towing_experience'],
                    onChanged: (value) {
                      setState(() {
                        widget.onDataChanged({'has_towing_experience': value});
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: widget.initialData['has_towing_experience'],
                    onChanged: (value) {
                      setState(() {
                        widget.onDataChanged({'has_towing_experience': value});
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Availability Hours
            Text(
              'Preferred Working Hours',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                _buildAvailabilityChip('24/7', '24_7'),
                _buildAvailabilityChip('Day Shift (6AM-6PM)', 'day'),
                _buildAvailabilityChip('Night Shift (6PM-6AM)', 'night'),
                _buildAvailabilityChip('Weekends Only', 'weekends'),
                _buildAvailabilityChip('Emergency Only', 'emergency'),
              ],
            ),
            SizedBox(height: 6.h),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next: Vehicle Information',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip(String label, String value) {
    final isSelected = widget.initialData['preferred_hours'] == value;

    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          widget.onDataChanged({'preferred_hours': selected ? value : null});
        });
      },
      selectedColor: Colors.orange[600],
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.orange[600]!),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _selectLicenseExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[600]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';

      setState(() {
        _licenseExpiryController.text = formattedDate;
        widget.onDataChanged(
            {'license_expiry_date': picked.toIso8601String().split('T')[0]});
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (widget.initialData['has_towing_experience'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your towing experience')),
        );
        return;
      }

      widget.onNext();
    }
  }
}
