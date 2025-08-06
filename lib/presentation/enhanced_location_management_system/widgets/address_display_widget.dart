import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddressDisplayWidget extends StatelessWidget {
  final String title;
  final String? address;
  final Position? position;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String iconName;

  const AddressDisplayWidget({
    Key? key,
    required this.title,
    this.address,
    this.position,
    this.isLoading = false,
    this.onRefresh,
    this.iconName = 'location_on',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Address content
          if (isLoading)
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Konum tespit ediliyor...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          else if (position != null && address != null) ...[
            // Address display
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Konum Onaylandı',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    address!,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Koordinatlar: ${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Location accuracy indicator
            Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: _getAccuracyColor(position!.accuracy),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Konum Doğruluğu: ${_getAccuracyText(position!.accuracy)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getAccuracyColor(position!.accuracy),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Error state
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off,
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 32,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Konum tespit edilemedi',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'GPS ve konum servislerinin açık olduğundan emin olun.',
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (onRefresh != null) ...[
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : onRefresh,
                      icon: Icon(
                        isLoading ? Icons.hourglass_empty : Icons.refresh,
                        size: 16,
                      ),
                      label: Text(isLoading ? 'Deneniyor...' : 'Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 5) return Colors.green;
    if (accuracy <= 20) return Colors.orange;
    return Colors.red;
  }

  String _getAccuracyText(double accuracy) {
    if (accuracy <= 5) return 'Mükemmel (±${accuracy.toStringAsFixed(0)}m)';
    if (accuracy <= 20) return 'İyi (±${accuracy.toStringAsFixed(0)}m)';
    return 'Orta (±${accuracy.toStringAsFixed(0)}m)';
  }
}
