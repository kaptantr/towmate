import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_service.dart';
import '../../services/service_request_service.dart';
import './widgets/address_display_widget.dart';
import './widgets/destination_autocomplete_widget.dart';
import './widgets/location_quick_select_widget.dart';
import './widgets/route_preview_widget.dart';

class EnhancedLocationManagementSystem extends StatefulWidget {
  const EnhancedLocationManagementSystem({Key? key}) : super(key: key);

  @override
  State<EnhancedLocationManagementSystem> createState() =>
      _EnhancedLocationManagementSystemState();
}

class _EnhancedLocationManagementSystemState
    extends State<EnhancedLocationManagementSystem> {
  Position? _currentPosition;
  String? _currentAddress;
  String? _destinationAddress;
  Position? _destinationPosition;
  bool _isLoadingLocation = false;
  bool _isValidatingAddress = false;
  Map<String, dynamic>? _routePreview;

  // Arguments from previous screen
  List<String> _selectedServices = [];
  Map<String, double> _servicePrices = {};
  double _totalPrice = 0.0;
  double _totalDiscount = 0.0;
  List<String> _quickDescriptions = [];
  String? _customDescription;
  bool _emergencyPriority = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArgumentsAndInitialize();
    });
  }

  void _loadArgumentsAndInitialize() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _selectedServices = List<String>.from(args['selectedServices'] ?? []);
        _servicePrices = Map<String, double>.from(args['servicePrices'] ?? {});
        _totalPrice = args['totalPrice']?.toDouble() ?? 0.0;
        _totalDiscount = args['totalDiscount']?.toDouble() ?? 0.0;
        _quickDescriptions = List<String>.from(args['quickDescriptions'] ?? []);
        _customDescription = args['customDescription'];
        _emergencyPriority = args['emergencyPriority'] ?? false;
      });
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Initialize location service first
      final initialized = await LocationService.instance.initialize();
      if (!initialized) {
        throw Exception('Konum servisi başlatılamadı');
      }

      final position =
          await LocationService.instance.getCurrentLocation(forceRefresh: true);

      if (position != null) {
        // Convert coordinates to meaningful address
        final address = await _convertCoordinatesToAddress(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Konumunuz başarıyla tespit edildi!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Konum tespit edilemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum alınırken hata oluştu: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: AppTheme.lightTheme.colorScheme.onError,
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<String> _convertCoordinatesToAddress(
      double latitude, double longitude) async {
    try {
      // Check cache first
      final cachedAddress = await ServiceRequestService.instance
          .getCachedAddress(latitude, longitude);
      if (cachedAddress != null) {
        return cachedAddress;
      }

      // Perform reverse geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = _formatPlacemarkToAddress(place);

        // Cache the result
        await ServiceRequestService.instance
            .cacheAddress(latitude, longitude, address);
        return address;
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }

    // Fallback to coordinates with descriptive format
    return 'Tespit Edilen Konum: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String _formatPlacemarkToAddress(Placemark place) {
    List<String> addressParts = [];

    // Street number and name
    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    } else {
      if (place.name?.isNotEmpty == true && place.name != place.locality) {
        addressParts.add(place.name!);
      }
    }

    // Neighborhood
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }

    // City and state
    if (place.locality?.isNotEmpty == true) {
      String cityPart = place.locality!;
      if (place.administrativeArea?.isNotEmpty == true &&
          place.administrativeArea != place.locality) {
        cityPart += ', ${place.administrativeArea!}';
      }
      addressParts.add(cityPart);
    }

    // Postal code
    if (place.postalCode?.isNotEmpty == true) {
      addressParts.add(place.postalCode!);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Adres tespit edilemedi';
  }

  Future<void> _onDestinationSelected(
      String address, double? lat, double? lng) async {
    setState(() {
      _destinationAddress = address;
      _destinationPosition = lat != null && lng != null
          ? Position(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            )
          : null;
    });

    // Generate route preview if both locations are available
    if (_currentPosition != null && _destinationPosition != null) {
      _generateRoutePreview();
    }
  }

  Future<void> _generateRoutePreview() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    try {
      // Calculate distance and estimated time
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destinationPosition!.latitude,
        _destinationPosition!.longitude,
      );

      final distanceKm = distance / 1000;
      final estimatedTimeMinutes =
          (distanceKm / 40) * 60; // Assuming 40 km/h average speed

      setState(() {
        _routePreview = {
          'distance': distanceKm,
          'estimatedTime': estimatedTimeMinutes,
          'startAddress': _currentAddress,
          'endAddress': _destinationAddress,
        };
      });
    } catch (e) {
      debugPrint('Route preview generation failed: $e');
    }
  }

  void _proceedToServiceRequest() {
    if (_currentPosition == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen konum onayını bekleyin'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Create service request with multi-service support
    _createMultiServiceRequest();
  }

  Future<void> _createMultiServiceRequest() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final request =
          await ServiceRequestService.instance.createMultiServiceRequest(
        selectedServices: _selectedServices,
        servicePrices: _servicePrices,
        pickupAddress: _currentAddress!,
        pickupLatitude: _currentPosition!.latitude,
        pickupLongitude: _currentPosition!.longitude,
        destinationAddress: _destinationAddress,
        destinationLatitude: _destinationPosition?.latitude,
        destinationLongitude: _destinationPosition?.longitude,
        quickDescriptions: _quickDescriptions,
        customDescription: _customDescription,
        emergencyPriority: _emergencyPriority,
        totalPrice: _totalPrice,
        totalDiscount: _totalDiscount,
      );

      if (request != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Çoklu hizmet talebiniz başarıyla oluşturuldu!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );

        // Navigate to driver matching screen
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.driverMatchingAndTracking,
          arguments: {
            'serviceRequestId': request['id'],
            'selectedServices': _selectedServices,
            'totalPrice': _totalPrice,
          },
        );
      } else {
        throw Exception('Request creation failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Talep oluşturulamadı. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Konum Onayı',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Text(
                    'Konumunuzu Onaylayın',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Başlangıç konumunuz tespit edildi. İsteğe bağlı olarak varış noktanızı da belirtebilirsiniz.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Current location display
                  AddressDisplayWidget(
                    title: 'Başlangıç Konumunuz',
                    address: _currentAddress,
                    position: _currentPosition,
                    isLoading: _isLoadingLocation,
                    onRefresh: _getCurrentLocation,
                    iconName: 'my_location',
                  ),

                  SizedBox(height: 3.h),

                  // Quick location selection
                  LocationQuickSelectWidget(
                    onLocationSelected: (address, lat, lng) {
                      _onDestinationSelected(address, lat, lng);
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Destination input
                  DestinationAutocompleteWidget(
                    currentAddress: _destinationAddress,
                    onDestinationSelected: _onDestinationSelected,
                  ),

                  SizedBox(height: 3.h),

                  // Route preview
                  if (_routePreview != null)
                    RoutePreviewWidget(
                      routeData: _routePreview!,
                    ),

                  SizedBox(height: 3.h),

                  // Selected services summary
                  if (_selectedServices.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'build',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 24,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Seçilen Hizmetler',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          ..._selectedServices.map((service) {
                            final serviceNames = {
                              'towing': 'Çekici Hizmeti',
                              'jumpstart': 'Akü Takviye',
                              'tire_change': 'Lastik Değişimi',
                              'lockout': 'Kapı Açma',
                              'fuel_delivery': 'Yakıt Getirme',
                              'winch_service': 'Vinç Hizmeti',
                            };

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.5.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      serviceNames[service] ?? service,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '₺${_servicePrices[service]?.toStringAsFixed(0) ?? '0'}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (_totalDiscount > 0) ...[
                            Divider(height: 2.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.discount,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Çoklu Hizmet İndirimi',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '-₺${_totalDiscount.toStringAsFixed(0)}',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          Divider(height: 2.h),
                          Row(
                            children: [
                              Text(
                                'Toplam',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₺${_totalPrice.toStringAsFixed(0)}',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: (_isLoadingLocation || _currentPosition == null)
                    ? null
                    : _proceedToServiceRequest,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: _currentPosition != null &&
                          !_isLoadingLocation
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  foregroundColor:
                      _currentPosition != null && !_isLoadingLocation
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                child: _isLoadingLocation
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hizmet Talebini Oluştur',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
