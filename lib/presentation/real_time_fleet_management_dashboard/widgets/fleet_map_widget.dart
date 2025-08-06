import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FleetMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> activeRequests;
  final bool showHeatMap;
  final Function(Map<String, dynamic>) onDriverSelected;

  const FleetMapWidget({
    super.key,
    required this.drivers,
    required this.activeRequests,
    required this.showHeatMap,
    required this.onDriverSelected,
  });

  @override
  State<FleetMapWidget> createState() => _FleetMapWidgetState();
}

class _FleetMapWidgetState extends State<FleetMapWidget> {
  String _mapType = 'standard';
  bool _showTraffic = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300.h,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(children: [
          _buildMapHeader(),
          Expanded(
              child: Container(
                  margin: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  child: Stack(children: [
                    // Map placeholder with driver markers
                    Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Icon(Icons.map,
                              size: 48.sp, color: AppTheme.textSecondaryLight),
                          SizedBox(height: 8.h),
                          Text('Interactive Fleet Map',
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondaryLight)),
                          SizedBox(height: 4.h),
                          Text(
                              '${widget.drivers.length} active drivers • ${widget.activeRequests.length} pending requests',
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppTheme.textSecondaryLight)),
                        ])),

                    // Driver markers overlay
                    ...widget.drivers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final driver = entry.value;
                      return Positioned(
                          left: (index * 30.0 + 20).w,
                          top: (index * 25.0 + 40).h,
                          child: GestureDetector(
                              onTap: () => widget.onDriverSelected(driver),
                              child: Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                      color: _getDriverMarkerColor(
                                          driver['current_status']),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withAlpha(51),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2)),
                                      ]),
                                  child: Icon(Icons.local_shipping,
                                      size: 12.sp, color: Colors.white))));
                    }).toList(),

                    // Request markers overlay
                    ...widget.activeRequests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final request = entry.value;
                      return Positioned(
                          right: (index * 35.0 + 30).w,
                          bottom: (index * 30.0 + 50).h,
                          child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                  color: _getRequestMarkerColor(
                                      request['urgency']),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(51),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2)),
                                  ]),
                              child: Icon(Icons.location_on,
                                  size: 10.sp, color: Colors.white)));
                    }).toList(),

                    // Heat map overlay (if enabled)
                    if (widget.showHeatMap)
                      Positioned.fill(
                          child: Container(
                              decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                      center: const Alignment(0.3, -0.4),
                                      radius: 0.8,
                                      colors: [
                            Colors.red.withAlpha(51),
                            Colors.orange.withAlpha(26),
                            Colors.transparent,
                          ])))),
                  ]))),
          _buildMapLegend(),
        ]));
  }

  Widget _buildMapHeader() {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppTheme.borderLight, width: 1))),
        child: Row(children: [
          Text('Fleet Overview Map',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          const Spacer(),
          PopupMenuButton<String>(
              icon: Icon(Icons.layers, size: 20.sp),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'standard', child: Text('Standard')),
                    const PopupMenuItem(
                        value: 'satellite', child: Text('Satellite')),
                    const PopupMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  ],
              onSelected: (value) => setState(() => _mapType = value)),
          IconButton(
              onPressed: () => setState(() => _showTraffic = !_showTraffic),
              icon: Icon(Icons.traffic,
                  size: 20.sp,
                  color: _showTraffic
                      ? AppTheme.primaryLight
                      : AppTheme.textSecondaryLight),
              tooltip: 'Toggle Traffic'),
        ]));
  }

  Widget _buildMapLegend() {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: AppTheme.borderLight, width: 1))),
        child: Row(children: [
          _buildLegendItem('Online', AppTheme.successLight),
          SizedBox(width: 16.w),
          _buildLegendItem('Busy', AppTheme.warningLight),
          SizedBox(width: 16.w),
          _buildLegendItem('Offline', AppTheme.textSecondaryLight),
          const Spacer(),
          _buildLegendItem('High Priority', AppTheme.errorLight),
          SizedBox(width: 16.w),
          _buildLegendItem('Normal', AppTheme.primaryLight),
        ]));
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      SizedBox(width: 4.w),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
    ]);
  }

  Color _getDriverMarkerColor(String? status) {
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

  Color _getRequestMarkerColor(String? urgency) {
    switch (urgency) {
      case 'emergency':
        return AppTheme.errorLight;
      case 'high':
        return AppTheme.accentLight;
      case 'medium':
        return AppTheme.primaryLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
