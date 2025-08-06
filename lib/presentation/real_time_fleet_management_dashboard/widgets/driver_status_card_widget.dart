import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DriverStatusCardWidget extends StatelessWidget {
  final Map<String, dynamic> driver;
  final VoidCallback onTap;

  const DriverStatusCardWidget({
    super.key,
    required this.driver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
            child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver header
                      Row(children: [
                        CircleAvatar(
                            backgroundColor:
                                _getStatusColor(driver['current_status']),
                            child: Text(_getDriverInitials(),
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white))),
                        SizedBox(width: 8.w),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(_getDriverName(),
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimaryLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Row(children: [
                                Container(
                                    width: 6.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            driver['current_status']),
                                        shape: BoxShape.circle)),
                                SizedBox(width: 4.w),
                                Text(
                                    driver['current_status']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                        color: _getStatusColor(
                                            driver['current_status']))),
                              ]),
                            ])),
                      ]),

                      SizedBox(height: 12.h),

                      // Vehicle info
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration:
                              BoxDecoration(color: AppTheme.backgroundLight),
                          child: Text(
                              '${driver['vehicle_make'] ?? ''} ${driver['vehicle_model'] ?? ''}',
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),

                      SizedBox(height: 8.h),

                      // Stats row
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                                Icons.star,
                                '${driver['rating'] ?? 0.0}',
                                AppTheme.warningLight),
                            _buildStatItem(
                                Icons.work,
                                '${driver['total_jobs'] ?? 0}',
                                AppTheme.primaryLight),
                            _buildStatItem(
                                Icons.attach_money,
                                '\$${(driver['total_earnings'] ?? 0).toString().split('.')[0]}',
                                AppTheme.successLight),
                          ]),

                      SizedBox(height: 8.h),

                      // Last update
                      Text(_getLastUpdateText(),
                          style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: AppTheme.textSecondaryLight)),
                    ]))));
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12.sp, color: color),
      SizedBox(width: 2.w),
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryLight)),
    ]);
  }

  String _getDriverName() {
    return driver['user_profiles']?['full_name'] ?? 'Unknown Driver';
  }

  String _getDriverInitials() {
    final name = _getDriverName();
    if (name == 'Unknown Driver') return 'D';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getLastUpdateText() {
    final lastUpdate = driver['last_location_update'];
    if (lastUpdate == null) return 'No location data';

    try {
      final updateTime = DateTime.parse(lastUpdate.toString());
      final now = DateTime.now();
      final difference = now.difference(updateTime);

      if (difference.inMinutes < 1) {
        return 'Updated just now';
      } else if (difference.inMinutes < 60) {
        return 'Updated ${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return 'Updated ${difference.inHours}h ago';
      } else {
        return 'Updated ${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'online':
        return AppTheme.successLight;
      case 'busy':
        return AppTheme.warningLight;
      case 'offline':
        return AppTheme.textSecondaryLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
