import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class VehicleInfoForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const VehicleInfoForm({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  State<VehicleInfoForm> createState() => _VehicleInfoFormState();
}

class _VehicleInfoFormState extends State<VehicleInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleMakeController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleYearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _insuranceNumberController;
  late TextEditingController _insuranceExpiryController;
  late TextEditingController _towingCapacityController;

  String? _selectedVehicleType;

  final List<Map<String, String>> _vehicleTypes = [
    {'value': 'truck', 'label': 'Truck'},
    {'value': 'heavy_truck', 'label': 'Heavy Truck'},
    {'value': 'bus', 'label': 'Bus'},
  ];

  @override
  void initState() {
    super.initState();
    _vehicleMakeController = TextEditingController(
      text: widget.initialData['vehicle_make'] ?? '',
    );
    _vehicleModelController = TextEditingController(
      text: widget.initialData['vehicle_model'] ?? '',
    );
    _vehicleYearController = TextEditingController(
      text: widget.initialData['vehicle_year']?.toString() ?? '',
    );
    _licensePlateController = TextEditingController(
      text: widget.initialData['license_plate'] ?? '',
    );
    _insuranceNumberController = TextEditingController(
      text: widget.initialData['insurance_number'] ?? '',
    );
    _insuranceExpiryController = TextEditingController(
      text: widget.initialData['insurance_expiry_date'] ?? '',
    );
    _towingCapacityController = TextEditingController(
      text: widget.initialData['towing_capacity']?.toString() ?? '',
    );
    _selectedVehicleType = widget.initialData['vehicle_type'];
  }

  @override
  void dispose() {
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    _insuranceNumberController.dispose();
    _insuranceExpiryController.dispose();
    _towingCapacityController.dispose();
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
              'Vehicle Information',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Provide details about your tow truck',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),

            // Vehicle Make
            Text(
              'Vehicle Make *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _vehicleMakeController,
              decoration: _inputDecoration('e.g., Ford, Mercedes, Volvo'),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vehicle make is required';
                }
                return null;
              },
              onChanged: (value) {
                widget.onDataChanged({'vehicle_make': value});
              },
            ),
            SizedBox(height: 3.h),

            // Vehicle Model
            Text(
              'Vehicle Model *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _vehicleModelController,
              decoration: _inputDecoration('e.g., Transit, Actros, FH'),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vehicle model is required';
                }
                return null;
              },
              onChanged: (value) {
                widget.onDataChanged({'vehicle_model': value});
              },
            ),
            SizedBox(height: 3.h),

            // Vehicle Year and Type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year *',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _vehicleYearController,
                        decoration: _inputDecoration('2020'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Year required';
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 2000 ||
                              year > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final year = int.tryParse(value);
                          if (year != null) {
                            widget.onDataChanged({'vehicle_year': year});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Type *',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        decoration: _inputDecoration('Select type'),
                        items: _vehicleTypes.map((type) {
                          return DropdownMenuItem(
                            value: type['value'],
                            child: Text(type['label']!),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Type required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value;
                            widget.onDataChanged({'vehicle_type': value});
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // License Plate
            Text(
              'License Plate *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _licensePlateController,
              decoration: _inputDecoration('34 ABC 123'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'License plate is required';
                }
                return null;
              },
              onChanged: (value) {
                widget.onDataChanged({'license_plate': value});
              },
            ),
            SizedBox(height: 3.h),

            // Towing Capacity
            Text(
              'Towing Capacity (tons) *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _towingCapacityController,
              decoration: _inputDecoration('e.g., 3.5, 7.5, 15'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Towing capacity is required';
                }
                final capacity = double.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Please enter valid towing capacity';
                }
                return null;
              },
              onChanged: (value) {
                final capacity = double.tryParse(value);
                if (capacity != null) {
                  widget.onDataChanged({'towing_capacity': capacity});
                }
              },
            ),
            SizedBox(height: 4.h),

            // Insurance Information
            Text(
              'Insurance Information',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),

            // Insurance Number
            Text(
              'Insurance Policy Number *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _insuranceNumberController,
              decoration: _inputDecoration('Enter insurance policy number'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Insurance number is required';
                }
                return null;
              },
              onChanged: (value) {
                widget.onDataChanged({'insurance_number': value});
              },
            ),
            SizedBox(height: 3.h),

            // Insurance Expiry Date
            Text(
              'Insurance Expiry Date *',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _insuranceExpiryController,
              decoration: _inputDecoration('DD/MM/YYYY').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectInsuranceExpiryDate,
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Insurance expiry date is required';
                }
                return null;
              },
            ),
            SizedBox(height: 6.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange[600]!),
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
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
                      'Create Profile',
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
          ],
        ),
      ),
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

  Future<void> _selectInsuranceExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)), // 5 years
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
        _insuranceExpiryController.text = formattedDate;
        widget.onDataChanged(
            {'insurance_expiry_date': picked.toIso8601String().split('T')[0]});
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext();
    }
  }
}
