import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/admin_service.dart';
import './widgets/quick_action_card.dart';
import './widgets/recent_activity_list.dart';
import './widgets/statistics_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAdmin = await AdminService.instance.isAdmin();

      if (!isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Access denied: Admin privileges required')));
        Navigator.pop(context);
        return;
      }

      setState(() {
        _isAdmin = true;
      });

      _loadDashboardData();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking admin access: $error')));
      Navigator.pop(context);
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final statistics = await AdminService.instance.getSystemStatistics();
      final activities =
          await AdminService.instance.getAdminActivityLogs(limit: 10);

      setState(() {
        _statistics = statistics;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: Text('Admin Dashboard',
                style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            backgroundColor: Colors.indigo[600],
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showDrawer()),
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadDashboardData),
              IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout),
            ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          _buildWelcomeSection(),
                          SizedBox(height: 4.h),

                          // Statistics Cards
                          _buildStatisticsSection(),
                          SizedBox(height: 4.h),

                          // Quick Actions
                          _buildQuickActionsSection(),
                          SizedBox(height: 4.h),

                          // Recent Activities
                          _buildRecentActivitiesSection(),
                        ]))));
  }

  Widget _buildWelcomeSection() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.indigo[600]!, Colors.indigo[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, Admin',
              style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: 1.h),
          Text('Manage your TowMate platform efficiently',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: Colors.white.withAlpha(204))),
          SizedBox(height: 2.h),
          Row(children: [
            CustomIconWidget(iconName: 'status', size: 6.w, color: Colors.white),
            SizedBox(width: 2.w),
            Text('System Status: Online',
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ]),
        ]));
  }

  Widget _buildStatisticsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('System Overview',
          style:
              GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
      SizedBox(height: 2.h),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 3.h,
          childAspectRatio: 1.5,
          children: [
            StatisticsCard(
                title: 'Total Users',
                value: _statistics['total_users']?.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue),
            StatisticsCard(
                title: 'Active Drivers',
                value: _statistics['active_drivers']?.toString() ?? '0',
                icon: Icons.local_shipping,
                color: Colors.green),
            StatisticsCard(
                title: 'Pending Verifications',
                value: _statistics['pending_verifications']?.toString() ?? '0',
                icon: Icons.pending_actions,
                color: Colors.orange),
            StatisticsCard(
                title: 'Total Revenue',
                value:
                    '₺${(_statistics['total_revenue'] ?? 0.0).toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.purple),
            StatisticsCard(
                title: 'Service Requests',
                value: _statistics['total_requests']?.toString() ?? '0',
                icon: Icons.assignment,
                color: Colors.teal),
            StatisticsCard(
                title: 'Completion Rate',
                value:
                    '${(_statistics['completion_rate'] ?? 0.0).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: Colors.indigo),
          ]),
    ]);
  }

  Widget _buildQuickActionsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions',
          style:
              GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
      SizedBox(height: 2.h),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 3.h,
          childAspectRatio: 1.2,
          children: [
            QuickActionCard(
                title: 'User Management',
                icon: Icons.people_outline,
                color: Colors.blue,
                onTap: () => _navigateToUserManagement()),
            QuickActionCard(
                title: 'Driver Verification',
                icon: Icons.verified_user,
                color: Colors.green,
                onTap: () => _navigateToDriverVerification()),
            QuickActionCard(
                title: 'Payment Management',
                icon: Icons.payment,
                color: Colors.purple,
                onTap: () => _navigateToPaymentManagement()),
            QuickActionCard(
                title: 'System Settings',
                icon: Icons.settings,
                color: Colors.orange,
                onTap: () => _navigateToSystemSettings()),
            QuickActionCard(
                title: 'Export Data',
                icon: Icons.download,
                color: Colors.teal,
                onTap: () => _showExportDialog()),
            QuickActionCard(
                title: 'Activity Logs',
                icon: Icons.history,
                color: Colors.indigo,
                onTap: () => _navigateToActivityLogs()),
          ]),
    ]);
  }

  Widget _buildRecentActivitiesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Activities',
            style: GoogleFonts.inter(
                fontSize: 18.sp, fontWeight: FontWeight.w600)),
        TextButton(
            onPressed: () => _navigateToActivityLogs(),
            child: Text('View All',
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.indigo[600],
                    fontWeight: FontWeight.w500))),
      ]),
      SizedBox(height: 2.h),
      RecentActivityList(activities: _recentActivities),
    ]);
  }

  void _showDrawer() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
            padding: EdgeInsets.all(6.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () => Navigator.pop(context)),
              ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('User Management'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserManagement();
                  }),
              ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Driver Verification'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToDriverVerification();
                  }),
              ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Management'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPaymentManagement();
                  }),
              ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('System Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSystemSettings();
                  }),
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  }),
            ])));
  }

  void _navigateToUserManagement() {
    // Placeholder for user management screen navigation
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Management feature coming soon')));
  }

  void _navigateToDriverVerification() {
    // Placeholder for driver verification screen navigation
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Driver Verification feature coming soon')));
  }

  void _navigateToPaymentManagement() {
    // Placeholder for payment management screen navigation
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment Management feature coming soon')));
  }

  void _navigateToSystemSettings() {
    // Placeholder for system settings screen navigation
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System Settings feature coming soon')));
  }

  void _navigateToActivityLogs() {
    // Placeholder for activity logs screen navigation
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity Logs feature coming soon')));
  }

  void _showExportDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Export Data'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Export Users'),
                      onTap: () => _exportData('users')),
                  ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: const Text('Export Drivers'),
                      onTap: () => _exportData('drivers')),
                  ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Export Payments'),
                      onTap: () => _exportData('payments')),
                  ListTile(
                      leading: const Icon(Icons.assignment),
                      title: const Text('Export Service Requests'),
                      onTap: () => _exportData('requests')),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                ]));
  }

  Future<void> _exportData(String dataType) async {
    Navigator.pop(context); // Close dialog

    try {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exporting $dataType data...')));

      final csvData = await AdminService.instance.exportData(
          dataType: dataType,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now());

      // In a real app, you would save the CSV file or offer download
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${dataType.toUpperCase()} data exported successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  void _logout() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (route) => false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout',
                          style: TextStyle(color: Colors.white))),
                ]));
  }
}