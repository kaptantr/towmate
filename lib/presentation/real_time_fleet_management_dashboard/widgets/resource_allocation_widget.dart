import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ResourceAllocationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> activeRequests;
  final VoidCallback onResourceAllocated;

  const ResourceAllocationWidget({
    super.key,
    required this.drivers,
    required this.activeRequests,
    required this.onResourceAllocated,
  });

  @override
  State<ResourceAllocationWidget> createState() =>
      _ResourceAllocationWidgetState();
}

class _ResourceAllocationWidgetState extends State<ResourceAllocationWidget> {
  bool _dynamicPricingEnabled = true;
  bool _surgeZoneActive = false;
  double _surgeMultiplier = 1.5;
  String _selectedZone = 'north';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildResourceOverview(),
          SizedBox(height: 16.h),
          _buildDynamicPricing(),
          SizedBox(height: 16.h),
          _buildSurgeZoneManagement(),
          SizedBox(height: 16.h),
          _buildDriverIncentives(),
          SizedBox(height: 16.h),
          _buildMarketAnalysis(),
        ]));
  }

  Widget _buildResourceOverview() {
    final totalDrivers = widget.drivers.length;
    final onlineDrivers =
        widget.drivers.where((d) => d['current_status'] == 'online').length;
    final busyDrivers =
        widget.drivers.where((d) => d['current_status'] == 'busy').length;
    final utilizationRate =
        totalDrivers > 0 ? (busyDrivers / totalDrivers * 100).toDouble() : 0.0;

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Resource Overview',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(
                child: _buildResourceCard(
                    'Total Fleet',
                    totalDrivers.toString(),
                    Icons.local_shipping,
                    AppTheme.primaryLight)),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildResourceCard('Online', onlineDrivers.toString(),
                    Icons.circle, AppTheme.successLight)),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildResourceCard('Busy', busyDrivers.toString(),
                    Icons.work, AppTheme.warningLight)),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildResourceCard(
                    'Utilization',
                    '${utilizationRate.toInt()}%',
                    Icons.analytics,
                    AppTheme.accentLight)),
          ]),
          SizedBox(height: 16.h),
          _buildUtilizationChart(utilizationRate),
        ]));
  }

  Widget _buildResourceCard(
      String title, String value, IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: color.withAlpha(13)),
        child: Column(children: [
          Icon(icon, color: color, size: 20.sp),
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

  Widget _buildUtilizationChart(double utilizationRate) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fleet Utilization Trend',
          style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryLight)),
      SizedBox(height: 8.h),
      Container(
          height: 80.h,
          decoration: BoxDecoration(color: AppTheme.backgroundLight),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Icons.trending_up,
                    size: 32.sp, color: AppTheme.primaryLight),
                Text('Utilization trending upward',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
              ]))),
    ]);
  }

  Widget _buildDynamicPricing() {
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
            Text('Dynamic Pricing',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            Switch(
                value: _dynamicPricingEnabled,
                onChanged: (value) =>
                    setState(() => _dynamicPricingEnabled = value)),
          ]),
          SizedBox(height: 12.h),
          if (_dynamicPricingEnabled) ...[
            Text('Current pricing adjustments based on demand and supply',
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(
                  child: _buildPricingZoneCard(
                      'North Zone', 1.2, AppTheme.successLight)),
              SizedBox(width: 8.w),
              Expanded(
                  child: _buildPricingZoneCard(
                      'South Zone', 1.0, AppTheme.primaryLight)),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(
                  child: _buildPricingZoneCard(
                      'East Zone', 1.8, AppTheme.errorLight)),
              SizedBox(width: 8.w),
              Expanded(
                  child: _buildPricingZoneCard(
                      'West Zone', 1.4, AppTheme.warningLight)),
            ]),
            SizedBox(height: 12.h),
            ElevatedButton(
                onPressed: _adjustPricingRules,
                child: const Text('Adjust Pricing Rules')),
          ] else
            Text('Dynamic pricing is disabled. Using standard rates.',
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildPricingZoneCard(String zone, double multiplier, Color color) {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: color.withAlpha(13),
            border: Border.all(color: color.withAlpha(51))),
        child: Column(children: [
          Text(zone,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 4.h),
          Text('${multiplier}x',
              style: GoogleFonts.inter(
                  fontSize: 16.sp, fontWeight: FontWeight.w700, color: color)),
        ]));
  }

  Widget _buildSurgeZoneManagement() {
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
            Text('Surge Zone Management',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
            const Spacer(),
            Switch(
                value: _surgeZoneActive,
                onChanged: (value) => setState(() => _surgeZoneActive = value)),
          ]),
          SizedBox(height: 12.h),
          if (_surgeZoneActive) ...[
            Row(children: [
              Text('Active Zone:',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
              SizedBox(width: 12.w),
              DropdownButton<String>(
                  value: _selectedZone,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'north', child: Text('North Zone')),
                    DropdownMenuItem(value: 'south', child: Text('South Zone')),
                    DropdownMenuItem(value: 'east', child: Text('East Zone')),
                    DropdownMenuItem(value: 'west', child: Text('West Zone')),
                  ],
                  onChanged: (value) => setState(() => _selectedZone = value!)),
            ]),
            SizedBox(height: 12.h),
            Text('Surge Multiplier: ${_surgeMultiplier}x',
                style: GoogleFonts.inter(
                    fontSize: 14.sp, color: AppTheme.textPrimaryLight)),
            Slider(
                value: _surgeMultiplier,
                min: 1.0,
                max: 3.0,
                divisions: 20,
                label: '${_surgeMultiplier}x',
                onChanged: (value) => setState(() => _surgeMultiplier = value)),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: _deactivateSurge,
                      child: const Text('Deactivate Surge'))),
              SizedBox(width: 12.w),
              Expanded(
                  child: ElevatedButton(
                      onPressed: _applySurgeZone,
                      child: const Text('Apply Surge'))),
            ]),
          ] else
            Text('No active surge zones. Market pricing is normal.',
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildDriverIncentives() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Driver Incentive Programs',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          _buildIncentiveCard('Weekend Bonus', '+\$5 per completed job',
              'Active until Sunday', AppTheme.successLight, true),
          SizedBox(height: 8.h),
          _buildIncentiveCard('Peak Hour Bonus', '+20% earnings 6-9 PM',
              'Auto-triggered', AppTheme.warningLight, true),
          SizedBox(height: 8.h),
          _buildIncentiveCard('High Rating Bonus', '+\$10 for 4.8+ rating',
              'Monthly reward', AppTheme.primaryLight, false),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
              onPressed: _createNewIncentive,
              icon: const Icon(Icons.add),
              label: const Text('Create New Incentive')),
        ]));
  }

  Widget _buildIncentiveCard(String title, String description, String period,
      Color color, bool isActive) {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: isActive ? color.withAlpha(13) : Colors.grey.withAlpha(13),
            border: Border.all(
                color: isActive
                    ? color.withAlpha(51)
                    : Colors.grey.withAlpha(51))),
        child: Row(children: [
          Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey,
                  shape: BoxShape.circle)),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight)),
                Text(description,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(isActive ? 'ACTIVE' : 'INACTIVE',
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey)),
            Text(period,
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
          ]),
        ]));
  }

  Widget _buildMarketAnalysis() {
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
            Icon(Icons.trending_up, color: AppTheme.primaryLight, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Real-time Market Analysis',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
          ]),
          SizedBox(height: 12.h),
          _buildMarketInsight(
              'Demand spike expected in downtown area within 1 hour',
              Icons.location_on,
              AppTheme.warningLight),
          _buildMarketInsight('Current supply/demand ratio: 1.3 (Optimal)',
              Icons.balance, AppTheme.successLight),
          _buildMarketInsight(
              'Weather forecast: Clear skies - Normal demand expected',
              Icons.wb_sunny,
              AppTheme.primaryLight),
          _buildMarketInsight('Competitor pricing: 5% above market average',
              Icons.compare_arrows, AppTheme.accentLight),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
              onPressed: _generateMarketReport,
              icon: const Icon(Icons.analytics),
              label: const Text('Generate Market Report')),
        ]));
  }

  Widget _buildMarketInsight(String text, IconData icon, Color color) {
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

  void _adjustPricingRules() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Adjust Pricing Rules'),
                content: const Text(
                    'Configure dynamic pricing parameters for different zones and time periods.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onResourceAllocated();
                      },
                      child: const Text('Apply Changes')),
                ]));
  }

  void _applySurgeZone() {
    widget.onResourceAllocated();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Surge zone activated: $_selectedZone (${_surgeMultiplier}x)'),
        backgroundColor: AppTheme.successLight));
  }

  void _deactivateSurge() {
    setState(() => _surgeZoneActive = false);
    widget.onResourceAllocated();
  }

  void _createNewIncentive() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Create New Incentive'),
                content: const Text(
                    'Configure new driver incentive program parameters.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onResourceAllocated();
                      },
                      child: const Text('Create')),
                ]));
  }

  void _generateMarketReport() {
    debugPrint('Generating comprehensive market analysis report');
  }
}