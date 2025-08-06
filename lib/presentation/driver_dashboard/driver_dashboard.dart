import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_service.dart';
import '../../services/service_request_service.dart';
import './widgets/active_job_card_widget.dart';
import './widgets/driver_stats_widget.dart';
import './widgets/driver_status_toggle_widget.dart';
import './widgets/earnings_summary_widget.dart';
import './widgets/incoming_request_card_widget.dart';
import './widgets/map_tracking_widget.dart';
import './widgets/quick_actions_widget.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Driver state variables
  bool _isOnline = false;
  bool _hasIncomingRequest = false;
  bool _hasActiveJob = false;
  bool _isLocationTracking = false;

  // Mock data for driver (will be replaced with real data)
  Map<String, dynamic> _driverProfile = {
    'name': 'Mehmet Yılmaz',
    'rating': 4.8,
    'completedJobs': 247,
    'vehicleType': 'Ağır Çekici',
    'licensePlate': '34 ABC 123',
    'profileImage':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
  };

  Map<String, dynamic> _todayEarnings = {
    'totalEarnings': 850.0,
    'completedJobs': 5,
    'averageJobValue': 170.0,
    'tip': 75.0,
    'bonuses': 25.0,
  };

  Map<String, dynamic> _weeklyStats = {
    'totalEarnings': 4250.0,
    'completedJobs': 23,
    'rating': 4.8,
    'onlineHours': 42.5,
  };

  Map<String, dynamic>? _incomingRequest;
  Map<String, dynamic>? _activeJob;
  List<Map<String, dynamic>> _availableRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeServices();
    _loadDriverData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    // Initialize location service
    bool locationInitialized = await LocationService.instance.initialize();
    if (locationInitialized) {
      setState(() {
        _isLocationTracking = true;
      });
    }
  }

  Future<void> _loadDriverData() async {
    try {
      // Load real earnings data
      final earnings = await ServiceRequestService.instance.getDriverEarnings();
      if (earnings.isNotEmpty) {
        setState(() {
          _todayEarnings['totalEarnings'] = earnings['today_earnings'] ?? 0.0;
          _weeklyStats['totalEarnings'] = earnings['week_earnings'] ?? 0.0;
        });
      }

      // Load available requests
      _loadAvailableRequests();

      // Load active jobs
      _loadActiveJobs();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadAvailableRequests() async {
    try {
      final requests =
          await ServiceRequestService.instance.getAvailableRequests();
      setState(() {
        _availableRequests = requests;
        if (requests.isNotEmpty && _isOnline && !_hasActiveJob) {
          _incomingRequest = requests.first;
          _hasIncomingRequest = true;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadActiveJobs() async {
    try {
      final activeJobs =
          await ServiceRequestService.instance.getDriverActiveRequests();
      if (activeJobs.isNotEmpty) {
        setState(() {
          _activeJob = activeJobs.first;
          _hasActiveJob = true;
          _hasIncomingRequest = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _toggleOnlineStatus(bool value) async {
    setState(() {
      _isOnline = value;
      if (!_isOnline) {
        _hasIncomingRequest = false;
      }
    });

    if (_isOnline && _isLocationTracking) {
      // Start location tracking
      LocationService.instance
          .startLocationTracking()
          .listen((Position position) {
        LocationService.instance.updateDriverLocation(position);
      });

      // Load available requests
      _loadAvailableRequests();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline
              ? 'Çevrimiçi oldunuz - Talep almaya hazırsınız!'
              : 'Çevrimdışı oldunuz',
        ),
        backgroundColor: _isOnline
            ? AppTheme.lightTheme.colorScheme.tertiary
            : AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _acceptRequest() async {
    if (_incomingRequest != null) {
      bool success = await ServiceRequestService.instance
          .acceptServiceRequest(_incomingRequest!['id']);

      if (success) {
        setState(() {
          _activeJob = _incomingRequest;
          _hasIncomingRequest = false;
          _hasActiveJob = true;
          _incomingRequest = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Talep kabul edildi! Müşteri konumuna yönlendiriliyorsunuz.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            action: SnackBarAction(
              label: 'Navigasyon',
              onPressed: () {
                // Navigation will be handled by the map widget
              },
            ),
          ),
        );
      }
    }
  }

  void _rejectRequest() {
    setState(() {
      _hasIncomingRequest = false;
      _incomingRequest = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Talep reddedildi'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );

    // Load next available request
    if (_isOnline) {
      _loadAvailableRequests();
    }
  }

  void _completeJob() async {
    if (_activeJob != null) {
      bool success = await ServiceRequestService.instance
          .updateRequestStatus(_activeJob!['id'], 'completed');

      if (success) {
        setState(() {
          _hasActiveJob = false;
          _activeJob = null;
          _todayEarnings['totalEarnings'] +=
              (_activeJob?['estimated_price'] ?? 0.0);
          _todayEarnings['completedJobs']++;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'İş tamamlandı! ${_activeJob?['estimated_price'] ?? 0}₺ kazandınız.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );

        // Load next available request
        if (_isOnline) {
          _loadAvailableRequests();
        }
      }
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Driver Status Toggle
          DriverStatusToggleWidget(
            isOnline: _isOnline,
            onToggle: _toggleOnlineStatus,
            driverName: _driverProfile['name'],
            vehicleType: _driverProfile['vehicleType'],
            licensePlate: _driverProfile['licensePlate'],
          ),

          // Incoming Request Card (if available)
          if (_hasIncomingRequest && !_hasActiveJob && _incomingRequest != null)
            IncomingRequestCardWidget(
              request: _incomingRequest!,
              onAccept: _acceptRequest,
              onReject: _rejectRequest,
            ),

          // Active Job Card (if available)
          if (_hasActiveJob && _activeJob != null)
            ActiveJobCardWidget(
              job: _activeJob!,
              onComplete: () => _completeJob(),
              onCallCustomer: () {
                // Handle call customer
              },
              onNavigate: () {
                // Navigation handled by map widget
              },
            ),

          // Today's Earnings Summary
          EarningsSummaryWidget(earnings: _todayEarnings),

          // Quick Actions
          QuickActionsWidget(),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return MapTrackingWidget(
      activeJob: _activeJob,
      onLocationUpdate: (position) {
        // Handle location updates
      },
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Today's Earnings Detail
          Container(
            margin: EdgeInsets.all(4.w),
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
                  'Bugünkü Kazançlar',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEarningItem(
                        'Toplam Kazanç',
                        '${_todayEarnings['totalEarnings']}₺',
                        Icons.account_balance_wallet),
                    _buildEarningItem(
                        'Tamamlanan İş',
                        '${_todayEarnings['completedJobs']}',
                        Icons.check_circle),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEarningItem('Bahşiş', '${_todayEarnings['tip']}₺',
                        Icons.volunteer_activism),
                    _buildEarningItem(
                        'Bonus', '${_todayEarnings['bonuses']}₺', Icons.star),
                  ],
                ),
              ],
            ),
          ),

          // Weekly Stats
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
                  'Haftalık İstatistikler',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEarningItem('Haftalık Kazanç',
                        '${_weeklyStats['totalEarnings']}₺', Icons.trending_up),
                    _buildEarningItem(
                        'Tamamlanan İş',
                        '${_weeklyStats['completedJobs']}',
                        Icons.assignment_turned_in),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEarningItem('Çevrimiçi Saat',
                        '${_weeklyStats['onlineHours']}', Icons.access_time),
                    _buildEarningItem('Ortalama Puan',
                        '${_weeklyStats['rating']}', Icons.star),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildEarningItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DriverStatsWidget(
            stats: _weeklyStats,
            profile: _driverProfile,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            margin: EdgeInsets.all(4.w),
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
              children: [
                CircleAvatar(
                  radius: 8.w,
                  backgroundImage: NetworkImage(_driverProfile['profileImage']),
                ),
                SizedBox(height: 2.h),
                Text(
                  _driverProfile['name'],
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${_driverProfile['rating']} (${_driverProfile['completedJobs']} iş)',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '${_driverProfile['vehicleType']} - ${_driverProfile['licensePlate']}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Profile Options
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
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
              children: [
                _buildProfileOption('Profil Bilgileri', Icons.person, () {}),
                _buildProfileOption(
                    'Araç Bilgileri', Icons.local_shipping, () {}),
                _buildProfileOption('Belgeler', Icons.description, () {}),
                _buildProfileOption('Ödeme Bilgileri', Icons.payment, () {}),
                _buildProfileOption('Bildirimler', Icons.notifications, () {}),
                _buildProfileOption('Destek', Icons.support_agent, () {}),
                _buildProfileOption('Çıkış Yap', Icons.logout, () {},
                    isLast: true),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap,
      {bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'TowMate Sürücü',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          // Notification icon
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 24,
                ),
                if (_hasIncomingRequest)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: AppTheme.lightTheme.colorScheme.onPrimary,
          indicatorWeight: 3,
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Ana Sayfa'),
            Tab(text: 'Harita'),
            Tab(text: 'Kazançlar'),
            Tab(text: 'İstatistik'),
            Tab(text: 'Profil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildMapTab(),
          _buildEarningsTab(),
          _buildStatsTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }
}
