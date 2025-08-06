import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverStatusIndicator extends StatelessWidget {
  final String status;
  final String? eta;

  const DriverStatusIndicator({
    Key? key,
    required this.status,
    this.eta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getStatusIcon(),
                color: _getStatusColor(),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Status text and ETA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (eta != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Tahmini varış: $eta',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Animated indicator
          if (status == 'en_route_to_customer' ||
              status == 'en_route_to_destination')
            SizedBox(
              width: 6.w,
              height: 6.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case 'matching':
        return 'Sürücü aranıyor...';
      case 'matched':
        return 'Sürücü atandı';
      case 'en_route_to_customer':
        return 'Size doğru geliyor';
      case 'arrived':
        return 'Sürücü geldi';
      case 'loading_vehicle':
        return 'Araç yükleniyor';
      case 'en_route_to_destination':
        return 'Hedefe doğru gidiyor';
      case 'completed':
        return 'Hizmet tamamlandı';
      default:
        return 'Durum güncelleniyor...';
    }
  }

  String _getStatusIcon() {
    switch (status) {
      case 'matching':
        return 'search';
      case 'matched':
        return 'check_circle';
      case 'en_route_to_customer':
        return 'directions_car';
      case 'arrived':
        return 'location_on';
      case 'loading_vehicle':
        return 'build';
      case 'en_route_to_destination':
        return 'navigation';
      case 'completed':
        return 'done_all';
      default:
        return 'info';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'matching':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'matched':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'en_route_to_customer':
      case 'en_route_to_destination':
        return AppTheme.lightTheme.primaryColor;
      case 'arrived':
        return Colors.orange;
      case 'loading_vehicle':
        return Colors.blue;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
