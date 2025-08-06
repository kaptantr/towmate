import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import './widgets/automated_dispatch_panel_widget.dart';
import './widgets/communication_center_widget.dart';
import './widgets/driver_status_card_widget.dart';
import './widgets/fleet_map_widget.dart';
import './widgets/performance_analytics_widget.dart';
import './widgets/quality_assurance_widget.dart';
import './widgets/resource_allocation_widget.dart';

class RealTimeFleetManagementDashboard extends StatefulWidget {
  const RealTimeFleetManagementDashboard({super.key});

  @override
  State<RealTimeFleetManagementDashboard> createState() =>
      _RealTimeFleetManagementDashboardState();
}

class _RealTimeFleetManagementDashboardState
    extends State<RealTimeFleetManagementDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  // Real-time data
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _activeRequests = [];
  Map<String, dynamic> _fleetStats = {};
  bool _isLoading = true;

  // Filter states
  String _selectedStatus = 'all';
  String _selectedRegion = 'all';
  bool _showHeatMap = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadFleetData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadFleetData();
    });
  }

  Future<void> _loadFleetData() async {
    try {
      final supabase = SupabaseService.instance.client;

      // Load active drivers with their current status and location
      final driversResponse = await supabase
          .from('driver_profiles')
          .select('''
            *,
            user_profiles(full_name, phone_number, profile_picture_url)
          ''')
          .eq('is_available', true)
          .order('last_location_update', ascending: false);

      // Load active service requests
      final requestsResponse = await supabase
          .from('service_requests')
          .select('''
            *,
            user_profiles(full_name, phone_number),
            driver_profiles(user_profiles(full_name))
          ''').inFilter('status', [
        'pending',
        'accepted',
        'in_progress'
      ]).order('created_at', ascending: false);

      // Calculate fleet statistics
      final statsResponse = await supabase.rpc('get_fleet_statistics');

      if (mounted) {
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(driversResponse);
          _activeRequests = List<Map<String, dynamic>>.from(requestsResponse);
          _fleetStats = statsResponse ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading fleet data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _isLoading
            ? _buildLoadingState()
            : Column(children: [
                _buildQuickStats(),
                _buildFilterBar(),
                Expanded(
                    child: TabBarView(controller: _tabController, children: [
                  _buildFleetOverviewTab(),
                  _buildDispatchTab(),
                  _buildAnalyticsTab(),
                  _buildResourceTab(),
                  _buildCommunicationTab(),
                  _buildQualityTab(),
                ])),
              ]));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        title: Text('Fleet Management Dashboard',
            style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        backgroundColor: AppTheme.primaryLight,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _loadFleetData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Data'),
          IconButton(
              onPressed: () => _showSettingsMenu(context),
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'Dashboard Settings'),
        ],
        bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Fleet Overview'),
              Tab(text: 'Auto Dispatch'),
              Tab(text: 'Analytics'),
              Tab(text: 'Resources'),
              Tab(text: 'Communication'),
              Tab(text: 'QA Monitor'),
            ]));
  }

  Widget _buildLoadingState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: AppTheme.primaryLight),
      SizedBox(height: 16.h),
      Text('Loading fleet data...',
          style: GoogleFonts.inter(
              fontSize: 16.sp, color: AppTheme.textSecondaryLight)),
    ]));
  }

  Widget _buildQuickStats() {
    return Container(
        padding: EdgeInsets.all(16.w),
        child: Row(children: [
          Expanded(
              child: _buildStatCard(
                  'Active Drivers',
                  _drivers
                      .where((d) => d['current_status'] == 'online')
                      .length
                      .toString(),
                  Icons.local_shipping,
                  AppTheme.successLight)),
          SizedBox(width: 12.w),
          Expanded(
              child: _buildStatCard(
                  'Pending Requests',
                  _activeRequests
                      .where((r) => r['status'] == 'pending')
                      .length
                      .toString(),
                  Icons.pending_actions,
                  AppTheme.warningLight)),
          SizedBox(width: 12.w),
          Expanded(
              child: _buildStatCard(
                  'In Progress',
                  _activeRequests
                      .where((r) => r['status'] == 'in_progress')
                      .length
                      .toString(),
                  Icons.timeline,
                  AppTheme.primaryLight)),
          SizedBox(width: 12.w),
          Expanded(
              child: _buildStatCard(
                  'Avg Response',
                  '${_fleetStats['avg_response_time'] ?? 12}min',
                  Icons.timer,
                  AppTheme.accentLight)),
        ]));
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 20.sp),
            const Spacer(),
            Container(
                width: 8.w,
                height: 8.h,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
          ]),
          SizedBox(height: 8.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight)),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondaryLight)),
        ]));
  }

  Widget _buildFilterBar() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(children: [
          _buildFilterChip(
              'Status', _selectedStatus, ['all', 'online', 'busy', 'offline'],
              (value) {
            setState(() => _selectedStatus = value);
          }),
          SizedBox(width: 12.w),
          _buildFilterChip('Region', _selectedRegion,
              ['all', 'north', 'south', 'east', 'west'], (value) {
            setState(() => _selectedRegion = value);
          }),
          const Spacer(),
          IconButton(
              onPressed: () => setState(() => _showHeatMap = !_showHeatMap),
              icon: Icon(_showHeatMap ? Icons.map : Icons.map_outlined,
                  color: _showHeatMap
                      ? AppTheme.primaryLight
                      : AppTheme.textSecondaryLight),
              tooltip: 'Toggle Heat Map'),
        ]));
  }

  Widget _buildFilterChip(String label, String value, List<String> options,
      Function(String) onChanged) {
    return PopupMenuButton<String>(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderLight)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('$label: ${value.toUpperCase()}',
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryLight)),
              SizedBox(width: 4.w),
              const Icon(Icons.arrow_drop_down, size: 16),
            ])),
        itemBuilder: (context) => options
            .map((option) =>
                PopupMenuItem(value: option, child: Text(option.toUpperCase())))
            .toList(),
        onSelected: onChanged);
  }

  Widget _buildFleetOverviewTab() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Interactive Map Section
          FleetMapWidget(
              drivers: _drivers,
              activeRequests: _activeRequests,
              showHeatMap: _showHeatMap,
              onDriverSelected: _onDriverSelected),
          SizedBox(height: 16.h),

          // Active Drivers Grid
          Text('Active Drivers',
              style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.2),
              itemCount: _drivers.length,
              itemBuilder: (context, index) {
                return DriverStatusCardWidget(
                    driver: _drivers[index],
                    onTap: () => _onDriverSelected(_drivers[index]));
              }),
        ]));
  }

  Widget _buildDispatchTab() {
    return AutomatedDispatchPanelWidget(
        activeRequests: _activeRequests,
        availableDrivers:
            _drivers.where((d) => d['current_status'] == 'online').toList(),
        onRequestAssigned: _onRequestAssigned);
  }

  Widget _buildAnalyticsTab() {
    return PerformanceAnalyticsWidget(
        fleetStats: _fleetStats,
        drivers: _drivers,
        onGenerateReport: _onGenerateReport);
  }

  Widget _buildResourceTab() {
    return ResourceAllocationWidget(
        drivers: _drivers,
        activeRequests: _activeRequests,
        onResourceAllocated: _onResourceAllocated);
  }

  Widget _buildCommunicationTab() {
    return CommunicationCenterWidget(
        drivers: _drivers,
        onMessageSent: _onMessageSent,
        onEmergencyAlert: _onEmergencyAlert);
  }

  Widget _buildQualityTab() {
    return QualityAssuranceWidget(
        activeRequests: _activeRequests,
        drivers: _drivers,
        onQualityCheck: _onQualityCheck);
  }

  void _onDriverSelected(Map<String, dynamic> driver) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildDriverDetailSheet(driver));
  }

  Widget _buildDriverDetailSheet(Map<String, dynamic> driver) {
    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(top: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                Expanded(
                    child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Driver Header
                              Row(children: [
                                CircleAvatar(
                                    backgroundColor: AppTheme.primaryLight,
                                    child: Text(
                                        driver['user_profiles']?['full_name']
                                                ?.toString()
                                                .substring(0, 1)
                                                .toUpperCase() ??
                                            'D',
                                        style: GoogleFonts.inter(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white))),
                                SizedBox(width: 16.w),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                          driver['user_profiles']
                                                  ?['full_name'] ??
                                              'Unknown Driver',
                                          style: GoogleFonts.inter(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppTheme.textPrimaryLight)),
                                      Text(
                                          '${driver['vehicle_make']} ${driver['vehicle_model']} (${driver['vehicle_year']})',
                                          style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              color:
                                                  AppTheme.textSecondaryLight)),
                                      Row(children: [
                                        Container(
                                            width: 8.w,
                                            height: 8.h,
                                            decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    driver['current_status']),
                                                shape: BoxShape.circle)),
                                        SizedBox(width: 4.w),
                                        Text(
                                            driver['current_status']
                                                    ?.toString()
                                                    .toUpperCase() ??
                                                'UNKNOWN',
                                            style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: _getStatusColor(
                                                    driver['current_status']))),
                                      ]),
                                    ])),
                              ]),
                              SizedBox(height: 24.h),

                              // Driver Stats
                              _buildDriverStatRow(
                                  'Rating', '${driver['rating'] ?? 0.0}/5.0'),
                              _buildDriverStatRow(
                                  'Total Jobs', '${driver['total_jobs'] ?? 0}'),
                              _buildDriverStatRow('Total Earnings',
                                  '\$${driver['total_earnings'] ?? 0}'),
                              _buildDriverStatRow('License Plate',
                                  driver['license_plate'] ?? 'N/A'),
                              _buildDriverStatRow(
                                  'Vehicle Type',
                                  driver['vehicle_type']
                                          ?.toString()
                                          .toUpperCase() ??
                                      'N/A'),

                              SizedBox(height: 24.h),

                              // Action Buttons
                              Row(children: [
                                Expanded(
                                    child: ElevatedButton.icon(
                                        onPressed: () => _contactDriver(driver),
                                        icon: const Icon(Icons.phone),
                                        label: const Text('Call Driver'))),
                                SizedBox(width: 12.w),
                                Expanded(
                                    child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _sendMessageToDriver(driver),
                                        icon: const Icon(Icons.message),
                                        label: const Text('Send Message'))),
                              ]),
                            ]))),
              ]));
        });
  }

  Widget _buildDriverStatRow(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight)),
        ]));
  }

  Color _getStatusColor(String? status) {
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

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Auto Refresh Settings'),
                  onTap: () => Navigator.pop(context)),
              ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Alert Preferences'),
                  onTap: () => Navigator.pop(context)),
              ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Dashboard Data'),
                  onTap: () => Navigator.pop(context)),
            ])));
  }

  void _onRequestAssigned(String requestId, String driverId) {
    // Handle automated dispatch assignment
    debugPrint('Request $requestId assigned to driver $driverId');
    _loadFleetData(); // Refresh data
  }

  void _onGenerateReport() {
    // Handle performance report generation
    debugPrint('Generating performance report');
  }

  void _onResourceAllocated() {
    // Handle resource allocation changes
    debugPrint('Resource allocation updated');
    _loadFleetData();
  }

  void _onMessageSent(String message, List<String> driverIds) {
    // Handle broadcast messaging
    debugPrint('Message sent to ${driverIds.length} drivers: $message');
  }

  void _onEmergencyAlert(String alert) {
    // Handle emergency alerts
    debugPrint('Emergency alert sent: $alert');
  }

  void _onQualityCheck(String requestId, Map<String, dynamic> checkData) {
    // Handle quality assurance checks
    debugPrint('Quality check completed for request $requestId');
  }

  void _contactDriver(Map<String, dynamic> driver) {
    // Implementation for calling driver
    debugPrint('Calling driver: ${driver['user_profiles']?['phone_number']}');
  }

  void _sendMessageToDriver(Map<String, dynamic> driver) {
    // Implementation for messaging driver
    debugPrint('Sending message to driver: ${driver['id']}');
  }
}