import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_service.dart';
import '../../services/service_request_service.dart';
import './widgets/destination_input_field.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/photo_upload_widget.dart';
import './widgets/price_estimation_card.dart';
import './widgets/tow_truck_type_selector.dart';

class CustomerServiceRequest extends StatefulWidget {
  const CustomerServiceRequest({Key? key}) : super(key: key);

  @override
  State<CustomerServiceRequest> createState() => _CustomerServiceRequestState();
}

class _CustomerServiceRequestState extends State<CustomerServiceRequest> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form data
  String? _selectedServiceType;
  String? _selectedVehicleType;
  Position? _currentLocation;
  String? _pickupAddress;
  String? _destinationAddress;
  String? _description;
  String _urgency = 'medium';
  List<XFile> _uploadedPhotos = [];
  bool _isLoading = false;
  bool _isLocationLoading = false;

  // Service types
  final Map<String, String> _serviceTypes = {
    'towing': 'Çekici Hizmeti',
    'jumpstart': 'Akü Takviye',
    'tire_change': 'Lastik Değişimi',
    'lockout': 'Kapı Açma',
    'fuel_delivery': 'Yakıt Getirme',
    'winch_service': 'Vinç Hizmeti',
  };

  // Vehicle types
  final Map<String, String> _vehicleTypes = {
    'sedan': 'Sedan',
    'suv': 'SUV',
    'truck': 'Kamyonet',
    'motorcycle': 'Motosiklet',
    'heavy_truck': 'Ağır Araç',
    'bus': 'Otobüs',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _isLoading = true;
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
        final address =
            LocationService.instance.currentAddress ?? 'Mevcut Konumunuz';
        setState(() {
          _currentLocation = position;
          _pickupAddress = address;
        });

        // Show success message
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
        // Show detailed error message with retry option
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
        _isLocationLoading = false;
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // Add automatic progression for better UX
  void _autoProgressAfterSelection() {
    if (_currentStep == 0 && _selectedServiceType != null) {
      // Auto-progress after service selection with a small delay for visual feedback
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _currentStep == 0) {
          _nextStep();
        }
      });
    } else if (_currentStep == 1 && _selectedVehicleType != null) {
      // Auto-progress after vehicle type selection
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _currentStep == 1) {
          _nextStep();
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_currentLocation == null ||
        _selectedServiceType == null ||
        _selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Lütfen tüm gerekli alanları doldurun'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = await ServiceRequestService.instance.createServiceRequest(
          serviceType: _selectedServiceType!,
          vehicleType: _selectedVehicleType!,
          pickupAddress: _pickupAddress ?? 'Mevcut Konum',
          pickupLatitude: _currentLocation!.latitude,
          pickupLongitude: _currentLocation!.longitude,
          destinationAddress: _destinationAddress,
          description: _description,
          urgency: _urgency);

      if (request != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Talebiniz başarıyla oluşturuldu!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary));

        // Navigate back or to tracking screen
        Navigator.pop(context);
      } else {
        throw Exception('Request creation failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Talep oluşturulamadı. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    return Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2)));
            })));
  }

  Widget _buildServiceTypeStep() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hangi hizmete ihtiyacınız var?',
              style: AppTheme.lightTheme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          Text(
              'Hizmet türünüzü seçtikten sonra otomatik olarak devam edeceğiz.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
          SizedBox(height: 4.h),
          ...(_serviceTypes.entries.map((entry) => Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedServiceType = entry.key;
                    });
                    // Add haptic feedback for better UX
                    HapticFeedback.lightImpact();
                    // Auto-progress after selection
                    _autoProgressAfterSelection();
                  },
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                          color: _selectedServiceType == entry.key
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _selectedServiceType == entry.key
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline,
                              width: _selectedServiceType == entry.key ? 2 : 1),
                          boxShadow: _selectedServiceType == entry.key
                              ? [
                                  BoxShadow(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : []),
                      child: Row(children: [
                        CustomIconWidget(
                            iconName: _getServiceIcon(entry.key),
                            color: _selectedServiceType == entry.key
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            size: 32),
                        SizedBox(width: 4.w),
                        Expanded(
                            child: Text(entry.value,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                        color: _selectedServiceType == entry.key
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface,
                                        fontWeight:
                                            _selectedServiceType == entry.key
                                                ? FontWeight.w600
                                                : FontWeight.w400))),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _selectedServiceType == entry.key
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                        iconName: 'check_circle',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 24),
                                    SizedBox(width: 2.w),
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppTheme.lightTheme.colorScheme
                                                    .primary),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ])))))),
        ]));
  }

  Widget _buildVehicleTypeStep() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Araç tipinizi seçin',
              style: AppTheme.lightTheme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          Text('Araç tipinizi seçtikten sonra otomatik olarak devam edeceğiz.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
          SizedBox(height: 4.h),
          TowTruckTypeSelector(
              selectedType: _selectedVehicleType ?? '',
              priceEstimates: const {},
              onTypeSelected: (type) {
                setState(() {
                  _selectedVehicleType = type;
                });
                // Add haptic feedback for better UX
                HapticFeedback.lightImpact();
                // Auto-progress after selection
                _autoProgressAfterSelection();
              }),
        ]));
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konumunuzu onaylayın',
            style: AppTheme.lightTheme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
          Text(
            'Başlangıç konumunuz GPS ile tespit edilir. Varış noktanızı da belirtebilirsiniz.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),

          // Current location section
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
                      iconName: 'my_location',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Mevcut Konumunuz',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                if (_isLocationLoading)
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'GPS konumunuz tespit ediliyor...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                else if (_currentLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _pickupAddress ?? 'Konum tespit edildi',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLocationLoading
                                  ? null
                                  : _getCurrentLocation,
                              icon: Icon(
                                _isLocationLoading
                                    ? Icons.hourglass_empty
                                    : Icons.refresh,
                                size: 18,
                              ),
                              label: Text(_isLocationLoading
                                  ? 'Güncelleniyor...'
                                  : 'Konumu Yenile'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_off',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 32,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Konum tespit edilemedi',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'GPS ve konum servislerinin açık olduğundan emin olun.',
                        textAlign: TextAlign.center,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton.icon(
                        onPressed:
                            _isLocationLoading ? null : _getCurrentLocation,
                        icon: Icon(_isLocationLoading
                            ? Icons.hourglass_empty
                            : Icons.refresh),
                        label: Text(_isLocationLoading
                            ? 'Güncelleniyor...'
                            : 'Tekrar Dene'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Always show destination input for all services (not just towing)
          DestinationInputField(
            destination: _destinationAddress,
            onDestinationChanged: (destination) {
              setState(() {
                _destinationAddress = destination;
              });
            },
            onPlaceSelected: (address, lat, lng) {
              setState(() {
                _destinationAddress = address;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Durum Açıklaması',
            style: AppTheme.lightTheme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),

          // Description input
          Container(
            margin: EdgeInsets.only(bottom: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Araç Durumu',
                  style: AppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  child: TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Aracınızın durumunu ve sorunu detaylı olarak açıklayın...',
                      hintStyle:
                          AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _description = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Urgency selector
          Container(
            margin: EdgeInsets.only(bottom: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aciliyet Durumu',
                  style: AppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    _buildUrgencyOption('low', 'Düşük', Colors.green),
                    _buildUrgencyOption('medium', 'Normal', Colors.orange),
                    _buildUrgencyOption('high', 'Yüksek', Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Photo upload
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Araç Fotoğrafları',
                  style: AppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Aracınızın mevcut durumunu gösteren fotoğraflar ekleyin',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                PhotoUploadWidget(
                  uploadedPhotos: _uploadedPhotos,
                  onPhotosChanged: (photos) {
                    setState(() {
                      _uploadedPhotos = photos;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyOption(String key, String label, Color color) {
    bool isSelected = _urgency == key;
    return Expanded(
        child: GestureDetector(
            onTap: () {
              setState(() {
                _urgency = key;
              });
            },
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isSelected
                            ? color
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: isSelected ? 2 : 1)),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? color
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400)))));
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Talep Özeti',
              style: AppTheme.lightTheme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),

          // Price estimation
          PriceEstimationCard(priceBreakdown: const {}),

          SizedBox(height: 3.h),

          // Request summary
          Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryItem(
                        'Hizmet', _serviceTypes[_selectedServiceType] ?? ''),
                    _buildSummaryItem(
                        'Araç', _vehicleTypes[_selectedVehicleType] ?? ''),
                    _buildSummaryItem('Konum', _pickupAddress ?? ''),
                    if (_destinationAddress != null)
                      _buildSummaryItem('Varış', _destinationAddress!),
                    if (_description != null)
                      _buildSummaryItem('Açıklama', _description!),
                  ])),

          SizedBox(height: 4.h),

          // Emergency contact
          EmergencyContactWidget(),
        ]));
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 20.w,
              child: Text('$label:',
                  style: AppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(
              child:
                  Text(value, style: AppTheme.lightTheme.textTheme.bodyMedium)),
        ]));
  }

  String _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'towing':
        return 'local_shipping';
      case 'jumpstart':
        return 'battery_charging_full';
      case 'tire_change':
        return 'tire_repair';
      case 'lockout':
        return 'lock_open';
      case 'fuel_delivery':
        return 'local_gas_station';
      case 'winch_service':
        return 'construction';
      default:
        return 'build';
    }
  }

  bool _needsDestination() {
    return _selectedServiceType == 'towing';
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedServiceType != null;
      case 1:
        return _selectedVehicleType != null;
      case 2:
        return _currentLocation != null; // Can proceed even without destination
      case 3:
        return true; // Details are optional - user can proceed without description
      case 4:
        return true; // Confirmation step
      default:
        return false;
    }
  }

  bool _canGoBack() {
    return _currentStep > 0 && !_isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hizmet Talebi',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_canGoBack()) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (_currentStep != index) {
                  setState(() {
                    _currentStep = index;
                  });
                }
              },
              children: [
                _buildServiceTypeStep(),
                _buildVehicleTypeStep(),
                _buildLocationStep(),
                _buildDetailsStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
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
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _canGoBack() ? _previousStep : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          side: BorderSide(
                            color: _canGoBack()
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: _canGoBack()
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Geri',
                              style: TextStyle(
                                color: _canGoBack()
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 4.w),
                  Expanded(
                    flex: _currentStep > 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || _isLocationLoading) || !_canProceed()
                              ? null
                              : _currentStep == 4
                                  ? _submitRequest
                                  : _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        backgroundColor:
                            _canProceed() && !_isLoading && !_isLocationLoading
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme
                                    .surfaceContainerHighest,
                        foregroundColor: _canProceed() &&
                                !_isLoading &&
                                !_isLocationLoading
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        elevation:
                            _canProceed() && !_isLoading && !_isLocationLoading
                                ? 2
                                : 0,
                      ),
                      child: (_isLoading || _isLocationLoading)
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
                                  _currentStep == 4 ? 'Talep Oluştur' : 'İleri',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (_currentStep < 4) ...[
                                  SizedBox(width: 1.w),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
