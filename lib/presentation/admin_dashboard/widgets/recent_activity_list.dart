import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(
              child: Text('No recent activities',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: Colors.grey[600]))));
    }

    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity);
            }));
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final activityType = activity['activity_type'] ?? '';
    final action = activity['action'] ?? '';
    final adminName =
        activity['user_profiles']?['full_name'] ?? 'Unknown Admin';
    final createdAt = activity['created_at'] ?? '';

    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
                color: _getActivityColor(activityType).withAlpha(26),
                borderRadius: BorderRadius.circular(8)),
            child: CustomIconWidget(
                iconName: _getActivityIcon(activityType),
                size: 5.w,
                color: _getActivityColor(activityType))),
        title: Text(_formatAction(action),
            style: GoogleFonts.inter(
                fontSize: 13.sp, fontWeight: FontWeight.w600)),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('by $adminName',
              style:
                  GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
          Text(_formatTime(createdAt),
              style:
                  GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey[500])),
        ]),
        trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
                color: _getActivityColor(activityType).withAlpha(26),
                borderRadius: BorderRadius.circular(4)),
            child: Text(_formatActivityType(activityType),
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _getActivityColor(activityType)))));
  }

  String _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'user_management':
        return 'people';
      case 'driver_verification':
        return 'verified_user';
      case 'payment_management':
        return 'payment';
      case 'system_config':
        return 'settings';
      case 'content_moderation':
        return 'help_outline';
      case 'data_export':
        return 'download';
      default:
        return 'help_outline';
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'user_management':
        return Colors.blue[600]!;
      case 'driver_verification':
        return Colors.green[600]!;
      case 'payment_management':
        return Colors.purple[600]!;
      case 'system_config':
        return Colors.orange[600]!;
      case 'content_moderation':
        return Colors.red[600]!;
      case 'data_export':
        return Colors.teal[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatActivityType(String activityType) {
    switch (activityType) {
      case 'user_management':
        return 'USER';
      case 'driver_verification':
        return 'DRIVER';
      case 'payment_management':
        return 'PAYMENT';
      case 'system_config':
        return 'SYSTEM';
      case 'content_moderation':
        return 'CONTENT';
      case 'data_export':
        return 'EXPORT';
      default:
        return activityType.toUpperCase();
    }
  }

  String _formatAction(String action) {
    return action.replaceAll('_', ' ').toUpperCase();
  }

  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}