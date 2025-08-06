import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/analytics_overview_card.dart';
import './widgets/description_options_tab.dart';
import './widgets/pricing_control_tab.dart';
import './widgets/quick_action_button.dart';
import './widgets/service_management_tab.dart';
import './widgets/system_settings_tab.dart';

class ComprehensiveAdminControlPanel extends StatefulWidget {
  const ComprehensiveAdminControlPanel({super.key});

  @override
  State<ComprehensiveAdminControlPanel> createState() =>
      _ComprehensiveAdminControlPanelState();
}

class _ComprehensiveAdminControlPanelState
    extends State<ComprehensiveAdminControlPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic> _analyticsData = {};

  final List<String> _tabTitles = [
    'Servis Yönetimi',
    'Fiyat Kontrolü',
    'Açıklama Seçenekleri',
    'Sistem Ayarları',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load analytics data for overview cards
      _analyticsData = {
        'totalServices': 6,
        'activeDrivers': 24,
        'pendingRequests': 12,
        'monthlyRevenue': 45680.50,
        'completedRequests': 1247,
        'averageRating': 4.8,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yüklenirken hata oluştu: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Yönetim Paneli',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Verileri Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/advanced-notification-center');
            },
            tooltip: 'Bildirimler',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.lightTheme.colorScheme.onPrimary,
          labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.7),
          labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Analytics Overview Cards
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistem Durumu',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Aktif Servisler',
                              value:
                                  _analyticsData['totalServices']?.toString() ??
                                      '0',
                              icon: 'build',
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Aktif Sürücüler',
                              value:
                                  _analyticsData['activeDrivers']?.toString() ??
                                      '0',
                              icon: 'local_shipping',
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Bekleyen Talepler',
                              value: _analyticsData['pendingRequests']
                                      ?.toString() ??
                                  '0',
                              icon: 'hourglass_empty',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Aylık Gelir',
                              value:
                                  '₺${(_analyticsData['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
                              icon: 'attach_money',
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Tamamlanan',
                              value: _analyticsData['completedRequests']
                                      ?.toString() ??
                                  '0',
                              icon: 'check_circle',
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: AnalyticsOverviewCard(
                              title: 'Ortalama Puan',
                              value: (_analyticsData['averageRating'] ?? 0.0)
                                  .toStringAsFixed(1),
                              icon: 'star',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                SizedBox(height: 2.h),
                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuickActionButton(
                      icon: 'add',
                      label: 'Yeni Servis',
                      onPressed: () {
                        _tabController.animateTo(0);
                      },
                    ),
                    QuickActionButton(
                      icon: 'price_change',
                      label: 'Fiyat Güncelle',
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                    ),
                    QuickActionButton(
                      icon: 'list_alt',
                      label: 'Açıklamalar',
                      onPressed: () {
                        _tabController.animateTo(2);
                      },
                    ),
                    QuickActionButton(
                      icon: 'settings',
                      label: 'Ayarlar',
                      onPressed: () {
                        _tabController.animateTo(3);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ServiceManagementTab(),
                PricingControlTab(),
                DescriptionOptionsTab(),
                SystemSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/real-time-fleet-management-dashboard');
        },
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
        icon: const Icon(Icons.dashboard),
        label: const Text('Fleet Dashboard'),
      ),
    );
  }
}
