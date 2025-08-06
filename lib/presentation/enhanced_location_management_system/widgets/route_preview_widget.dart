import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoutePreviewWidget extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RoutePreviewWidget({
    Key? key,
    required this.routeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = routeData['distance']?.toDouble() ?? 0.0;
    final estimatedTime = routeData['estimatedTime']?.toDouble() ?? 0.0;
    final startAddress = routeData['startAddress']?.toString() ?? '';
    final endAddress = routeData['endAddress']?.toString() ?? '';

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
                iconName: 'route',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Rota Önizlemesi',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tahmini',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Route information cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.straighten,
                  title: 'Mesafe',
                  value: '${distance.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.access_time,
                  title: 'Tahmini Süre',
                  value: '${estimatedTime.toStringAsFixed(0)} dk',
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Route visualization
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Start point
                _buildRoutePoint(
                  icon: Icons.my_location,
                  label: 'Başlangıç',
                  address: startAddress,
                  color: Colors.green,
                ),

                // Route line
                Container(
                  margin: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Araç rotası',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Container(
                              height: 2,
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                  ),
                ),

                // End point
                _buildRoutePoint(
                  icon: Icons.location_on,
                  label: 'Varış',
                  address: endAddress,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Additional information
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rota Bilgisi',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Mesafe ve süre tahminidir. Trafik durumu ve yol koşulları gerçek süreni etkileyebilir.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(77),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint({
    required IconData icon,
    required String label,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                address,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
