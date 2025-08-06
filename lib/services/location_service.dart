import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './supabase_service.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  loc.Location location = loc.Location();

  // Get API keys from environment
  static const String _googlePlacesApiKey = String.fromEnvironment(
      'GOOGLE_PLACES_API_KEY',
      defaultValue: 'AIzaSyBvOkBwgGlbUiuS-your-google-places-key');
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  // Current location data
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  String? _currentAddress;
  String? get currentAddress => _currentAddress;

  // Initialize location service with global support
  Future<bool> initialize() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (kDebugMode) {
        print('Location service enabled: $serviceEnabled');
      }

      if (!serviceEnabled) {
        try {
          serviceEnabled = await location.requestService();
          if (kDebugMode) {
            print('Location service request result: $serviceEnabled');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error requesting location service: $e');
          }
        }

        if (!serviceEnabled) {
          if (kDebugMode) {
            print('Location service is disabled and cannot be enabled');
          }
          return false;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (kDebugMode) {
        print('Initial permission status: $permission');
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (kDebugMode) {
          print('Permission after request: $permission');
        }

        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permission denied by user');
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permission permanently denied');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing location service: $e');
      }
      return false;
    }
  }

  // Get current location with global positioning support
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      if (kDebugMode) {
        print(
            'Getting current location globally, force refresh: $forceRefresh');
      }

      if (!forceRefresh && _currentPosition != null) {
        final now = DateTime.now();
        final locationTime = DateTime.fromMillisecondsSinceEpoch(
            _currentPosition!.timestamp.millisecondsSinceEpoch);
        final difference = now.difference(locationTime).inMinutes;

        if (difference < 2) {
          return _currentPosition;
        }
      }

      bool isInitialized = await initialize();
      if (!isInitialized) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
        forceAndroidLocationManager: false,
      ).timeout(const Duration(seconds: 20), onTimeout: () async {
        return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10));
      });

      _currentPosition = position;
      await _updateAddressFromPosition(position);

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      return null;
    }
  }

  // Convert coordinates to address with global reverse geocoding
  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      if (kDebugMode) {
        print(
            'Getting global address for: ${position.latitude}, ${position.longitude}');
      }

      // Check cache first
      final cachedAddress =
          await getCachedAddress(position.latitude, position.longitude);
      if (cachedAddress != null) {
        _currentAddress = cachedAddress;
        if (kDebugMode) {
          print('Using cached address: $_currentAddress');
        }
        return;
      }

      String? resolvedAddress;

      // Try Google Geocoding API for better global coverage if API key is available
      if (_googlePlacesApiKey !=
          'AIzaSyBvOkBwgGlbUiuS-your-google-places-key') {
        try {
          final response = await http
              .get(
                Uri.parse(
                    'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_googlePlacesApiKey'),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['results'] != null && data['results'].isNotEmpty) {
              resolvedAddress = data['results'][0]['formatted_address'];
              if (kDebugMode) {
                print('Google API address resolved: $resolvedAddress');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Google API failed, trying fallback: $e');
          }
        }
      }

      // Fallback to Flutter's geocoding
      if (resolvedAddress == null) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(const Duration(seconds: 10));

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            resolvedAddress = _formatGlobalAddress(placemark);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Geocoding fallback failed: $e');
          }
        }
      }

      _currentAddress = resolvedAddress ??
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      // Cache the resolved address
      if (resolvedAddress != null) {
        await cacheAddress(
            position.latitude, position.longitude, resolvedAddress);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address: $e');
      }
      _currentAddress =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }
  }

  // Format address globally with proper international formatting
  String _formatGlobalAddress(Placemark placemark) {
    List<String> addressParts = [];

    // Street number and name
    if (placemark.subThoroughfare != null &&
        placemark.subThoroughfare!.isNotEmpty) {
      if (placemark.thoroughfare != null &&
          placemark.thoroughfare!.isNotEmpty) {
        addressParts
            .add('${placemark.subThoroughfare} ${placemark.thoroughfare}');
      } else {
        addressParts.add(placemark.subThoroughfare!);
      }
    } else if (placemark.thoroughfare != null &&
        placemark.thoroughfare!.isNotEmpty) {
      addressParts.add(placemark.thoroughfare!);
    }

    // Neighborhood/Sub-locality
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressParts.add(placemark.subLocality!);
    }

    // City/Locality
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }

    // State/Administrative Area
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      if (placemark.locality != placemark.administrativeArea) {
        addressParts.add(placemark.administrativeArea!);
      }
    }

    // Country
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }

    // Postal Code
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      if (addressParts.isNotEmpty) {
        addressParts[addressParts.length - 1] += ' ${placemark.postalCode}';
      }
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Current Location';
  }

  // Check cached address
  Future<String?> getCachedAddress(double latitude, double longitude) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('location_address_cache')
          .select('formatted_address')
          .gte('latitude', latitude - 0.0005) // ~50m radius
          .lte('latitude', latitude + 0.0005)
          .gte('longitude', longitude - 0.0005)
          .lte('longitude', longitude + 0.0005)
          .gt('expires_at', DateTime.now().toIso8601String())
          .limit(1);

      if (response.isNotEmpty) {
        return response.first['formatted_address'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get cached address: $e');
      }
    }
    return null;
  }

  // Cache address
  Future<void> cacheAddress(
      double latitude, double longitude, String address) async {
    try {
      final client = SupabaseService.instance.client;

      await client.from('location_address_cache').insert({
        'latitude': latitude,
        'longitude': longitude,
        'formatted_address': address,
        'expires_at':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache address: $e');
      }
    }
  }

  // Global autocomplete search using Google Places API
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    try {
      if (_googlePlacesApiKey ==
          'AIzaSyBvOkBwgGlbUiuS-your-google-places-key') {
        // Return empty if no valid API key
        return [];
      }

      final response = await http
          .get(
            Uri.parse(
                '$_placesBaseUrl/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_googlePlacesApiKey&types=establishment|geocode'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((prediction) => {
                    'place_id': prediction['place_id'],
                    'description': prediction['description'],
                    'main_text': prediction['structured_formatting']
                        ['main_text'],
                    'secondary_text': prediction['structured_formatting']
                            ['secondary_text'] ??
                        '',
                  })
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching places: $e');
      }
    }
    return [];
  }

  // Get place details from place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      if (_googlePlacesApiKey ==
          'AIzaSyBvOkBwgGlbUiuS-your-google-places-key') {
        return null;
      }

      final response = await http
          .get(
            Uri.parse(
                '$_placesBaseUrl/details/json?place_id=$placeId&key=$_googlePlacesApiKey&fields=geometry,formatted_address,name'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null) {
          final result = data['result'];
          return {
            'latitude': result['geometry']['location']['lat'],
            'longitude': result['geometry']['location']['lng'],
            'formatted_address': result['formatted_address'],
            'name': result['name'],
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting place details: $e');
      }
    }
    return null;
  }

  // Start location tracking for drivers
  Stream<Position> startLocationTracking() {
    return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ));
  }

  // Update driver location in database
  Future<bool> updateDriverLocation(Position position) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) return false;

      await client.from('driver_profiles').update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      _currentPosition = position;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating driver location: $e');
      }
      return false;
    }
  }

  // Calculate distance between two points
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }

  // Get nearby drivers
  Future<List<Map<String, dynamic>>> getNearbyDrivers(
      double latitude, double longitude,
      {double radiusKm = 10}) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('driver_profiles')
          .select('''
            *,
            user_profiles!inner(
              full_name,
              phone,
              profile_image_url
            )
          ''')
          .eq('current_status', 'online')
          .eq('is_available', true)
          .not('current_latitude', 'is', null)
          .not('current_longitude', 'is', null);

      final drivers = response as List<dynamic>;
      List<Map<String, dynamic>> nearbyDrivers = [];

      for (var driver in drivers) {
        double distance = calculateDistance(
            latitude,
            longitude,
            driver['current_latitude'].toDouble(),
            driver['current_longitude'].toDouble());

        if (distance <= radiusKm) {
          driver['distance_km'] = distance;
          nearbyDrivers.add(driver);
        }
      }

      nearbyDrivers
          .sort((a, b) => a['distance_km'].compareTo(b['distance_km']));

      return nearbyDrivers;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nearby drivers: $e');
      }
      return [];
    }
  }

  // Get directions URL for navigation
  String getDirectionsUrl(
      double startLat, double startLng, double endLat, double endLng) {
    return 'https://www.google.com/maps/dir/$startLat,$startLng/$endLat,$endLng';
  }

  // Force refresh current location (public method for UI use)
  Future<Position?> refreshCurrentLocation() async {
    return getCurrentLocation(forceRefresh: true);
  }

  // Check if location services are available
  Future<bool> isLocationAvailable() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();

      return serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  // Get location accuracy description for UI
  String getAccuracyDescription(Position position) {
    final accuracy = position.accuracy;
    if (accuracy <= 5) {
      return 'Very High Accuracy';
    } else if (accuracy <= 10) {
      return 'High Accuracy';
    } else if (accuracy <= 50) {
      return 'Medium Accuracy';
    } else {
      return 'Low Accuracy';
    }
  }
}
