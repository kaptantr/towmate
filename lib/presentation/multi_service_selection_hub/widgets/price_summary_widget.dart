import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PriceSummaryWidget extends StatelessWidget {
  final Map<String, bool> selectedServices;
  final Map<String, double> servicePrices;
  final double discount;
  final double totalPrice;
  final bool emergencyPriority;
  final VoidCallback onRequestServices;

  const PriceSummaryWidget({
    Key? key,
    required this.selectedServices,
    required this.servicePrices,
    required this.discount,
    required this.totalPrice,
    required this.emergencyPriority,
    required this.onRequestServices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        selectedServices.values.where((selected) => selected).length;
    final subtotal = selectedServices.entries
        .where((entry) => entry.value)
        .fold<double>(
            0.0, (sum, entry) => sum + (servicePrices[entry.key] ?? 0.0));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price Breakdown
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Services ($selectedCount)',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    if (discount > 0) ...[
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bundle Discount (15%)',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: Colors.green[600],
                            ),
                          ),
                          Text(
                            '-\$${discount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (emergencyPriority) ...[
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Emergency Priority',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: Colors.red[600],
                            ),
                          ),
                          Text(
                            '+\$25.00',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Request Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: onRequestServices,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue to Location',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
