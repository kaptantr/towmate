import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SystemSettingsTab extends StatefulWidget {
  const SystemSettingsTab({super.key});

  @override
  State<SystemSettingsTab> createState() => _SystemSettingsTabState();
}

class _SystemSettingsTabState extends State<SystemSettingsTab> {
  bool _autoDispatch = true;
  bool _maintenanceMode = false;
  bool _pushNotifications = true;
  bool _smsNotifications = true;
  bool _emailNotifications = false;

  double _searchRadius = 15.0; // km
  int _maxDriversPerRequest = 5;
  int _requestTimeout = 300; // seconds

  String _supportPhoneNumber = '+90 555 123 4567';
  String _supportEmail = 'destek@towmate.com';
  String _companyName = 'TowMate Çekici Hizmetleri';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operational Settings
          _buildSettingsSection(
            'Operasyon Ayarları',
            Icons.settings_applications,
            [
              SwitchListTile(
                title: Text(
                  'Otomatik Görevlendirme',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                    'Yeni talepler en yakın uygun sürücüye otomatik atanır'),
                value: _autoDispatch,
                onChanged: (value) {
                  setState(() {
                    _autoDispatch = value;
                  });
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              SwitchListTile(
                title: Text(
                  'Bakım Modu',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle:
                    const Text('Sistem bakımda - yeni talepler kabul edilmez'),
                value: _maintenanceMode,
                onChanged: (value) {
                  setState(() {
                    _maintenanceMode = value;
                  });
                },
                activeColor: Colors.red,
              ),
              ListTile(
                title: Text(
                  'Arama Yarıçapı',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                    '${_searchRadius.toInt()} km içindeki sürücüler aranır'),
                trailing: SizedBox(
                  width: 30.w,
                  child: Slider(
                    value: _searchRadius,
                    min: 5.0,
                    max: 50.0,
                    divisions: 45,
                    label: '${_searchRadius.toInt()} km',
                    onChanged: (value) {
                      setState(() {
                        _searchRadius = value;
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Maksimum Sürücü Sayısı',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                    'Talep başına $_maxDriversPerRequest sürücüye bildirim gönderilir'),
                trailing: SizedBox(
                  width: 30.w,
                  child: Slider(
                    value: _maxDriversPerRequest.toDouble(),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: '$_maxDriversPerRequest',
                    onChanged: (value) {
                      setState(() {
                        _maxDriversPerRequest = value.toInt();
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Talep Zaman Aşımı',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                    '${(_requestTimeout / 60).toInt()} dakika sonra talep iptal edilir'),
                trailing: SizedBox(
                  width: 30.w,
                  child: Slider(
                    value: _requestTimeout.toDouble(),
                    min: 180.0, // 3 minutes
                    max: 1800.0, // 30 minutes
                    divisions: 29,
                    label: '${(_requestTimeout / 60).toInt()}dk',
                    onChanged: (value) {
                      setState(() {
                        _requestTimeout = value.toInt();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Notification Settings
          _buildSettingsSection(
            'Bildirim Ayarları',
            Icons.notifications,
            [
              SwitchListTile(
                title: Text(
                  'Push Bildirimleri',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Mobil uygulama bildirimleri'),
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              SwitchListTile(
                title: Text(
                  'SMS Bildirimleri',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Önemli durumlar için SMS gönderimi'),
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              SwitchListTile(
                title: Text(
                  'E-posta Bildirimleri',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Günlük raporlar ve özetler'),
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Company Information
          _buildSettingsSection(
            'Şirket Bilgileri',
            Icons.business,
            [
              ListTile(
                title: Text(
                  'Şirket Adı',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(_companyName),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditDialog(
                  'Şirket Adı',
                  _companyName,
                  (value) => setState(() => _companyName = value),
                ),
              ),
              ListTile(
                title: Text(
                  'Destek Telefonu',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(_supportPhoneNumber),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditDialog(
                  'Destek Telefonu',
                  _supportPhoneNumber,
                  (value) => setState(() => _supportPhoneNumber = value),
                ),
              ),
              ListTile(
                title: Text(
                  'Destek E-postası',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(_supportEmail),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditDialog(
                  'Destek E-postası',
                  _supportEmail,
                  (value) => setState(() => _supportEmail = value),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // System Actions
          _buildSettingsSection(
            'Sistem İşlemleri',
            Icons.admin_panel_settings,
            [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.backup,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Veri Yedekleme',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Sistem verilerini yedekle'),
                onTap: () => _showConfirmationDialog(
                  'Veri Yedekleme',
                  'Tüm sistem verileri yedeklenecek. Bu işlem birkaç dakika sürebilir.',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veri yedekleme başlatıldı'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  'Sistem Önbelleğini Temizle',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle:
                    const Text('Performans sorunları için önbelleği temizle'),
                onTap: () => _showConfirmationDialog(
                  'Önbellek Temizleme',
                  'Sistem önbelleği temizlenecek. Bu işlem performansı geçici olarak etkileyebilir.',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sistem önbelleği temizlendi'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restart_alt,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  'Sistemi Yeniden Başlat',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                    'Kritik güncellemeler için sistem yeniden başlatma'),
                onTap: () => _showConfirmationDialog(
                  'Sistem Yeniden Başlatma',
                  'Sistem yeniden başlatılacak. Bu işlem birkaç dakika sürecek ve tüm kullanıcıları etkileyecek.',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sistem yeniden başlatma başlatıldı'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Ayarları Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Simulate saving settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm ayarlar başarıyla kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
