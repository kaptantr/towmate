import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ServiceCardWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final Function(bool) onSelectionChanged;

  const ServiceCardWidget({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAvailable = service['available'] as bool;

    return GestureDetector(
      onTap: isAvailable ? () => onSelectionChanged(!isSelected) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withAlpha(26)
                  : Colors.black.withAlpha(13),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Service Icon
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withAlpha(26)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  size: 24.sp,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isAvailable
                          ? Colors.grey[700]
                          : Colors.grey[400],
                ),
              ),
              SizedBox(height: 2.h),

              // Service Name
              Text(
                service['name'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? Colors.black87 : Colors.grey[400],
                ),
              ),
              SizedBox(height: 1.h),

              // Price
              Text(
                '\$${(service['basePrice'] as double).toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isAvailable
                          ? Colors.green[600]
                          : Colors.grey[400],
                ),
              ),

              // Availability Indicator
              if (!isAvailable) ...[
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Unavailable',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],

              // Selection Checkbox
              if (isAvailable) ...[
                SizedBox(height: 1.h),
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 12.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
