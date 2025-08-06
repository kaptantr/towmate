import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class QualityAssuranceWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activeRequests;
  final List<Map<String, dynamic>> drivers;
  final Function(String, Map<String, dynamic>) onQualityCheck;

  const QualityAssuranceWidget({
    super.key,
    required this.activeRequests,
    required this.drivers,
    required this.onQualityCheck,
  });

  @override
  State<QualityAssuranceWidget> createState() => _QualityAssuranceWidgetState();
}

class _QualityAssuranceWidgetState extends State<QualityAssuranceWidget> {
  String _selectedTimeFrame = 'today';
  String _qualityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildQualityOverview(),
          SizedBox(height: 16.h),
          _buildServiceMonitoring(),
          SizedBox(height: 16.h),
          _buildCustomerFeedback(),
          SizedBox(height: 16.h),
          _buildDriverCompliance(),
          SizedBox(height: 16.h),
          _buildQualityMetrics(),
        ]));
  }

  Widget _buildQualityOverview() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Quality Assurance Overview',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            DropdownButton<String>(
                value: _selectedTimeFrame,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('Today')),
                  DropdownMenuItem(value: 'week', child: Text('This Week')),
                  DropdownMenuItem(value: 'month', child: Text('This Month')),
                ],
                onChanged: (value) =>
                    setState(() => _selectedTimeFrame = value!)),
          ]),
          SizedBox(height: 16.h),
          GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.3,
              children: [
                _buildQualityCard('Service Quality Score', '4.7/5.0',
                    Icons.star, AppTheme.successLight, '+0.2', true),
                _buildQualityCard('Compliance Rate', '96.3%', Icons.verified,
                    AppTheme.primaryLight, '+1.5%', true),
                _buildQualityCard('Response Time Avg', '11.2 min', Icons.timer,
                    AppTheme.warningLight, '-0.8 min', true),
                _buildQualityCard('Customer Satisfaction', '94.1%',
                    Icons.thumb_up, AppTheme.accentLight, '+2.3%', true),
              ]),
        ]));
  }

  Widget _buildQualityCard(String title, String value, IconData icon,
      Color color, String change, bool isPositive) {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: color.withAlpha(13),
            border: Border.all(color: color.withAlpha(51))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 20.sp),
            const Spacer(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.successLight.withAlpha(26)
                        : AppTheme.errorLight.withAlpha(26)),
                child: Text(change,
                    style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? AppTheme.successLight
                            : AppTheme.errorLight))),
          ]),
          SizedBox(height: 8.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight)),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildServiceMonitoring() {
    final activeServices = widget.activeRequests
        .where((r) => r['status'] == 'in_progress')
        .toList();

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Active Service Monitoring',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          if (activeServices.isEmpty)
            Center(
                child: Padding(
                    padding: EdgeInsets.all(32.h),
                    child: Column(children: [
                      Icon(Icons.check_circle_outline,
                          size: 48.sp, color: AppTheme.successLight),
                      SizedBox(height: 8.h),
                      Text('No active services to monitor',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, color: AppTheme.successLight)),
                    ])))
          else
            ...activeServices
                .take(3)
                .map((service) => _buildServiceMonitorItem(service))
                .toList(),
          if (activeServices.length > 3)
            Center(
                child: TextButton(
                    onPressed: () => _showAllActiveServices(),
                    child: Text(
                        'View all ${activeServices.length} active services'))),
        ]));
  }

  Widget _buildServiceMonitorItem(Map<String, dynamic> service) {
    final startTime = service['started_at'] != null
        ? DateTime.parse(service['started_at'].toString())
        : DateTime.parse(service['accepted_at'].toString());
    final elapsed = DateTime.now().difference(startTime);
    final estimatedDuration = _getEstimatedDuration(service['service_type']);
    final isDelayed = elapsed.inMinutes > estimatedDuration;

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            border: Border.all(
                color: isDelayed
                    ? AppTheme.errorLight.withAlpha(77)
                    : AppTheme.borderLight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration:
                    BoxDecoration(color: _getUrgencyColor(service['urgency'])),
                child: Text(
                    service['service_type']?.toString().toUpperCase() ??
                        'SERVICE',
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white))),
            const Spacer(),
            if (isDelayed)
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration:
                      BoxDecoration(color: AppTheme.errorLight.withAlpha(26)),
                  child: Text('DELAYED',
                      style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorLight))),
          ]),
          SizedBox(height: 8.h),
          Text(service['pickup_address'] ?? 'Unknown location',
              style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Row(children: [
            Icon(Icons.access_time,
                size: 14.sp, color: AppTheme.textSecondaryLight),
            SizedBox(width: 4.w),
            Text('Elapsed: ${elapsed.inHours}h ${elapsed.inMinutes % 60}m',
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
            const Spacer(),
            Text('Est: ${estimatedDuration}min',
                style: GoogleFonts.inter(
                    fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
          ]),
          SizedBox(height: 8.h),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => _contactCustomer(service),
                    child: const Text('Contact Customer'))),
            SizedBox(width: 8.w),
            Expanded(
                child: ElevatedButton(
                    onPressed: () => _performQualityCheck(service),
                    child: const Text('Quality Check'))),
          ]),
        ]));
  }

  Widget _buildCustomerFeedback() {
    final recentFeedback = [
      {
        'customer': 'John D.',
        'rating': 5.0,
        'comment': 'Excellent service, driver was professional and quick!',
        'service': 'Towing',
        'time': '2 hours ago',
      },
      {
        'customer': 'Sarah M.',
        'rating': 4.0,
        'comment': 'Good service but driver arrived 10 minutes late.',
        'service': 'Jumpstart',
        'time': '4 hours ago',
      },
      {
        'customer': 'Mike R.',
        'rating': 3.0,
        'comment': 'Service was okay but could have been more communicative.',
        'service': 'Tire Change',
        'time': '1 day ago',
      },
    ];

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Recent Customer Feedback',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            DropdownButton<String>(
                value: _qualityFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'high', child: Text('4+ Stars')),
                  DropdownMenuItem(value: 'medium', child: Text('3-4 Stars')),
                  DropdownMenuItem(value: 'low', child: Text('< 3 Stars')),
                ],
                onChanged: (value) => setState(() => _qualityFilter = value!)),
          ]),
          SizedBox(height: 12.h),
          ...recentFeedback
              .map((feedback) => _buildFeedbackItem(feedback))
              .toList(),
          SizedBox(height: 12.h),
          Center(
              child: TextButton(
                  onPressed: _viewAllFeedback,
                  child: const Text('View All Feedback'))),
        ]));
  }

  Widget _buildFeedbackItem(Map<String, dynamic> feedback) {
    final rating = feedback['rating'] as double;
    final color = _getRatingColor(rating);

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: AppTheme.backgroundLight),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(feedback['customer'],
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            SizedBox(width: 8.w),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: color.withAlpha(26)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star, size: 12.sp, color: color),
                  SizedBox(width: 2.w),
                  Text(rating.toString(),
                      style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ])),
            const Spacer(),
            Text(feedback['time'],
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
          ]),
          SizedBox(height: 8.h),
          Text(feedback['comment'],
              style: GoogleFonts.inter(
                  fontSize: 12.sp, color: AppTheme.textPrimaryLight)),
          SizedBox(height: 4.h),
          Text('Service: ${feedback['service']}',
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildDriverCompliance() {
    final topDrivers = widget.drivers.take(5).toList();

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Driver Compliance Monitoring',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          ...topDrivers.map((driver) => _buildComplianceItem(driver)).toList(),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
              onPressed: _generateComplianceReport,
              icon: const Icon(Icons.assessment),
              label: const Text('Generate Compliance Report')),
        ]));
  }

  Widget _buildComplianceItem(Map<String, dynamic> driver) {
    // Mock compliance score calculation
    final complianceScore = 85 + (DateTime.now().millisecond % 15);
    final color = _getComplianceColor(complianceScore);

    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: color.withAlpha(26),
              child: Text(
                  driver['user_profiles']?['full_name']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'D',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color))),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(driver['user_profiles']?['full_name'] ?? 'Unknown Driver',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight)),
                Text(
                    'Rating: ${driver['rating']} • ${driver['total_jobs']} jobs',
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
              ])),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: color.withAlpha(26)),
              child: Text('$complianceScore%',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color))),
        ]));
  }

  Widget _buildQualityMetrics() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quality Metrics & Standards',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          _buildMetricStandard(
              'Response Time', '< 15 minutes', 'Current: 11.2 min', true),
          _buildMetricStandard(
              'Customer Rating', '> 4.5 stars', 'Current: 4.7 stars', true),
          _buildMetricStandard(
              'Completion Rate', '> 95%', 'Current: 96.3%', true),
          _buildMetricStandard(
              'Arrival Accuracy', '> 90%', 'Current: 87.1%', false),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _updateStandards,
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Standards'))),
            SizedBox(width: 12.w),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: _exportQualityReport,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Report'))),
          ]),
        ]));
  }

  Widget _buildMetricStandard(
      String metric, String standard, String current, bool meetingStandard) {
    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: meetingStandard
                ? AppTheme.successLight.withAlpha(13)
                : AppTheme.warningLight.withAlpha(13),
            border: Border.all(
                color: meetingStandard
                    ? AppTheme.successLight.withAlpha(51)
                    : AppTheme.warningLight.withAlpha(51))),
        child: Row(children: [
          Icon(meetingStandard ? Icons.check_circle : Icons.warning,
              color: meetingStandard
                  ? AppTheme.successLight
                  : AppTheme.warningLight,
              size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(metric,
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight)),
                Text('Standard: $standard',
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
              ])),
          Text(current,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: meetingStandard
                      ? AppTheme.successLight
                      : AppTheme.warningLight)),
        ]));
  }

  int _getEstimatedDuration(String? serviceType) {
    switch (serviceType) {
      case 'towing':
        return 45;
      case 'jumpstart':
        return 15;
      case 'tire_change':
        return 30;
      case 'lockout':
        return 20;
      case 'fuel_delivery':
        return 25;
      default:
        return 30;
    }
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency) {
      case 'emergency':
        return AppTheme.errorLight;
      case 'high':
        return AppTheme.accentLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.primaryLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppTheme.successLight;
    if (rating >= 3.5) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  Color _getComplianceColor(int score) {
    if (score >= 90) return AppTheme.successLight;
    if (score >= 75) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  void _performQualityCheck(Map<String, dynamic> service) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Quality Check'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service ID: ${service['id']}'),
                      Text('Type: ${service['service_type']}'),
                      Text('Location: ${service['pickup_address']}'),
                      SizedBox(height: 16.h),
                      const Text('Quality Check Results:'),
                      const Text('• Driver arrived on time ✓'),
                      const Text('• Customer contacted ✓'),
                      const Text('• Service completed properly ✓'),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onQualityCheck(
                            service['id'], {'status': 'passed', 'score': 95});
                      },
                      child: const Text('Submit Check')),
                ]));
  }

  void _contactCustomer(Map<String, dynamic> service) {
    debugPrint('Contacting customer for service: ${service['id']}');
  }

  void _showAllActiveServices() {
    debugPrint('Showing all active services');
  }

  void _viewAllFeedback() {
    debugPrint('Viewing all customer feedback');
  }

  void _generateComplianceReport() {
    debugPrint('Generating driver compliance report');
  }

  void _updateStandards() {
    debugPrint('Opening quality standards configuration');
  }

  void _exportQualityReport() {
    debugPrint('Exporting quality assurance report');
  }
}
