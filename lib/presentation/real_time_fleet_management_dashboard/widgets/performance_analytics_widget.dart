import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PerformanceAnalyticsWidget extends StatefulWidget {
  final Map<String, dynamic> fleetStats;
  final List<Map<String, dynamic>> drivers;
  final VoidCallback onGenerateReport;

  const PerformanceAnalyticsWidget({
    super.key,
    required this.fleetStats,
    required this.drivers,
    required this.onGenerateReport,
  });

  @override
  State<PerformanceAnalyticsWidget> createState() =>
      _PerformanceAnalyticsWidgetState();
}

class _PerformanceAnalyticsWidgetState
    extends State<PerformanceAnalyticsWidget> {
  String _selectedPeriod = 'today';
  String _selectedMetric = 'response_time';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildAnalyticsHeader(),
          SizedBox(height: 16.h),
          _buildKPICards(),
          SizedBox(height: 16.h),
          _buildPerformanceChart(),
          SizedBox(height: 16.h),
          _buildDriverRankings(),
          SizedBox(height: 16.h),
          _buildReportGenerationCard(),
        ]));
  }

  Widget _buildAnalyticsHeader() {
    return Row(children: [
      Text('Performance Analytics',
          style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight)),
      const Spacer(),
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.borderLight)),
          child: DropdownButton<String>(
              value: _selectedPeriod,
              underline: const SizedBox(),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('This Week')),
                DropdownMenuItem(value: 'month', child: Text('This Month')),
                DropdownMenuItem(value: 'quarter', child: Text('This Quarter')),
              ],
              onChanged: (value) => setState(() => _selectedPeriod = value!))),
    ]);
  }

  Widget _buildKPICards() {
    return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
        children: [
          _buildKPICard(
              'Avg Response Time',
              '${widget.fleetStats['avg_response_time'] ?? 12} min',
              Icons.timer,
              AppTheme.primaryLight,
              '+5%',
              true),
          _buildKPICard(
              'Customer Satisfaction',
              '${widget.fleetStats['avg_rating'] ?? 4.5}/5.0',
              Icons.star,
              AppTheme.warningLight,
              '+0.2',
              true),
          _buildKPICard(
              'Fleet Utilization',
              '${widget.fleetStats['utilization_rate'] ?? 78}%',
              Icons.trending_up,
              AppTheme.successLight,
              '+12%',
              true),
          _buildKPICard(
              'Revenue/Driver',
              '\$${widget.fleetStats['revenue_per_driver'] ?? 245}',
              Icons.attach_money,
              AppTheme.accentLight,
              '+8%',
              true),
        ]);
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color,
      String change, bool isPositive) {
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
            Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: color.withAlpha(26)),
                child: Icon(icon, color: color, size: 20.sp)),
            const Spacer(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.successLight.withAlpha(26)
                        : AppTheme.errorLight.withAlpha(26)),
                child: Text(change,
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: isPositive
                            ? AppTheme.successLight
                            : AppTheme.errorLight))),
          ]),
          SizedBox(height: 12.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight)),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildPerformanceChart() {
    return Container(
        height: 200.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Performance Trends',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            DropdownButton<String>(
                value: _selectedMetric,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                      value: 'response_time', child: Text('Response Time')),
                  DropdownMenuItem(
                      value: 'satisfaction', child: Text('Satisfaction')),
                  DropdownMenuItem(value: 'earnings', child: Text('Earnings')),
                ],
                onChanged: (value) => setState(() => _selectedMetric = value!)),
          ]),
          SizedBox(height: 16.h),
          Expanded(
              child: LineChart(LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ];
                                return Text(days[value.toInt() % days.length],
                                    style: GoogleFonts.inter(fontSize: 10.sp));
                              })),
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                LineChartBarData(
                    spots: _getChartData(),
                    isCurved: true,
                    color: AppTheme.primaryLight,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryLight.withAlpha(26))),
              ]))),
        ]));
  }

  Widget _buildDriverRankings() {
    final sortedDrivers = List<Map<String, dynamic>>.from(widget.drivers)
      ..sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Top Performers',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          ...sortedDrivers
              .take(5)
              .map((driver) => _buildDriverRankItem(driver))
              .toList(),
        ]));
  }

  Widget _buildDriverRankItem(Map<String, dynamic> driver) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: AppTheme.primaryLight.withAlpha(26),
              child: Text(
                  driver['user_profiles']?['full_name']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'D',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight))),
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
                    '${driver['total_jobs'] ?? 0} jobs • \$${driver['total_earnings'] ?? 0}',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
              ])),
          Row(children: [
            Icon(Icons.star, color: AppTheme.warningLight, size: 16.sp),
            SizedBox(width: 4.w),
            Text('${driver['rating'] ?? 0.0}',
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
          ]),
        ]));
  }

  Widget _buildReportGenerationCard() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Report Generation',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 8.h),
          Text('Generate comprehensive performance reports for stakeholders',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _generateReport('pdf'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF Report'))),
            SizedBox(width: 12.w),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _generateReport('excel'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel Export'))),
            SizedBox(width: 12.w),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: widget.onGenerateReport,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Full Report'))),
          ]),
        ]));
  }

  List<FlSpot> _getChartData() {
    // Mock data for demonstration
    switch (_selectedMetric) {
      case 'response_time':
        return [
          const FlSpot(0, 15),
          const FlSpot(1, 12),
          const FlSpot(2, 14),
          const FlSpot(3, 10),
          const FlSpot(4, 11),
          const FlSpot(5, 13),
          const FlSpot(6, 9),
        ];
      case 'satisfaction':
        return [
          const FlSpot(0, 4.2),
          const FlSpot(1, 4.4),
          const FlSpot(2, 4.3),
          const FlSpot(3, 4.6),
          const FlSpot(4, 4.5),
          const FlSpot(5, 4.7),
          const FlSpot(6, 4.8),
        ];
      case 'earnings':
        return [
          const FlSpot(0, 200),
          const FlSpot(1, 220),
          const FlSpot(2, 210),
          const FlSpot(3, 240),
          const FlSpot(4, 235),
          const FlSpot(5, 250),
          const FlSpot(6, 245),
        ];
      default:
        return [];
    }
  }

  void _generateReport(String format) {
    debugPrint('Generating $format report for period: $_selectedPeriod');
    // Implementation would include actual report generation logic
  }
}
