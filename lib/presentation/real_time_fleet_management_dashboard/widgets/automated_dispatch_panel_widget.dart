import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AutomatedDispatchPanelWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activeRequests;
  final List<Map<String, dynamic>> availableDrivers;
  final Function(String, String) onRequestAssigned;

  const AutomatedDispatchPanelWidget({
    super.key,
    required this.activeRequests,
    required this.availableDrivers,
    required this.onRequestAssigned,
  });

  @override
  State<AutomatedDispatchPanelWidget> createState() =>
      _AutomatedDispatchPanelWidgetState();
}

class _AutomatedDispatchPanelWidgetState
    extends State<AutomatedDispatchPanelWidget> {
  bool _autoDispatchEnabled = true;
  String _dispatchAlgorithm = 'proximity';
  List<Map<String, dynamic>> _dispatchQueue = [];

  @override
  void initState() {
    super.initState();
    _generateDispatchRecommendations();
  }

  void _generateDispatchRecommendations() {
    _dispatchQueue = widget.activeRequests
        .where((request) => request['status'] == 'pending')
        .map((request) => {
              ...request,
              'recommended_driver': _findBestDriver(request),
              'confidence_score': _calculateConfidenceScore(request),
            })
        .toList();

    // Sort by urgency and confidence score
    _dispatchQueue.sort((a, b) {
      final urgencyOrder = ['emergency', 'high', 'medium', 'low'];
      final urgencyA = urgencyOrder.indexOf(a['urgency'] ?? 'medium');
      final urgencyB = urgencyOrder.indexOf(b['urgency'] ?? 'medium');

      if (urgencyA != urgencyB) return urgencyA.compareTo(urgencyB);
      return (b['confidence_score'] ?? 0.0)
          .compareTo(a['confidence_score'] ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildDispatchControlPanel(),
          SizedBox(height: 16.h),
          _buildDispatchQueue(),
          SizedBox(height: 16.h),
          _buildDispatchMetrics(),
          SizedBox(height: 16.h),
          _buildMLInsights(),
        ]));
  }

  Widget _buildDispatchControlPanel() {
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
            Text('Automated Dispatch Control',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            Switch(
                value: _autoDispatchEnabled,
                onChanged: (value) =>
                    setState(() => _autoDispatchEnabled = value)),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Text('Algorithm:',
                style: GoogleFonts.inter(
                    fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
            SizedBox(width: 12.w),
            Expanded(
                child: DropdownButton<String>(
                    value: _dispatchAlgorithm,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'proximity', child: Text('Proximity Based')),
                      DropdownMenuItem(
                          value: 'rating', child: Text('Rating Optimized')),
                      DropdownMenuItem(
                          value: 'hybrid', child: Text('Hybrid ML Model')),
                      DropdownMenuItem(
                          value: 'traffic', child: Text('Traffic Aware')),
                    ],
                    onChanged: (value) =>
                        setState(() => _dispatchAlgorithm = value!))),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: _autoDispatchEnabled ? _runAutoDispatch : null,
                    icon: const Icon(Icons.auto_mode),
                    label: const Text('Auto Dispatch All'))),
            SizedBox(width: 12.w),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _generateDispatchRecommendations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Queue'))),
          ]),
        ]));
  }

  Widget _buildDispatchQueue() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dispatch Queue (${_dispatchQueue.length} pending)',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          if (_dispatchQueue.isEmpty)
            Center(
                child: Padding(
                    padding: EdgeInsets.all(32.h),
                    child: Column(children: [
                      Icon(Icons.check_circle_outline,
                          size: 48.sp, color: AppTheme.successLight),
                      SizedBox(height: 8.h),
                      Text('All requests assigned!',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp, color: AppTheme.successLight)),
                    ])))
          else
            ...(_dispatchQueue
                .take(5)
                .map((request) => _buildDispatchQueueItem(request))
                .toList()),
          if (_dispatchQueue.length > 5)
            Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Center(
                    child: TextButton(
                        onPressed: () => _showFullQueue(),
                        child: Text(
                            'View all ${_dispatchQueue.length} requests')))),
        ]));
  }

  Widget _buildDispatchQueueItem(Map<String, dynamic> request) {
    final recommendedDriver = request['recommended_driver'];
    final confidenceScore = request['confidence_score'] ?? 0.0;

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            border: Border.all(
                color: _getUrgencyColor(request['urgency']).withAlpha(77),
                width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration:
                    BoxDecoration(color: _getUrgencyColor(request['urgency'])),
                child: Text(
                    request['urgency']?.toString().toUpperCase() ?? 'MEDIUM',
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white))),
            SizedBox(width: 8.w),
            Text(request['service_type']?.toString().toUpperCase() ?? 'TOWING',
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            Text(_getTimeAgo(request['created_at']),
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
          ]),
          SizedBox(height: 8.h),
          Text(request['pickup_address'] ?? 'Unknown location',
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: AppTheme.textPrimaryLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          if (recommendedDriver != null)
            Row(children: [
              Icon(Icons.recommend, size: 16.sp, color: AppTheme.primaryLight),
              SizedBox(width: 4.w),
              Expanded(
                  child: Text(
                      'Recommended: ${recommendedDriver['user_profiles']?['full_name'] ?? 'Unknown'}',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w500))),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                      color:
                          _getConfidenceColor(confidenceScore).withAlpha(26)),
                  child: Text('${(confidenceScore * 100).toInt()}%',
                      style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getConfidenceColor(confidenceScore)))),
            ]),
          SizedBox(height: 8.h),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => _manualAssign(request),
                    child: const Text('Manual Assign'))),
            SizedBox(width: 8.w),
            Expanded(
                child: ElevatedButton(
                    onPressed: recommendedDriver != null
                        ? () => _assignRequest(
                            request['id'], recommendedDriver['id'])
                        : null,
                    child: const Text('Auto Assign'))),
          ]),
        ]));
  }

  Widget _buildDispatchMetrics() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dispatch Performance',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
                child: _buildMetricItem('Avg Assignment Time', '2.3 min',
                    Icons.speed, AppTheme.primaryLight)),
            Expanded(
                child: _buildMetricItem('Assignment Success Rate', '94.2%',
                    Icons.check_circle, AppTheme.successLight)),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
                child: _buildMetricItem('Driver Acceptance Rate', '87.5%',
                    Icons.thumb_up, AppTheme.warningLight)),
            Expanded(
                child: _buildMetricItem('Customer Satisfaction', '4.6/5.0',
                    Icons.star, AppTheme.accentLight)),
          ]),
        ]));
  }

  Widget _buildMetricItem(
      String title, String value, IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(color: color.withAlpha(13)),
        child: Column(children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight)),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10.sp, color: AppTheme.textSecondaryLight),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildMLInsights() {
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
            Icon(Icons.psychology, color: AppTheme.primaryLight, size: 20.sp),
            SizedBox(width: 8.w),
            Text('ML Insights & Predictions',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
          ]),
          SizedBox(height: 12.h),
          _buildInsightItem(
              'Peak demand expected in North zone within 30 minutes',
              Icons.trending_up,
              AppTheme.warningLight),
          _buildInsightItem(
              'Driver efficiency increased by 12% with current algorithm',
              Icons.analytics,
              AppTheme.successLight),
          _buildInsightItem(
              'Recommend positioning 2 drivers near downtown for optimal coverage',
              Icons.location_on,
              AppTheme.primaryLight),
        ]));
  }

  Widget _buildInsightItem(String text, IconData icon, Color color) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(color: color.withAlpha(26)),
              child: Icon(icon, color: color, size: 16.sp)),
          SizedBox(width: 12.w),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13.sp, color: AppTheme.textPrimaryLight))),
        ]));
  }

  Map<String, dynamic>? _findBestDriver(Map<String, dynamic> request) {
    if (widget.availableDrivers.isEmpty) return null;

    // Simple proximity-based recommendation for demo
    return widget.availableDrivers.first;
  }

  double _calculateConfidenceScore(Map<String, dynamic> request) {
    // Mock confidence calculation
    return 0.75 + (DateTime.now().millisecond % 25) / 100;
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

  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return AppTheme.successLight;
    if (score >= 0.6) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final time = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _runAutoDispatch() {
    for (final request in _dispatchQueue) {
      final driver = request['recommended_driver'];
      if (driver != null) {
        _assignRequest(request['id'], driver['id']);
      }
    }
  }

  void _assignRequest(String requestId, String driverId) {
    widget.onRequestAssigned(requestId, driverId);
    setState(() {
      _dispatchQueue.removeWhere((request) => request['id'] == requestId);
    });
  }

  void _manualAssign(Map<String, dynamic> request) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Select Driver for Manual Assignment',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 16.h),
              ...widget.availableDrivers.map((driver) => ListTile(
                  leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(driver['user_profiles']?['full_name']
                              ?.toString()
                              .substring(0, 1)
                              .toUpperCase() ??
                          'D')),
                  title:
                      Text(driver['user_profiles']?['full_name'] ?? 'Unknown'),
                  subtitle: Text(
                      'Rating: ${driver['rating']} • ${driver['total_jobs']} jobs'),
                  onTap: () {
                    Navigator.pop(context);
                    _assignRequest(request['id'], driver['id']);
                  })),
            ])));
  }

  void _showFullQueue() {
    // Implementation for showing full dispatch queue
    debugPrint(
        'Showing full dispatch queue with ${_dispatchQueue.length} items');
  }
}
