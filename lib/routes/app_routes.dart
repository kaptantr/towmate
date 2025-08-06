import 'package:flutter/material.dart';
import '../presentation/driver_matching_and_tracking/driver_matching_and_tracking.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/customer_service_request/customer_service_request.dart';
import '../presentation/driver_dashboard/driver_dashboard.dart';
import '../presentation/payment_management/payment_management_screen.dart';
import '../presentation/driver_registration/driver_registration_screen.dart';
import '../presentation/admin_dashboard/admin_dashboard_screen.dart';
import '../presentation/advanced_notification_center/advanced_notification_center.dart';
import '../presentation/insurance_claim_support_center/insurance_claim_support_center.dart';
import '../presentation/real_time_fleet_management_dashboard/real_time_fleet_management_dashboard.dart';
import '../presentation/multi_service_selection_hub/multi_service_selection_hub.dart';
import '../presentation/enhanced_location_management_system/enhanced_location_management_system.dart';
import '../presentation/comprehensive_admin_control_panel/comprehensive_admin_control_panel.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String driverMatchingAndTracking =
      '/driver-matching-and-tracking';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String profileSettings = '/profile-settings';
  static const String customerServiceRequest = '/customer-service-request';
  static const String driverDashboard = '/driver-dashboard';
  static const String paymentManagement = '/payment-management';
  static const String driverRegistration = '/driver-registration';
  static const String adminDashboard = '/admin-dashboard';
  static const String advancedNotificationCenter =
      '/advanced-notification-center';
  static const String insuranceClaimSupportCenter =
      '/insurance-claim-support-center';
  static const String realTimeFleetManagementDashboard =
      '/real-time-fleet-management-dashboard';
  static const String multiServiceSelectionHub = '/multi-service-selection-hub';
  static const String enhancedLocationManagementSystem =
      '/enhanced-location-management-system';
  static const String comprehensiveAdminControlPanel =
      '/comprehensive-admin-control-panel';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    driverMatchingAndTracking: (context) => DriverMatchingAndTracking(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    profileSettings: (context) => const ProfileSettings(),
    customerServiceRequest: (context) => const CustomerServiceRequest(),
    driverDashboard: (context) => const DriverDashboard(),
    paymentManagement: (context) => const PaymentManagementScreen(),
    driverRegistration: (context) => const DriverRegistrationScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    advancedNotificationCenter: (context) => const AdvancedNotificationCenter(),
    insuranceClaimSupportCenter: (context) =>
        const InsuranceClaimSupportCenter(),
    realTimeFleetManagementDashboard: (context) =>
        const RealTimeFleetManagementDashboard(),
    multiServiceSelectionHub: (context) => const MultiServiceSelectionHub(),
    enhancedLocationManagementSystem: (context) =>
        const EnhancedLocationManagementSystem(),
    comprehensiveAdminControlPanel: (context) =>
        const ComprehensiveAdminControlPanel(),
    // TODO: Add your other routes here
  };
}
