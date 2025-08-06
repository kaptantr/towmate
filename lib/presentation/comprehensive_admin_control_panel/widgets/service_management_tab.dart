import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceManagementTab extends StatefulWidget {
  const ServiceManagementTab({super.key});

  @override
  State<ServiceManagementTab> createState() => _ServiceManagementTabState();
}

class _ServiceManagementTabState extends State<ServiceManagementTab> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;

  final Map<String, String> _serviceTypeLabels = {
    'towing': 'Çekici Hizmeti',
    'jumpstart': 'Akü Takviye',
    'tire_change': 'Lastik Değişimi',
    'lockout': 'Kapı Açma',
    'fuel_delivery': 'Yakıt Getirme',
    'winch_service': 'Vinç Hizmeti',
  };

  final Map<String, String> _serviceIcons = {
    'towing': 'local_shipping',
    'jumpstart': 'battery_charging_full',
    'tire_change': 'tire_repair',
    'lockout': 'lock_open',
    'fuel_delivery': 'local_gas_station',
    'winch_service': 'construction',
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock service data with realistic configuration
      _services = [
        {
          'id': 'towing',
          'service_type': 'towing',
          'is_active': true,
          'display_order': 1,
          'service_description':
              'Profesyonel çekici hizmeti - aracınızı güvenle istediğiniz yere taşıyoruz',
          'estimated_duration_minutes': 45,
          'required_certification': 'Çekici Lisansı',
          'equipment_needed': 'Çekici Kamyonu, Güvenlik Ekipmanları',
          'availability_schedule': '7/24 Hizmet',
        },
        {
          'id': 'jumpstart',
          'service_type': 'jumpstart',
          'is_active': true,
          'display_order': 2,
          'service_description':
              'Akü takviye servisi - boşalan aküyünüzü hemen şarj ediyoruz',
          'estimated_duration_minutes': 15,
          'required_certification': 'Temel Elektrik Bilgisi',
          'equipment_needed': 'Akü Takviye Kabloları, Multimetre',
          'availability_schedule': '7/24 Hizmet',
        },
        {
          'id': 'tire_change',
          'service_type': 'tire_change',
          'is_active': true,
          'display_order': 3,
          'service_description':
              'Lastik değişimi - patlak lastiğinizi yeni lastik ile değiştiriyoruz',
          'estimated_duration_minutes': 25,
          'required_certification': 'Lastik Montaj Sertifikası',
          'equipment_needed': 'Kriko, Bijon Anahtarı, Yedek Lastik',
          'availability_schedule': '06:00 - 24:00',
        },
        {
          'id': 'lockout',
          'service_type': 'lockout',
          'is_active': true,
          'display_order': 4,
          'service_description':
              'Kapı açma servisi - aracınızın kilitli kapısını hasar vermeden açıyoruz',
          'estimated_duration_minutes': 20,
          'required_certification': 'Oto Kilitçi Sertifikası',
          'equipment_needed': 'Kapı Açma Kit, Güvenlik Araçları',
          'availability_schedule': '7/24 Hizmet',
        },
        {
          'id': 'fuel_delivery',
          'service_type': 'fuel_delivery',
          'is_active': true,
          'display_order': 5,
          'service_description':
              'Yakıt getirme - bulunduğunuz yere yakıt getiriyoruz',
          'estimated_duration_minutes': 30,
          'required_certification': 'Yakıt Taşıma Belgesi',
          'equipment_needed': 'Güvenli Yakıt Bidonu, Huni',
          'availability_schedule': '08:00 - 22:00',
        },
        {
          'id': 'winch_service',
          'service_type': 'winch_service',
          'is_active': false,
          'display_order': 6,
          'service_description':
              'Vinç hizmeti - sıkışan aracınızı güvenle çıkarıyoruz',
          'estimated_duration_minutes': 60,
          'required_certification': 'Vinç Operatörü Lisansı',
          'equipment_needed': 'Vinç Kamyonu, Güvenlik Donanımları',
          'availability_schedule': '08:00 - 20:00',
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Servisler yüklenirken hata oluştu: ${e.toString()}'),
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

  Future<void> _toggleServiceStatus(String serviceId, bool newStatus) async {
    try {
      setState(() {
        final serviceIndex = _services.indexWhere((s) => s['id'] == serviceId);
        if (serviceIndex != -1) {
          _services[serviceIndex]['is_active'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Servis durumu ${newStatus ? 'aktif' : 'pasif'} olarak güncellendi',
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Durum güncellenirken hata oluştu: ${e.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _showServiceEditDialog(Map<String, dynamic> service) {
    final TextEditingController descriptionController =
        TextEditingController(text: service['service_description']);
    final TextEditingController durationController = TextEditingController(
        text: service['estimated_duration_minutes'].toString());
    final TextEditingController certificationController =
        TextEditingController(text: service['required_certification']);
    final TextEditingController equipmentController =
        TextEditingController(text: service['equipment_needed']);
    final TextEditingController scheduleController =
        TextEditingController(text: service['availability_schedule']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_serviceTypeLabels[service['service_type']]} Düzenle',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Servis Açıklaması',
                  hintText: 'Müşterilere gösterilecek açıklama',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Tahmini Süre (dakika)',
                  hintText: '30',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: certificationController,
                decoration: const InputDecoration(
                  labelText: 'Gerekli Sertifika',
                  hintText: 'Sürücü için gerekli sertifika',
                ),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: equipmentController,
                decoration: const InputDecoration(
                  labelText: 'Gerekli Ekipmanlar',
                  hintText: 'İhtiyaç duyulan araç ve gereçler',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Çalışma Saatleri',
                  hintText: '7/24 Hizmet veya 08:00 - 20:00',
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
              // Update service configuration
              setState(() {
                final serviceIndex =
                    _services.indexWhere((s) => s['id'] == service['id']);
                if (serviceIndex != -1) {
                  _services[serviceIndex]['service_description'] =
                      descriptionController.text;
                  _services[serviceIndex]['estimated_duration_minutes'] =
                      int.tryParse(durationController.text) ?? 30;
                  _services[serviceIndex]['required_certification'] =
                      certificationController.text;
                  _services[serviceIndex]['equipment_needed'] =
                      equipmentController.text;
                  _services[serviceIndex]['availability_schedule'] =
                      scheduleController.text;
                }
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Servis ayarları güncellendi'),
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
      onRefresh: _loadServices,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                final serviceType = service['service_type'] as String;

                return Container(
                  margin: EdgeInsets.only(bottom: 3.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: service['is_active']
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.shadowColor
                            .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Service Header
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: service['is_active']
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: service['is_active']
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomIconWidget(
                                iconName: _serviceIcons[serviceType] ?? 'build',
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _serviceTypeLabels[serviceType] ??
                                              serviceType,
                                          style: AppTheme
                                              .lightTheme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: service['is_active']
                                                ? AppTheme.lightTheme
                                                    .colorScheme.primary
                                                : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.w, vertical: 0.5.h),
                                        decoration: BoxDecoration(
                                          color: service['is_active']
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          service['is_active']
                                              ? 'Aktif'
                                              : 'Pasif',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    service['service_description'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Service Details
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          children: [
                            _buildDetailRow('Tahmini Süre',
                                '${service['estimated_duration_minutes']} dakika'),
                            _buildDetailRow(
                                'Gerekli Sertifika',
                                service['required_certification'] ??
                                    'Belirtilmemiş'),
                            _buildDetailRow('Gerekli Ekipmanlar',
                                service['equipment_needed'] ?? 'Belirtilmemiş'),
                            _buildDetailRow(
                                'Çalışma Saatleri',
                                service['availability_schedule'] ??
                                    '7/24 Hizmet'),

                            SizedBox(height: 2.h),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showServiceEditDialog(service),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Düzenle'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _toggleServiceStatus(
                                        service['id'], !service['is_active']),
                                    icon: Icon(
                                      service['is_active']
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 18,
                                    ),
                                    label: Text(service['is_active']
                                        ? 'Deaktif Et'
                                        : 'Aktif Et'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: service['is_active']
                                          ? Colors.red
                                          : AppTheme
                                              .lightTheme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
