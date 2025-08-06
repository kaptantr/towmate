import 'package:flutter/material.dart';
import 'dart:math' as math;

import './supabase_service.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();
  static DriverService get instance => _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;

  // Check if current user is a driver
  Future<bool> isDriver() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      final response = await _supabaseService.client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] == 'driver';
    } catch (e) {
      debugPrint('Error checking driver status: $e');
      return false;
    }
  }

  // Get driver profile
  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _supabaseService.client.from('driver_profiles').select('''
            *,
            user_profiles!inner(
              full_name,
              email,
              phone,
              profile_image_url
            )
          ''').eq('user_id', user.id).single();

      return response;
    } catch (e) {
      debugPrint('Error getting driver profile: $e');
      return null;
    }
  }

  // Update driver status (online/offline/busy/break)
  Future<bool> updateDriverStatus(String status, {bool? isAvailable}) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      final updateData = {
        'current_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isAvailable != null) {
        updateData['is_available'] = isAvailable.toString();
      }

      await _supabaseService.client
          .from('driver_profiles')
          .update(updateData)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error updating driver status: $e');
      return false;
    }
  }

  // Update driver location
  Future<bool> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      await _supabaseService.client.from('driver_profiles').update({
        'current_latitude': latitude,
        'current_longitude': longitude,
        'last_location_update': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error updating driver location: $e');
      return false;
    }
  }

  // Get driver earnings for a specific period
  Future<Map<String, dynamic>> getDriverEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get driver profile first
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      // Build query
      var query = _supabaseService.client
          .from('driver_earnings')
          .select('*')
          .eq('driver_id', driverId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final earnings = await query.order('date', ascending: false);

      double totalAmount = 0.0;
      double totalTips = 0.0;
      double totalBonus = 0.0;
      int totalJobs = earnings.length;

      for (final earning in earnings) {
        totalAmount += (earning['total_amount']?.toDouble() ?? 0.0);
        totalTips += (earning['tip_amount']?.toDouble() ?? 0.0);
        totalBonus += (earning['bonus_amount']?.toDouble() ?? 0.0);
      }

      return {
        'total_amount': totalAmount,
        'total_tips': totalTips,
        'total_bonus': totalBonus,
        'total_jobs': totalJobs,
        'earnings': earnings,
      };
    } catch (e) {
      debugPrint('Error getting driver earnings: $e');
      return {
        'total_amount': 0.0,
        'total_tips': 0.0,
        'total_bonus': 0.0,
        'total_jobs': 0,
        'earnings': [],
      };
    }
  }

  // Get driver statistics (ratings, completed jobs, etc.)
  Future<Map<String, dynamic>> getDriverStatistics() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get driver profile with stats
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id, rating, total_jobs, total_earnings')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      // Get review statistics
      final reviews = await _supabaseService.client
          .from('reviews')
          .select('rating')
          .eq('reviewee_id', user.id)
          .eq('is_customer_review', true);

      double averageRating = 0.0;
      int totalReviews = reviews.length;

      if (totalReviews > 0) {
        double totalRatingSum = 0.0;
        for (final review in reviews) {
          totalRatingSum += (review['rating']?.toDouble() ?? 0.0);
        }
        averageRating = totalRatingSum / totalReviews;
      }

      // Get this month's completed jobs
      final startOfMonth =
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      final thisMonthJobs = await _supabaseService.client
          .from('service_requests')
          .select('id')
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .gte('completed_at', startOfMonth.toIso8601String())
          .count();

      return {
        'total_jobs': driverProfile['total_jobs'] ?? 0,
        'total_earnings': driverProfile['total_earnings']?.toDouble() ?? 0.0,
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'this_month_jobs': thisMonthJobs.count ?? 0,
        'profile_rating': driverProfile['rating']?.toDouble() ?? 0.0,
      };
    } catch (e) {
      debugPrint('Error getting driver statistics: $e');
      return {
        'total_jobs': 0,
        'total_earnings': 0.0,
        'average_rating': 0.0,
        'total_reviews': 0,
        'this_month_jobs': 0,
        'profile_rating': 0.0,
      };
    }
  }

  // Get available service requests for the driver
  Future<List<Map<String, dynamic>>> getAvailableRequests({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Get all pending requests
      var query = _supabaseService.client
          .from('service_requests')
          .select('''
            *,
            customer:user_profiles!customer_id (
              full_name,
              phone,
              profile_image_url
            )
          ''')
          .eq('status', 'pending')
          .isFilter('driver_id', null)
          .order('urgency', ascending: false)
          .order('requested_at', ascending: true);

      final requests = await query;

      // If location is provided, filter by distance
      if (latitude != null && longitude != null) {
        return requests
            .where((request) {
              final pickupLat = request['pickup_latitude']?.toDouble();
              final pickupLng = request['pickup_longitude']?.toDouble();

              if (pickupLat == null || pickupLng == null) return false;

              // Simple distance calculation (approximate)
              final distance =
                  _calculateDistance(latitude, longitude, pickupLat, pickupLng);
              return distance <= radiusKm;
            })
            .toList()
            .cast<Map<String, dynamic>>();
      }

      return List<Map<String, dynamic>>.from(requests);
    } catch (e) {
      debugPrint('Error getting available requests: $e');
      return [];
    }
  }

  // Calculate distance between two points (approximate)
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Get driver's active/assigned requests
  Future<List<Map<String, dynamic>>> getDriverActiveRequests() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return [];

      // Get driver profile first
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      final response = await _supabaseService.client
          .from('service_requests')
          .select('''
            *,
            customer:user_profiles!customer_id (
              full_name,
              phone,
              profile_image_url
            )
          ''')
          .eq('driver_id', driverId)
          .inFilter('status', ['accepted', 'in_progress'])
          .order('accepted_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting driver active requests: $e');
      return [];
    }
  }

  // Accept a service request
  Future<bool> acceptServiceRequest(String requestId) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      // Get driver profile
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      // Update service request
      await _supabaseService.client
          .from('service_requests')
          .update({
            'driver_id': driverId,
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .eq('status', 'pending');

      // Update driver status
      await updateDriverStatus('busy', isAvailable: false);

      return true;
    } catch (e) {
      debugPrint('Error accepting service request: $e');
      return false;
    }
  }

  // Update service request status
  Future<bool> updateServiceRequestStatus(
      String requestId, String status) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return false;

      // Get driver profile
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      Map<String, dynamic> updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add status-specific timestamps
      switch (status) {
        case 'in_progress':
          updateData['started_at'] = DateTime.now().toIso8601String();
          break;
        case 'completed':
          updateData['completed_at'] = DateTime.now().toIso8601String();

          // Create earnings record and update driver stats
          await _processCompletedJob(requestId, driverId);

          // Make driver available again
          await updateDriverStatus('online', isAvailable: true);
          break;
        case 'cancelled':
          updateData['cancelled_at'] = DateTime.now().toIso8601String();

          // Make driver available again
          await updateDriverStatus('online', isAvailable: true);
          break;
      }

      // Update the service request
      await _supabaseService.client
          .from('service_requests')
          .update(updateData)
          .eq('id', requestId)
          .eq('driver_id', driverId);

      return true;
    } catch (e) {
      debugPrint('Error updating service request status: $e');
      return false;
    }
  }

  // Process completed job (create earnings, update stats)
  Future<void> _processCompletedJob(String requestId, String driverId) async {
    try {
      // Get service request details
      final request = await _supabaseService.client
          .from('service_requests')
          .select('estimated_price, final_price')
          .eq('id', requestId)
          .single();

      final jobAmount = request['final_price']?.toDouble() ??
          request['estimated_price']?.toDouble() ??
          0.0;

      if (jobAmount <= 0) return;

      // Calculate driver earnings (85% of total, 15% platform fee)
      final driverEarning = jobAmount * 0.85;

      // Create earnings record
      await _supabaseService.client.from('driver_earnings').insert({
        'driver_id': driverId,
        'service_request_id': requestId,
        'base_amount': driverEarning,
        'total_amount': driverEarning,
        'tip_amount': 0.00,
        'bonus_amount': 0.00,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });

      // Update driver profile stats
      final currentProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('total_earnings, total_jobs')
          .eq('id', driverId)
          .single();

      await _supabaseService.client.from('driver_profiles').update({
        'total_earnings':
            (currentProfile['total_earnings']?.toDouble() ?? 0.0) +
                driverEarning,
        'total_jobs': (currentProfile['total_jobs']?.toInt() ?? 0) + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', driverId);
    } catch (e) {
      debugPrint('Error processing completed job: $e');
    }
  }

  // Get job history for the driver
  Future<List<Map<String, dynamic>>> getJobHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) return [];

      // Get driver profile first
      final driverProfile = await _supabaseService.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final driverId = driverProfile['id'];

      final response = await _supabaseService.client
          .from('service_requests')
          .select('''
            *,
            customer:user_profiles!customer_id (
              full_name,
              phone
            ),
            payment:payments!service_request_id (
              amount,
              payment_status,
              payment_method
            )
          ''')
          .eq('driver_id', driverId)
          .inFilter('status', ['completed', 'cancelled'])
          .order('completed_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting job history: $e');
      return [];
    }
  }
}