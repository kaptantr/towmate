import 'package:flutter/material.dart';

import './supabase_service.dart';

class ServiceRequestService {
  static final ServiceRequestService _instance =
      ServiceRequestService._internal();
  factory ServiceRequestService() => _instance;
  ServiceRequestService._internal();
  static ServiceRequestService get instance => _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<Map<String, dynamic>?> createServiceRequest({
    required String serviceType,
    required String vehicleType,
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? description,
    String urgency = 'medium',
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final requestData = {
        'customer_id': user.id,
        'service_type': serviceType,
        'vehicle_type': vehicleType,
        'pickup_address': pickupAddress,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'destination_address': destinationAddress,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'description': description,
        'urgency': urgency,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('service_requests')
          .insert(requestData)
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint('Service request creation failed: $e');
      throw Exception('Failed to create service request: $e');
    }
  }

  // NEW: Multi-service request creation
  Future<Map<String, dynamic>?> createMultiServiceRequest({
    required List<String> selectedServices,
    required Map<String, double> servicePrices,
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    List<String>? quickDescriptions,
    String? customDescription,
    bool emergencyPriority = false,
    required double totalPrice,
    required double totalDiscount,
  }) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create main service request with first service as primary
      final mainServiceType = selectedServices.first;
      final urgencyLevel = emergencyPriority ? 'emergency' : 'medium';

      final requestData = {
        'customer_id': user.id,
        'service_type': mainServiceType,
        'vehicle_type': 'sedan', // Default, can be made configurable
        'pickup_address': pickupAddress,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'destination_address': destinationAddress,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'description':
            _combineDescriptions(quickDescriptions, customDescription),
        'urgency': urgencyLevel,
        'status': 'pending',
        'estimated_price': totalPrice,
        'requested_at': DateTime.now().toIso8601String(),
      };

      // Create the main service request
      final response = await _supabaseService.client
          .from('service_requests')
          .insert(requestData)
          .select()
          .single();

      final serviceRequestId = response['id'];

      // Create individual service items
      await _createServiceRequestItems(
        serviceRequestId,
        selectedServices,
        servicePrices,
      );

      // Create description entries
      if (quickDescriptions != null && quickDescriptions.isNotEmpty) {
        await _createDescriptionEntries(serviceRequestId, quickDescriptions);
      }

      return response;
    } catch (e) {
      debugPrint('Multi-service request creation failed: $e');
      throw Exception('Failed to create multi-service request: $e');
    }
  }

  Future<void> _createServiceRequestItems(
    String serviceRequestId,
    List<String> selectedServices,
    Map<String, double> servicePrices,
  ) async {
    final items = selectedServices.map((serviceType) {
      return {
        'service_request_id': serviceRequestId,
        'service_type': serviceType,
        'estimated_price': servicePrices[serviceType] ?? 0.0,
        'status': 'pending',
      };
    }).toList();

    await _supabaseService.client.from('service_request_items').insert(items);
  }

  Future<void> _createDescriptionEntries(
    String serviceRequestId,
    List<String> quickDescriptions,
  ) async {
    final descriptions = quickDescriptions.map((desc) {
      return {
        'service_request_id': serviceRequestId,
        'custom_description': desc,
      };
    }).toList();

    await _supabaseService.client
        .from('service_request_descriptions')
        .insert(descriptions);
  }

  String _combineDescriptions(
      List<String>? quickDescriptions, String? customDescription) {
    List<String> parts = [];

    if (quickDescriptions != null && quickDescriptions.isNotEmpty) {
      parts.addAll(quickDescriptions);
    }

    if (customDescription != null && customDescription.isNotEmpty) {
      parts.add(customDescription);
    }

    return parts.join('; ');
  }

  // NEW: Get service configurations from admin settings
  Future<Map<String, Map<String, dynamic>>> getServiceConfigurations() async {
    try {
      final response = await _supabaseService.client
          .from('admin_service_configurations')
          .select('*')
          .eq('is_active', true);

      final Map<String, Map<String, dynamic>> configurations = {};

      for (final config in response) {
        configurations[config['service_type']] = {
          'name': config['display_name'],
          'icon': config['icon_name'],
          'basePrice': config['base_price']?.toDouble() ?? 0.0,
          'description': config['description'],
          'available': config['is_active'] ?? true,
        };
      }

      return configurations;
    } catch (e) {
      debugPrint('Failed to load service configurations: $e');
      return _getDefaultServiceConfigurations();
    }
  }

  // Fallback service configurations
  Map<String, Map<String, dynamic>> _getDefaultServiceConfigurations() {
    return {
      'towing': {
        'name': 'Araç Çekme',
        'icon': 'local_shipping',
        'basePrice': 150.0,
        'description': 'Profesyonel araç çekme hizmeti',
        'available': true,
      },
      'jumpstart': {
        'name': 'Akü Takviyesi',
        'icon': 'battery_charging_full',
        'basePrice': 80.0,
        'description': 'Boşalan akü için acil takviye',
        'available': true,
      },
      'tire_change': {
        'name': 'Lastik Değişimi',
        'icon': 'tire_repair',
        'basePrice': 100.0,
        'description': 'Patlak lastik değişim hizmeti',
        'available': true,
      },
      'lockout': {
        'name': 'Kapı Açma',
        'icon': 'lock_open',
        'basePrice': 120.0,
        'description': 'Araç içinde kalan anahtar sorunu',
        'available': true,
      },
      'fuel_delivery': {
        'name': 'Yakıt İkmali',
        'icon': 'local_gas_station',
        'basePrice': 90.0,
        'description': 'Acil yakıt getirme hizmeti',
        'available': true,
      },
      'winch_service': {
        'name': 'Vinç Hizmeti',
        'icon': 'construction',
        'basePrice': 200.0,
        'description': 'Ağır vinç operasyonları',
        'available': true,
      },
    };
  }

  // NEW: Get description options from admin settings
  Future<Map<String, List<Map<String, dynamic>>>> getDescriptionOptions(
      List<String> selectedServices) async {
    try {
      final response = await _supabaseService.client
          .from('admin_description_options')
          .select('*')
          .eq('is_active', true)
          .order('display_order');

      final Map<String, List<Map<String, dynamic>>> options = {};

      for (final option in response) {
        final category = option['category'];
        final serviceType = option['service_type'];

        // Include options that are for all services (null service_type) or for selected services
        if (serviceType == null || selectedServices.contains(serviceType)) {
          if (!options.containsKey(category)) {
            options[category] = [];
          }

          options[category]!.add({
            'id': option['id'],
            'text': option['option_text'],
            'service_type': option['service_type'],
          });
        }
      }

      return options;
    } catch (e) {
      debugPrint('Failed to load description options: $e');
      return _getDefaultDescriptionOptions(selectedServices);
    }
  }

  // Fallback description options
  Map<String, List<Map<String, dynamic>>> _getDefaultDescriptionOptions(
      List<String> selectedServices) {
    Map<String, List<Map<String, dynamic>>> options = {};

    if (selectedServices.contains('towing')) {
      options['Araç Durumu'] = [
        {'id': '1', 'text': 'Motor çalışmıyor', 'service_type': 'towing'},
        {'id': '2', 'text': 'Kaza geçirdi', 'service_type': 'towing'},
        {'id': '3', 'text': 'Lastik patladı', 'service_type': 'towing'},
      ];
    }

    if (selectedServices.contains('jumpstart')) {
      options['Akü Durumu'] = [
        {'id': '4', 'text': 'Akü tamamen bitmiş', 'service_type': 'jumpstart'},
        {'id': '5', 'text': 'Motor çalışmıyor', 'service_type': 'jumpstart'},
      ];
    }

    return options;
  }

  Future<List<Map<String, dynamic>>> getServiceRequests() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('service_requests')
          .select('*')
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch service requests: $e');
      throw Exception('Failed to fetch service requests: $e');
    }
  }

  Future<Map<String, dynamic>?> getServiceRequest(String id) async {
    try {
      final response = await _supabaseService.client
          .from('service_requests')
          .select('*')
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      debugPrint('Failed to fetch service request: $e');
      return null;
    }
  }

  Future<bool> updateServiceRequestStatus(String id, String status) async {
    try {
      await _supabaseService.client.from('service_requests').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      return true;
    } catch (e) {
      debugPrint('Failed to update service request status: $e');
      return false;
    }
  }

  Future<bool> cancelServiceRequest(String id) async {
    try {
      await _supabaseService.client.from('service_requests').update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      return true;
    } catch (e) {
      debugPrint('Failed to cancel service request: $e');
      return false;
    }
  }

  // NEW: Get driver earnings data
  Future<Map<String, dynamic>> getDriverEarnings() async {
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

      // Get today's earnings
      final todayEarnings = await _supabaseService.client
          .from('driver_earnings')
          .select('total_amount, tip_amount, bonus_amount')
          .eq('driver_id', driverId)
          .eq('date', DateTime.now().toIso8601String().split('T')[0]);

      // Get this week's earnings
      final startOfWeek =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final weekEarnings = await _supabaseService.client
          .from('driver_earnings')
          .select('total_amount, tip_amount, bonus_amount')
          .eq('driver_id', driverId)
          .gte('date', startOfWeek.toIso8601String().split('T')[0]);

      double todayTotal = 0.0;
      double todayTips = 0.0;
      double todayBonus = 0.0;

      for (final earning in todayEarnings) {
        todayTotal += (earning['total_amount']?.toDouble() ?? 0.0);
        todayTips += (earning['tip_amount']?.toDouble() ?? 0.0);
        todayBonus += (earning['bonus_amount']?.toDouble() ?? 0.0);
      }

      double weekTotal = 0.0;
      for (final earning in weekEarnings) {
        weekTotal += (earning['total_amount']?.toDouble() ?? 0.0);
      }

      return {
        'today_earnings': todayTotal,
        'today_tips': todayTips,
        'today_bonus': todayBonus,
        'week_earnings': weekTotal,
      };
    } catch (e) {
      debugPrint('Failed to get driver earnings: $e');
      return {
        'today_earnings': 0.0,
        'today_tips': 0.0,
        'today_bonus': 0.0,
        'week_earnings': 0.0,
      };
    }
  }

  // NEW: Get available service requests for drivers
  Future<List<Map<String, dynamic>>> getAvailableRequests() async {
    try {
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
          .eq('status', 'pending')
          .isFilter('driver_id', null)
          .order('urgency', ascending: false)
          .order('requested_at', ascending: true)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to get available requests: $e');
      return [];
    }
  }

  // NEW: Get active service requests for current driver
  Future<List<Map<String, dynamic>>> getDriverActiveRequests() async {
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
      debugPrint('Failed to get driver active requests: $e');
      return [];
    }
  }

  // NEW: Accept a service request
  Future<bool> acceptServiceRequest(String requestId) async {
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

      // Update the service request
      await _supabaseService.client
          .from('service_requests')
          .update({
            'driver_id': driverId,
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .eq('status', 'pending'); // Ensure it's still pending

      // Update driver status to busy
      await _supabaseService.client.from('driver_profiles').update({
        'current_status': 'busy',
        'is_available': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', driverId);

      return true;
    } catch (e) {
      debugPrint('Failed to accept service request: $e');
      return false;
    }
  }

  // NEW: Update request status (for driver workflow)
  Future<bool> updateRequestStatus(String requestId, String status) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get driver profile to verify ownership
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

      // Add timestamp fields based on status
      switch (status) {
        case 'in_progress':
          updateData['started_at'] = DateTime.now().toIso8601String();
          break;
        case 'completed':
          updateData['completed_at'] = DateTime.now().toIso8601String();

          // Get the request details for earnings calculation
          final request = await _supabaseService.client
              .from('service_requests')
              .select('estimated_price, final_price')
              .eq('id', requestId)
              .single();

          final earningsAmount = request['final_price']?.toDouble() ??
              request['estimated_price']?.toDouble() ??
              0.0;

          // Create earnings record
          if (earningsAmount > 0) {
            await _supabaseService.client.from('driver_earnings').insert({
              'driver_id': driverId,
              'service_request_id': requestId,
              'base_amount':
                  earningsAmount * 0.85, // 85% to driver, 15% commission
              'total_amount': earningsAmount * 0.85,
              'date': DateTime.now().toIso8601String().split('T')[0],
            });

            // Update driver's total earnings and job count
            final currentProfile = await _supabaseService.client
                .from('driver_profiles')
                .select('total_earnings, total_jobs')
                .eq('id', driverId)
                .single();

            await _supabaseService.client.from('driver_profiles').update({
              'total_earnings':
                  (currentProfile['total_earnings']?.toDouble() ?? 0.0) +
                      (earningsAmount * 0.85),
              'total_jobs': (currentProfile['total_jobs']?.toInt() ?? 0) + 1,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', driverId);
          }

          // Update driver status back to online
          await _supabaseService.client.from('driver_profiles').update({
            'current_status': 'online',
            'is_available': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', driverId);
          break;
        case 'cancelled':
          updateData['cancelled_at'] = DateTime.now().toIso8601String();

          // Update driver status back to online
          await _supabaseService.client.from('driver_profiles').update({
            'current_status': 'online',
            'is_available': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', driverId);
          break;
      }

      // Update the service request
      await _supabaseService.client
          .from('service_requests')
          .update(updateData)
          .eq('id', requestId)
          .eq('driver_id', driverId); // Ensure driver owns this request

      return true;
    } catch (e) {
      debugPrint('Failed to update request status: $e');
      return false;
    }
  }

  // NEW: Address caching methods for location management
  Future<String?> getCachedAddress(double latitude, double longitude) async {
    try {
      // Create a location key with reasonable precision
      final locationKey =
          '${latitude.toStringAsFixed(5)}_${longitude.toStringAsFixed(5)}';

      final response = await _supabaseService.client
          .from('address_cache')
          .select('cached_address, cached_at')
          .eq('location_key', locationKey)
          .maybeSingle();

      if (response != null) {
        // Check if cache is still valid (24 hours)
        final cachedAt = DateTime.parse(response['cached_at']);
        final now = DateTime.now();
        final difference = now.difference(cachedAt);

        if (difference.inHours < 24) {
          return response['cached_address'];
        } else {
          // Clean up expired cache entry
          await _supabaseService.client
              .from('address_cache')
              .delete()
              .eq('location_key', locationKey);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get cached address: $e');
      return null;
    }
  }

  Future<void> cacheAddress(
      double latitude, double longitude, String address) async {
    try {
      // Create a location key with reasonable precision
      final locationKey =
          '${latitude.toStringAsFixed(5)}_${longitude.toStringAsFixed(5)}';

      await _supabaseService.client.from('address_cache').upsert({
        'location_key': locationKey,
        'latitude': latitude,
        'longitude': longitude,
        'cached_address': address,
        'cached_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to cache address: $e');
      // Don't throw error as caching is not critical
    }
  }
}
