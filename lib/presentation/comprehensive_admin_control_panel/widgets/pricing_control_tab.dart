import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PricingControlTab extends StatefulWidget {
  const PricingControlTab({super.key});

  @override
  State<PricingControlTab> createState() => _PricingControlTabState();
}

class _PricingControlTabState extends State<PricingControlTab> {
  List<Map<String, dynamic>> _pricingConfig = [];
  bool _isLoading = false;
  bool _surgeActive = false;
  double _surgeMultiplier = 1.5;

  final Map<String, String> _serviceTypeLabels = {
    'towing': 'Çekici Hizmeti',
    'jumpstart': 'Akü Takviye',
    'tire_change': 'Lastik Değişimi',
    'lockout': 'Kapı Açma',
    'fuel_delivery': 'Yakıt Getirme',
    'winch_service': 'Vinç Hizmeti',
  };

  @override
  void initState() {
    super.initState();
    _loadPricingConfig();
  }

  Future<void> _loadPricingConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock pricing configuration data
      _pricingConfig = [
        {
          'service_type': 'towing',
          'base_price': 100.00,
          'price_per_km': 8.50,
          'minimum_price': 150.00,
          'is_active': true,
        },
        {
          'service_type': 'jumpstart',
          'base_price': 80.00,
          'price_per_km': 0.00,
          'minimum_price': 80.00,
          'is_active': true,
        },
        {
          'service_type': 'tire_change',
          'base_price': 120.00,
          'price_per_km': 0.00,
          'minimum_price': 120.00,
          'is_active': true,
        },
        {
          'service_type': 'lockout',
          'base_price': 90.00,
          'price_per_km': 0.00,
          'minimum_price': 90.00,
          'is_active': true,
        },
        {
          'service_type': 'fuel_delivery',
          'base_price': 70.00,
          'price_per_km': 5.00,
          'minimum_price': 100.00,
          'is_active': true,
        },
        {
          'service_type': 'winch_service',
          'base_price': 150.00,
          'price_per_km': 12.00,
          'minimum_price': 200.00,
          'is_active': false,
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Fiyat bilgileri yüklenirken hata oluştu: ${e.toString()}'),
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

  void _showPriceEditDialog(Map<String, dynamic> pricing) {
    final TextEditingController basePriceController =
        TextEditingController(text: pricing['base_price'].toString());
    final TextEditingController pricePerKmController =
        TextEditingController(text: pricing['price_per_km'].toString());
    final TextEditingController minimumPriceController =
        TextEditingController(text: pricing['minimum_price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_serviceTypeLabels[pricing['service_type']]} Fiyat Düzenle',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: basePriceController,
                decoration: const InputDecoration(
                  labelText: 'Temel Fiyat (₺)',
                  hintText: '100.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: pricePerKmController,
                decoration: const InputDecoration(
                  labelText: 'Kilometre Başına Fiyat (₺)',
                  hintText: '8.50',
                  prefixIcon: Icon(Icons.route),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: minimumPriceController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Fiyat (₺)',
                  hintText: '150.00',
                  prefixIcon: Icon(Icons.price_change),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiyat Hesaplama Önizlemesi:',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '5 km için: ₺${_calculatePrice(double.tryParse(basePriceController.text) ?? 0, double.tryParse(pricePerKmController.text) ?? 0, double.tryParse(minimumPriceController.text) ?? 0, 5).toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    Text(
                      '15 km için: ₺${_calculatePrice(double.tryParse(basePriceController.text) ?? 0, double.tryParse(pricePerKmController.text) ?? 0, double.tryParse(minimumPriceController.text) ?? 0, 15).toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update pricing configuration
              setState(() {
                final pricingIndex = _pricingConfig.indexWhere(
                    (p) => p['service_type'] == pricing['service_type']);
                if (pricingIndex != -1) {
                  _pricingConfig[pricingIndex]['base_price'] =
                      double.tryParse(basePriceController.text) ?? 0.0;
                  _pricingConfig[pricingIndex]['price_per_km'] =
                      double.tryParse(pricePerKmController.text) ?? 0.0;
                  _pricingConfig[pricingIndex]['minimum_price'] =
                      double.tryParse(minimumPriceController.text) ?? 0.0;
                }
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fiyat yapılandırması güncellendi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  double _calculatePrice(double basePrice, double pricePerKm,
      double minimumPrice, double distance) {
    double totalPrice = basePrice + (pricePerKm * distance);
    return totalPrice > minimumPrice ? totalPrice : minimumPrice;
  }

  void _showSurgeSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yoğunluk Fiyatlandırması'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Yoğunluk Çarpanı Aktif'),
              subtitle: const Text('Yoğun saatlerde otomatik fiyat artışı'),
              value: _surgeActive,
              onChanged: (value) {
                setState(() {
                  _surgeActive = value;
                });
              },
            ),
            if (_surgeActive) ...[
              SizedBox(height: 2.h),
              Text('Çarpan: ${_surgeMultiplier.toStringAsFixed(1)}x'),
              Slider(
                value: _surgeMultiplier,
                min: 1.0,
                max: 3.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _surgeMultiplier = value;
                  });
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_surgeActive
                      ? 'Yoğunluk fiyatlandırması ${_surgeMultiplier.toStringAsFixed(1)}x ile aktif edildi'
                      : 'Yoğunluk fiyatlandırması deaktif edildi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPricingConfig,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Surge Pricing Control
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'trending_up',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Yoğunluk Fiyatlandırması',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _surgeActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _surgeActive ? 'Aktif' : 'Pasif',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _surgeActive
                        ? 'Yoğun zamanlarda fiyatlar ${_surgeMultiplier.toStringAsFixed(1)}x artırılacak'
                        : 'Yoğunluk tabanlı fiyat artışı şu anda deaktif',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showSurgeSettingsDialog,
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Yoğunluk Ayarları'),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Service Pricing List
            Text(
              'Servis Fiyatlandırması',
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pricingConfig.length,
                itemBuilder: (context, index) {
                  final pricing = _pricingConfig[index];
                  final serviceType = pricing['service_type'] as String;

                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pricing['is_active']
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.shadowColor
                              .withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _serviceTypeLabels[serviceType] ?? serviceType,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: pricing['is_active']
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: pricing['is_active']
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pricing['is_active'] ? 'Aktif' : 'Pasif',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        // Pricing Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriceItem(
                                'Temel Fiyat',
                                '₺${pricing['base_price'].toStringAsFixed(2)}',
                                Icons.price_change,
                              ),
                            ),
                            Expanded(
                              child: _buildPriceItem(
                                'Km Başına',
                                '₺${pricing['price_per_km'].toStringAsFixed(2)}',
                                Icons.route,
                              ),
                            ),
                            Expanded(
                              child: _buildPriceItem(
                                'Minimum',
                                '₺${pricing['minimum_price'].toStringAsFixed(2)}',
                                Icons.money,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        // Price Examples
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Örnek Fiyatlar:',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '5 km: ₺${_calculatePrice(pricing['base_price'], pricing['price_per_km'], pricing['minimum_price'], 5).toStringAsFixed(2)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                              Text(
                                '15 km: ₺${_calculatePrice(pricing['base_price'], pricing['price_per_km'], pricing['minimum_price'], 15).toStringAsFixed(2)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Edit Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showPriceEditDialog(pricing),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Fiyat Düzenle'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
