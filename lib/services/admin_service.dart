import 'package:flutter/material.dart';

import './supabase_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();
  static AdminService get instance => _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      final response = await _supabaseService.client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'admin';
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Get system statistics for admin dashboard
  Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      final stats = <String, dynamic>{};

      // Get cached statistics first
      final cachedStats = await _supabaseService.client
          .from('admin_system_statistics')
          .select('*')
          .eq('stat_date', DateTime.now().toIso8601String().split('T')[0]);

      // Convert cached stats to map
      for (final stat in cachedStats) {
        stats[stat['stat_name']] = stat['stat_value'];
      }

      // If no cached stats, calculate fresh ones
      if (cachedStats.isEmpty) {
        // Total users
        final usersCount = await _supabaseService.client
            .from('user_profiles')
            .select('id')
            .count();
        stats['total_users'] = usersCount.count ?? 0;

        // Active drivers (online or available)
        final activeDriversCount = await _supabaseService.client
            .from('driver_profiles')
            .select('id')
            .or('current_status.eq.online,is_available.eq.true')
            .count();
        stats['active_drivers'] = activeDriversCount.count ?? 0;

        // Pending verifications (drivers not verified)
        final pendingVerifications = await _supabaseService.client
            .from('user_profiles')
            .select('id')
            .eq('role', 'driver')
            .eq('is_verified', false)
            .count();
        stats['pending_verifications'] = pendingVerifications.count ?? 0;

        // Total revenue from payments
        final revenueResult = await _supabaseService.client
            .from('payments')
            .select('amount')
            .eq('payment_status', 'completed');

        double totalRevenue = 0.0;
        for (final payment in revenueResult) {
          totalRevenue += (payment['amount']?.toDouble() ?? 0.0);
        }
        stats['total_revenue'] = totalRevenue;

        // Total service requests
        final requestsCount = await _supabaseService.client
            .from('service_requests')
            .select('id')
            .count();
        stats['total_requests'] = requestsCount.count ?? 0;

        // Completion rate
        final completedCount = await _supabaseService.client
            .from('service_requests')
            .select('id')
            .eq('status', 'completed')
            .count();

        final totalRequests = requestsCount.count ?? 0;
        final completedRequests = completedCount.count ?? 0;

        stats['completion_rate'] =
            totalRequests > 0 ? (completedRequests / totalRequests * 100) : 0.0;

        // Cache the calculated statistics
        await _cacheStatistics(stats);
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting system statistics: $e');
      return {
        'total_users': 0,
        'active_drivers': 0,
        'pending_verifications': 0,
        'total_revenue': 0.0,
        'total_requests': 0,
        'completion_rate': 0.0,
      };
    }
  }

  // Cache statistics in database
  Future<void> _cacheStatistics(Map<String, dynamic> stats) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      for (final entry in stats.entries) {
        await _supabaseService.client.from('admin_system_statistics').upsert({
          'stat_name': entry.key,
          'stat_value': entry.value,
          'stat_date': today,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error caching statistics: $e');
    }
  }

  // Get admin activity logs
  Future<List<Map<String, dynamic>>> getAdminActivityLogs(
      {int limit = 50}) async {
    try {
      final response =
          await _supabaseService.client.from('admin_activity_logs').select('''
            *,
            admin_user:user_profiles!admin_user_id(
              full_name,
              email
            )
          ''').order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting admin activity logs: $e');
      return [];
    }
  }

  // Log admin activity
  Future<void> logAdminActivity({
    required String action,
    String? description,
    String? affectedEntityType,
    String? affectedEntityId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return;

      await _supabaseService.client.from('admin_activity_logs').insert({
        'admin_user_id': user.id,
        'action': action,
        'description': description,
        'affected_entity_type': affectedEntityType,
        'affected_entity_id': affectedEntityId,
        'ip_address': ipAddress,
        'user_agent': userAgent,
      });
    } catch (e) {
      debugPrint('Error logging admin activity: $e');
    }
  }

  // Export data as CSV
  Future<String> exportData({
    required String dataType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<Map<String, dynamic>> data = [];

      switch (dataType) {
        case 'users':
          data = await _exportUsers(startDate, endDate);
          break;
        case 'drivers':
          data = await _exportDrivers(startDate, endDate);
          break;
        case 'payments':
          data = await _exportPayments(startDate, endDate);
          break;
        case 'requests':
          data = await _exportServiceRequests(startDate, endDate);
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }

      // Convert to CSV format
      return _convertToCSV(data);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      throw Exception('Failed to export data: $e');
    }
  }

  // Export users data
  Future<List<Map<String, dynamic>>> _exportUsers(
      DateTime? startDate, DateTime? endDate) async {
    var query = _supabaseService.client
        .from('user_profiles')
        .select('id, email, full_name, role, is_verified, created_at');

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    return await query.order('created_at', ascending: false);
  }

  // Export drivers data
  Future<List<Map<String, dynamic>>> _exportDrivers(
      DateTime? startDate, DateTime? endDate) async {
    var query = _supabaseService.client.from('driver_profiles').select('''
          *,
          user_profiles!inner(
            email,
            full_name,
            created_at
          )
        ''');

    if (startDate != null) {
      query =
          query.gte('user_profiles.created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('user_profiles.created_at', endDate.toIso8601String());
    }

    return await query.order('created_at', ascending: false);
  }

  // Export payments data
  Future<List<Map<String, dynamic>>> _exportPayments(
      DateTime? startDate, DateTime? endDate) async {
    var query = _supabaseService.client.from('payments').select('''
          *,
          customer:user_profiles!customer_id(
            full_name,
            email
          )
        ''');

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    return await query.order('created_at', ascending: false);
  }

  // Export service requests data
  Future<List<Map<String, dynamic>>> _exportServiceRequests(
      DateTime? startDate, DateTime? endDate) async {
    var query = _supabaseService.client.from('service_requests').select('''
          *,
          customer:user_profiles!customer_id(
            full_name,
            email
          )
        ''');

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    return await query.order('created_at', ascending: false);
  }

  // Convert data to CSV format
  String _convertToCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';

    // Get headers from first row
    final headers = data.first.keys.toList();

    // Create CSV content
    final csvContent = StringBuffer();

    // Add headers
    csvContent.writeln(headers.join(','));

    // Add data rows
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // Escape commas and quotes
        if (value.contains(',') || value.contains('"')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).toList();

      csvContent.writeln(values.join(','));
    }

    return csvContent.toString();
  }

  // Manage service configurations
  Future<List<Map<String, dynamic>>> getServiceConfigurations() async {
    try {
      final response = await _supabaseService.client
          .from('admin_service_configurations')
          .select('*')
          .order('service_type');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting service configurations: $e');
      return [];
    }
  }

  // Update service configuration
  Future<bool> updateServiceConfiguration(
      String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.client
          .from('admin_service_configurations')
          .update(data)
          .eq('id', id);

      // Log the activity
      await logAdminActivity(
        action: 'update_service_config',
        description:
            'Updated service configuration for ${data['service_type']}',
        affectedEntityType: 'service_configuration',
        affectedEntityId: id,
      );

      return true;
    } catch (e) {
      debugPrint('Error updating service configuration: $e');
      return false;
    }
  }

  // Update user verification status
  Future<bool> updateUserVerification(String userId, bool isVerified) async {
    try {
      await _supabaseService.client.from('user_profiles').update({
        'is_verified': isVerified,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Log the activity
      await logAdminActivity(
        action: 'update_verification',
        description: '${isVerified ? 'Verified' : 'Unverified'} user',
        affectedEntityType: 'user_profile',
        affectedEntityId: userId,
      );

      return true;
    } catch (e) {
      debugPrint('Error updating user verification: $e');
      return false;
    }
  }

  // Get pending driver verifications
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final response = await _supabaseService.client
          .from('user_profiles')
          .select('''
            *,
            driver_profiles!inner(
              vehicle_make,
              vehicle_model,
              license_plate,
              license_number,
              insurance_number
            )
          ''')
          .eq('role', 'driver')
          .eq('is_verified', false)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting pending verifications: $e');
      return [];
    }
  }
}
