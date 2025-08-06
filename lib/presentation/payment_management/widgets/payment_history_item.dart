import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentHistoryItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onTap;

  const PaymentHistoryItem({
    Key? key,
    required this.payment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = payment['amount'] ?? 0.0;
    final status = payment['payment_status'] ?? 'unknown';
    final serviceType =
        payment['service_requests']?['service_type'] ?? 'Towing';
    final createdAt = payment['created_at'] ?? '';
    final driverName = payment['driver_profiles']?['user_profiles']
            ?['full_name'] ??
        'Unknown Driver';

    return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Row(children: [
                      // Service Icon
                      Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: _getStatusColor(status).withAlpha(26),
                              borderRadius: BorderRadius.circular(8)),
                          child: CustomIconWidget(
                              iconName: _getServiceIcon(serviceType),
                              size: 6.w,
                              color: _getStatusColor(status))),
                      SizedBox(width: 4.w),

                      // Payment Details
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatServiceType(serviceType),
                                      style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)),
                                  Text('₺${amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(status))),
                                ]),
                            SizedBox(height: 1.h),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(driverName,
                                      style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600])),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                          color: _getStatusColor(status)
                                              .withAlpha(26),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(_formatStatus(status),
                                          style: GoogleFonts.inter(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: _getStatusColor(status)))),
                                ]),
                            SizedBox(height: 1.h),
                            Text(_formatDate(createdAt),
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp, color: Colors.grey[500])),
                          ])),
                    ])))));
  }

  String _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'towing':
        return 'local_shipping';
      case 'jumpstart':
        return 'flash_on';
      case 'tire_change':
        return 'tire_repair';
      case 'lockout':
        return 'lock_open';
      case 'fuel_delivery':
        return 'local_gas_station';
      case 'winch_service':
        return 'build';
      default:
        return 'build';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'processing':
        return Colors.blue[600]!;
      case 'failed':
        return Colors.red[600]!;
      case 'refunded':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'processing':
        return 'PROCESSING';
      case 'failed':
        return 'FAILED';
      case 'refunded':
        return 'REFUNDED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatServiceType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'towing':
        return 'Towing Service';
      case 'jumpstart':
        return 'Jump Start';
      case 'tire_change':
        return 'Tire Change';
      case 'lockout':
        return 'Lockout Service';
      case 'fuel_delivery':
        return 'Fuel Delivery';
      case 'winch_service':
        return 'Winch Service';
      default:
        return serviceType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
