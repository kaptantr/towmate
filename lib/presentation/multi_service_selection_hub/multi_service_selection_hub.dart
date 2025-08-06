import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/service_request_service.dart';
import './widgets/quick_description_selector_widget.dart';
import './widgets/service_bundling_widget.dart';
import './widgets/service_selection_card_widget.dart';

class MultiServiceSelectionHub extends StatefulWidget {
  const MultiServiceSelectionHub({Key? key}) : super(key: key);

  @override
  State<MultiServiceSelectionHub> createState() =>
      _MultiServiceSelectionHubState();
}

class _MultiServiceSelectionHubState extends State<MultiServiceSelectionHub> {
  Set<String> _selectedServices = {};
  Map<String, double> _servicePrices = {};
  Map<String, String> _serviceDescriptions = {};
  bool _isLoading = false;
  bool _showEmergencyPriority = false;
  double _totalPrice = 0.0;
  double _totalDiscount = 0.0;
  List<String> _selectedQuickDescriptions = [];
  String? _customDescription;

  // Service configurations loaded from admin settings
  Map<String, Map<String, dynamic>> _serviceConfigurations = {
    'towing': {
      'name': 'Çekici Hizmeti',
      'icon': 'local_shipping',
      'basePrice': 180.0,
      'description': 'Aracınızı güvenli bir şekilde istediğiniz yere çekeriz',
      'available': true,
    },
    'jumpstart': {
      'name': 'Akü Takviye',
      'icon': 'battery_charging_full',
      'basePrice': 80.0,
      'description':
          'Boşalmış aküyü çalıştırır, aracınızı yeniden hayata döndürürüz',
      'available': true,
    },
    'tire_change': {
      'name': 'Lastik Değişimi',
      'icon': 'tire_repair',
      'basePrice': 120.0,
      'description': 'Patlak lastiğinizi yedek lastikle değiştiririz',
      'available': true,
    },
    'lockout': {
      'name': 'Kapı Açma',
      'icon': 'lock_open',
      'basePrice': 100.0,
      'description': 'Anahtarınızı içerde unuttuğunuzda aracınızı açarız',
      'available': true,
    },
    'fuel_delivery': {
      'name': 'Yakıt Getirme',
      'icon': 'local_gas_station',
      'basePrice': 150.0,
      'description': 'Yakıtınız bittiğinde size yakıt getiririz',
      'available': true,
    },
    'winch_service': {
      'name': 'Vinç Hizmeti',
      'icon': 'construction',
      'basePrice': 250.0,
      'description': 'Çamura saplanan veya hendekte kalan aracınızı çıkarırız',
      'available': true,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadServiceConfigurations();
  }

  Future<void> _loadServiceConfigurations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load service configurations from admin settings
      final configurations =
          await ServiceRequestService.instance.getServiceConfigurations();
      if (configurations.isNotEmpty) {
        setState(() {
          _serviceConfigurations = configurations;
        });
      }
    } catch (e) {
      // Use default configurations on error
      debugPrint('Failed to load service configurations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleService(String serviceType) {
    setState(() {
      if (_selectedServices.contains(serviceType)) {
        _selectedServices.remove(serviceType);
        _servicePrices.remove(serviceType);
        _serviceDescriptions.remove(serviceType);
      } else {
        _selectedServices.add(serviceType);
        final config = _serviceConfigurations[serviceType];
        if (config != null) {
          _servicePrices[serviceType] = config['basePrice']?.toDouble() ?? 0.0;
          _serviceDescriptions[serviceType] = config['description'] ?? '';
        }
      }
      _calculateTotalPrice();
    });

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  void _calculateTotalPrice() {
    double subtotal =
        _servicePrices.values.fold(0.0, (sum, price) => sum + price);

    // Calculate multi-service discount
    double discount = 0.0;
    if (_selectedServices.length >= 2) {
      if (_selectedServices.length >= 4) {
        discount = subtotal * 0.20; // 20% for 4+ services
      } else if (_selectedServices.length >= 3) {
        discount = subtotal * 0.15; // 15% for 3 services
      } else {
        discount = subtotal * 0.10; // 10% for 2 services
      }
    }

    // Apply emergency priority surcharge if selected
    double emergencySurcharge = 0.0;
    if (_showEmergencyPriority) {
      emergencySurcharge = subtotal * 0.25; // 25% emergency surcharge
    }

    setState(() {
      _totalDiscount = discount;
      _totalPrice = subtotal - discount + emergencySurcharge;
    });
  }

  void _proceedToLocationConfirmation() {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen en az bir hizmet seçin'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Navigate to Enhanced Location Management System
    Navigator.pushNamed(
      context,
      AppRoutes.enhancedLocationManagementSystem,
      arguments: {
        'selectedServices': _selectedServices.toList(),
        'servicePrices': _servicePrices,
        'totalPrice': _totalPrice,
        'totalDiscount': _totalDiscount,
        'quickDescriptions': _selectedQuickDescriptions,
        'customDescription': _customDescription,
        'emergencyPriority': _showEmergencyPriority,
      },
    );
  }

  void _onQuickDescriptionChanged(List<String> descriptions) {
    setState(() {
      _selectedQuickDescriptions = descriptions;
    });
  }

  void _onCustomDescriptionChanged(String? description) {
    setState(() {
      _customDescription = description;
    });
  }

  Widget _buildServiceGrid() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemCount: _serviceConfigurations.length,
      itemBuilder: (context, index) {
        final serviceType = _serviceConfigurations.keys.elementAt(index);
        final config = _serviceConfigurations[serviceType]!;

        if (!config['available']) return const SizedBox.shrink();

        return ServiceSelectionCardWidget(
          serviceType: serviceType,
          serviceName: config['name'],
          iconName: config['icon'],
          basePrice: config['basePrice']?.toDouble() ?? 0.0,
          description: config['description'] ?? '',
          isSelected: _selectedServices.contains(serviceType),
          onTap: () => _toggleService(serviceType),
        );
      },
    );
  }

  Widget _buildEmergencyPriorityToggle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _showEmergencyPriority
            ? AppTheme.lightTheme.colorScheme.error.withAlpha(26)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showEmergencyPriority
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning',
            color: _showEmergencyPriority
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acil Durum Önceliği',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: _showEmergencyPriority
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+25% ek ücret, öncelikli hizmet',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _showEmergencyPriority,
            onChanged: (value) {
              setState(() {
                _showEmergencyPriority = value;
              });
              _calculateTotalPrice();
              HapticFeedback.lightImpact();
            },
            activeColor: AppTheme.lightTheme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hizmet Seçimi',
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
                    'İhtiyacınız olan hizmetleri seçin',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Birden fazla hizmet seçerek indirimi kazanabilirsiniz. Seçtiğiniz hizmetler için tek bir teknisyen gelecektir.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Service selection grid
                  _buildServiceGrid(),

                  SizedBox(height: 3.h),

                  // Emergency priority toggle
                  _buildEmergencyPriorityToggle(),

                  // Service bundling information
                  if (_selectedServices.length >= 2)
                    ServiceBundlingWidget(
                      selectedServices: _selectedServices.toList(),
                      servicePrices: _servicePrices,
                      totalDiscount: _totalDiscount,
                    ),

                  SizedBox(height: 3.h),

                  // Quick description selector
                  if (_selectedServices.isNotEmpty)
                    QuickDescriptionSelectorWidget(
                      selectedServices: _selectedServices.toList(),
                      onDescriptionsChanged: _onQuickDescriptionChanged,
                      onCustomDescriptionChanged: _onCustomDescriptionChanged,
                    ),

                  // Extra spacing to ensure content doesn't get hidden behind the bottom button
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
      // Fixed bottom button using floatingActionButton for better visibility
      floatingActionButton: _selectedServices.isNotEmpty
          ? Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price summary container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.shadowColor.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withAlpha(51),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fiyat Hesabı',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${_selectedServices.length} Hizmet',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Service prices
                        ..._selectedServices.map((serviceType) {
                          final serviceNames = {
                            'towing': 'Çekici',
                            'jumpstart': 'Akü Takviye',
                            'tire_change': 'Lastik Değişimi',
                            'lockout': 'Kapı Açma',
                            'fuel_delivery': 'Yakıt Getirme',
                            'winch_service': 'Vinç Hizmeti',
                          };
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  serviceNames[serviceType] ?? serviceType,
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                                Text(
                                  '₺${_servicePrices[serviceType]?.toStringAsFixed(0) ?? '0'}',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        }),

                        if (_servicePrices.isNotEmpty) ...[
                          Divider(height: 1.5.h, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ara Toplam',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                              Text(
                                '₺${_servicePrices.values.fold(0.0, (sum, price) => sum + price).toStringAsFixed(0)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],

                        if (_totalDiscount > 0) ...[
                          SizedBox(height: 0.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Çoklu Hizmet İndirimi',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '-₺${_totalDiscount.toStringAsFixed(0)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],

                        Divider(height: 1.5.h, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '₺${_totalPrice.toStringAsFixed(0)}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        if (_totalDiscount > 0) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedServices.length} hizmet seçerek ₺${_totalDiscount.toStringAsFixed(0)} tasarruf ettiniz!',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _proceedToLocationConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                        elevation: 4,
                        shadowColor: AppTheme.lightTheme.colorScheme.primary
                            .withAlpha(77),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Konum Onayına Geç',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
