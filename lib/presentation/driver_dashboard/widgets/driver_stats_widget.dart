import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DriverStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> profile;

  const DriverStatsWidget({
    Key? key,
    required this.stats,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Performance Overview
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Performans Özeti',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceItem(
                        'Puan',
                        '${stats['rating']}',
                        Icons.star,
                        'Müşteri memnuniyeti',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 12.h,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildPerformanceItem(
                        'Tamamlanan',
                        '${stats['completedJobs']}',
                        Icons.check_circle,
                        'Bu hafta',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Detailed Stats
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detaylı İstatistikler',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),

                // Earnings Stats
                _buildStatRow(
                  'Haftalık Kazanç',
                  '₺${stats['totalEarnings']?.toStringAsFixed(0) ?? '0'}',
                  Icons.account_balance_wallet,
                  AppTheme.lightTheme.colorScheme.tertiary,
                  '${(stats['totalEarnings'] / 7).toStringAsFixed(0)}₺/gün',
                ),

                SizedBox(height: 2.h),

                _buildStatRow(
                  'Çevrimiçi Saat',
                  '${stats['onlineHours']} saat',
                  Icons.access_time,
                  Colors.blue,
                  '${(stats['onlineHours'] / 7).toStringAsFixed(1)} saat/gün',
                ),

                SizedBox(height: 2.h),

                _buildStatRow(
                  'Ortalama İş Değeri',
                  '₺${(stats['totalEarnings'] / stats['completedJobs']).toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.purple,
                  'İş başına',
                ),

                SizedBox(height: 2.h),

                _buildStatRow(
                  'Müşteri Puanı',
                  '${stats['rating']}/5.0',
                  Icons.star,
                  Colors.amber,
                  '${profile['completedJobs']} değerlendirme',
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Achievement Badges
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Başarı Rozetleri',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementBadge(
                      'Güvenilir Sürücü',
                      Icons.shield,
                      Colors.blue,
                      stats['rating'] >= 4.5,
                    ),
                    _buildAchievementBadge(
                      'Hızlı Respons',
                      Icons.flash_on,
                      Colors.orange,
                      true, // Assuming they respond quickly
                    ),
                    _buildAchievementBadge(
                      'Süper Sürücü',
                      Icons.star,
                      Colors.amber,
                      stats['rating'] >= 4.8 && stats['completedJobs'] >= 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Weekly Progress
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Hedefler',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildProgressItem(
                  'Kazanç Hedefi',
                  stats['totalEarnings']?.toDouble() ?? 0,
                  5000.0,
                  '₺',
                  AppTheme.lightTheme.colorScheme.tertiary,
                ),
                SizedBox(height: 2.h),
                _buildProgressItem(
                  'İş Hedefi',
                  stats['completedJobs']?.toDouble() ?? 0,
                  30.0,
                  ' iş',
                  Colors.blue,
                ),
                SizedBox(height: 2.h),
                _buildProgressItem(
                  'Çevrimiçi Saat',
                  stats['onlineHours']?.toDouble() ?? 0,
                  50.0,
                  ' saat',
                  Colors.purple,
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
      String title, String value, IconData icon, String subtitle) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      String title, IconData icon, Color color, bool isEarned) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isEarned
                ? color.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEarned
                  ? color
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isEarned
                ? color
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5),
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isEarned
                ? color
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressItem(
      String title, double current, double target, String unit, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current.toStringAsFixed(0)}${unit} / ${target.toStringAsFixed(0)}${unit}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        SizedBox(height: 0.5.h),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% tamamlandı',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
