import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/notification_toggle_widget.dart';
import './widgets/payment_method_card_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/vehicle_info_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Mehmet Yılmaz",
    "email": "mehmet.yilmaz@email.com",
    "phone": "+90 532 123 45 67",
    "profileImage":
        "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400",
    "rating": 4.8,
    "memberSince": "Ocak 2022",
    "userType": "driver", // "customer" or "driver"
  };

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "id": 1,
      "type": "visa",
      "name": "Visa",
      "details": "**** **** **** 1234",
      "isDefault": true,
    },
    {
      "id": 2,
      "type": "mastercard",
      "name": "Mastercard",
      "details": "**** **** **** 5678",
      "isDefault": false,
    },
    {
      "id": 3,
      "type": "digital_wallet",
      "name": "Dijital Cüzdan",
      "details": "mehmet.yilmaz@email.com",
      "isDefault": false,
    },
  ];

  final List<Map<String, dynamic>> emergencyContacts = [
    {
      "id": 1,
      "name": "Ayşe Yılmaz",
      "phone": "+90 532 987 65 43",
      "relationship": "Eş",
    },
    {
      "id": 2,
      "name": "Ali Yılmaz",
      "phone": "+90 533 456 78 90",
      "relationship": "Kardeş",
    },
  ];

  final Map<String, dynamic> vehicleData = {
    "brand": "Mercedes",
    "model": "Sprinter",
    "licensePlate": "34 ABC 123",
    "type": "Hafif Ticari",
    "year": 2020,
    "capacity": 3.5,
    "status": "Aktif",
  };

  // Notification settings
  Map<String, bool> notificationSettings = {
    "serviceUpdates": true,
    "promotionalOffers": false,
    "driverCommunications": true,
    "emergencyAlerts": true,
    "paymentNotifications": true,
  };

  // App preferences
  Map<String, dynamic> appPreferences = {
    "darkMode": false,
    "soundEnabled": true,
    "language": "Türkçe",
    "biometricEnabled": true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profil Ayarları",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 6.w,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Profil"),
          ],
          labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: AppTheme.lightTheme.colorScheme.onPrimary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Profile Header
          ProfileHeaderWidget(
            userData: userData,
            onEditPressed: _showEditProfileDialog,
          ),

          SizedBox(height: 3.h),

          // Personal Information
          SettingsSectionWidget(
            title: "Kişisel Bilgiler",
            children: [
              SettingsItemWidget(
                iconName: 'person',
                title: "Ad Soyad",
                subtitle: userData["name"] as String,
                onTap: _showEditNameDialog,
              ),
              SettingsItemWidget(
                iconName: 'email',
                title: "E-posta",
                subtitle: userData["email"] as String,
                onTap: _showEditEmailDialog,
              ),
              SettingsItemWidget(
                iconName: 'phone',
                title: "Telefon",
                subtitle: userData["phone"] as String,
                onTap: _showEditPhoneDialog,
                showDivider: false,
              ),
            ],
          ),

          // Payment Methods
          SettingsSectionWidget(
            title: "Ödeme Yöntemleri",
            children: [
              ...(paymentMethods as List)
                  .map((method) => PaymentMethodCardWidget(
                        paymentMethod: method as Map<String, dynamic>,
                        onRemove: () =>
                            _removePaymentMethod(method["id"] as int),
                      ))
                  .toList(),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddPaymentMethodDialog,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                  label: Text("Yeni Ödeme Yöntemi Ekle"),
                ),
              ),
            ],
          ),

          // Vehicle Information (Driver only)
          userData["userType"] == "driver"
              ? SettingsSectionWidget(
                  title: "Araç Bilgileri",
                  children: [
                    VehicleInfoWidget(
                      vehicleData: vehicleData,
                      onEdit: _showEditVehicleDialog,
                    ),
                    SizedBox(height: 2.h),
                    SettingsItemWidget(
                      iconName: 'description',
                      title: "Belgeler",
                      subtitle: "Sürücü belgesi, ruhsat ve sigorta",
                      onTap: _showDocumentsScreen,
                    ),
                    SettingsItemWidget(
                      iconName: 'analytics',
                      title: "Kazanç Ayarları",
                      subtitle: "Günlük kazanç hedefleri ve raporlar",
                      onTap: _showEarningsSettings,
                      showDivider: false,
                    ),
                  ],
                )
              : const SizedBox.shrink(),

          // Notification Preferences
          SettingsSectionWidget(
            title: "Bildirim Tercihleri",
            children: [
              NotificationToggleWidget(
                title: "Servis Güncellemeleri",
                subtitle: "Sipariş durumu ve sürücü bilgilendirmeleri",
                value: notificationSettings["serviceUpdates"]!,
                onChanged: (value) =>
                    _updateNotificationSetting("serviceUpdates", value),
              ),
              NotificationToggleWidget(
                title: "Promosyon Teklifleri",
                subtitle: "İndirimler ve özel kampanyalar",
                value: notificationSettings["promotionalOffers"]!,
                onChanged: (value) =>
                    _updateNotificationSetting("promotionalOffers", value),
              ),
              NotificationToggleWidget(
                title: "Sürücü İletişimi",
                subtitle: "Sürücüden gelen mesajlar ve aramalar",
                value: notificationSettings["driverCommunications"]!,
                onChanged: (value) =>
                    _updateNotificationSetting("driverCommunications", value),
              ),
              NotificationToggleWidget(
                title: "Acil Durum Uyarıları",
                subtitle: "Güvenlik ve acil durum bildirimleri",
                value: notificationSettings["emergencyAlerts"]!,
                onChanged: (value) =>
                    _updateNotificationSetting("emergencyAlerts", value),
              ),
              NotificationToggleWidget(
                title: "Ödeme Bildirimleri",
                subtitle: "Ödeme onayları ve fatura bilgilendirmeleri",
                value: notificationSettings["paymentNotifications"]!,
                onChanged: (value) =>
                    _updateNotificationSetting("paymentNotifications", value),
              ),
            ],
          ),

          // Privacy Settings
          SettingsSectionWidget(
            title: "Gizlilik Ayarları",
            children: [
              SettingsItemWidget(
                iconName: 'location_on',
                title: "Konum Paylaşımı",
                subtitle: "Servis sırasında konum bilgisi paylaşımı",
                trailing: Switch(
                  value: true,
                  onChanged: (value) => _showLocationSharingDialog(),
                ),
                onTap: _showLocationSharingDialog,
              ),
              SettingsItemWidget(
                iconName: 'data_usage',
                title: "Veri Kullanımı",
                subtitle: "Uygulama veri kullanım tercihleri",
                onTap: _showDataUsageSettings,
              ),
              SettingsItemWidget(
                iconName: 'campaign',
                title: "Pazarlama İletişimi",
                subtitle: "E-posta ve SMS pazarlama izinleri",
                onTap: _showMarketingSettings,
                showDivider: false,
              ),
            ],
          ),

          // Emergency Contacts
          SettingsSectionWidget(
            title: "Acil Durum Kişileri",
            children: [
              ...(emergencyContacts as List)
                  .map((contact) => EmergencyContactWidget(
                        contact: contact as Map<String, dynamic>,
                        onEdit: () =>
                            _editEmergencyContact(contact["id"] as int),
                        onRemove: () =>
                            _removeEmergencyContact(contact["id"] as int),
                      ))
                  .toList(),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddEmergencyContactDialog,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                  label: Text("Acil Durum Kişisi Ekle"),
                ),
              ),
            ],
          ),

          // App Preferences
          SettingsSectionWidget(
            title: "Uygulama Tercihleri",
            children: [
              SettingsItemWidget(
                iconName: 'dark_mode',
                title: "Karanlık Mod",
                subtitle: "Gece görünümü için karanlık tema",
                trailing: Switch(
                  value: appPreferences["darkMode"] as bool,
                  onChanged: (value) => _updateAppPreference("darkMode", value),
                ),
                onTap: () => _updateAppPreference(
                    "darkMode", !(appPreferences["darkMode"] as bool)),
              ),
              SettingsItemWidget(
                iconName: 'volume_up',
                title: "Ses Ayarları",
                subtitle: "Bildirim sesleri ve titreşim",
                trailing: Switch(
                  value: appPreferences["soundEnabled"] as bool,
                  onChanged: (value) =>
                      _updateAppPreference("soundEnabled", value),
                ),
                onTap: () => _updateAppPreference(
                    "soundEnabled", !(appPreferences["soundEnabled"] as bool)),
              ),
              SettingsItemWidget(
                iconName: 'language',
                title: "Dil",
                subtitle: appPreferences["language"] as String,
                onTap: _showLanguageSelection,
              ),
              SettingsItemWidget(
                iconName: 'accessibility',
                title: "Erişilebilirlik",
                subtitle: "Görme ve işitme destekleri",
                onTap: _showAccessibilitySettings,
                showDivider: false,
              ),
            ],
          ),

          // Account Actions
          SettingsSectionWidget(
            title: "Hesap İşlemleri",
            children: [
              SettingsItemWidget(
                iconName: 'lock',
                title: "Şifre Değiştir",
                subtitle: "Hesap güvenliği için şifrenizi güncelleyin",
                onTap: _showChangePasswordDialog,
              ),
              SettingsItemWidget(
                iconName: 'fingerprint',
                title: "Biyometrik Güvenlik",
                subtitle: "Parmak izi veya yüz tanıma ile giriş",
                trailing: Switch(
                  value: appPreferences["biometricEnabled"] as bool,
                  onChanged: (value) =>
                      _updateAppPreference("biometricEnabled", value),
                ),
                onTap: () => _updateAppPreference("biometricEnabled",
                    !(appPreferences["biometricEnabled"] as bool)),
              ),
              SettingsItemWidget(
                iconName: 'delete_forever',
                title: "Hesabı Sil",
                subtitle: "Hesabınızı kalıcı olarak silin",
                iconColor: AppTheme.lightTheme.colorScheme.error,
                onTap: _showDeleteAccountDialog,
                showDivider: false,
              ),
            ],
          ),

          // Support
          SettingsSectionWidget(
            title: "Destek",
            children: [
              SettingsItemWidget(
                iconName: 'help',
                title: "Sık Sorulan Sorular",
                subtitle: "Yaygın sorunlar ve çözümleri",
                onTap: _showFAQ,
              ),
              SettingsItemWidget(
                iconName: 'contact_support',
                title: "İletişim",
                subtitle: "Müşteri hizmetleri ile iletişime geçin",
                onTap: _showContactSupport,
              ),
              SettingsItemWidget(
                iconName: 'feedback',
                title: "Geri Bildirim",
                subtitle: "Uygulama hakkında görüşlerinizi paylaşın",
                onTap: _showFeedbackForm,
                showDivider: false,
              ),
            ],
          ),

          // Version and Legal
          SettingsSectionWidget(
            title: "Hakkında",
            children: [
              SettingsItemWidget(
                iconName: 'info',
                title: "Versiyon",
                subtitle: "TowMate v1.2.3",
                onTap: null,
              ),
              SettingsItemWidget(
                iconName: 'description',
                title: "Kullanım Koşulları",
                subtitle: "Hizmet şartları ve koşulları",
                onTap: _showTermsOfService,
              ),
              SettingsItemWidget(
                iconName: 'privacy_tip',
                title: "Gizlilik Politikası",
                subtitle: "Veri koruma ve gizlilik bilgileri",
                onTap: _showPrivacyPolicy,
                showDivider: false,
              ),
            ],
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // Dialog and action methods
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Profil Fotoğrafını Düzenle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w),
              title: Text("Kamera"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage("Kamera açılıyor...");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'photo_library',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w),
              title: Text("Galeri"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage("Galeri açılıyor...");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final TextEditingController controller =
        TextEditingController(text: userData["name"] as String);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ad Soyad Düzenle"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Ad Soyad",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["name"] = controller.text;
              });
              Navigator.pop(context);
              _showSuccessMessage("Ad soyad güncellendi");
            },
            child: Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final TextEditingController controller =
        TextEditingController(text: userData["email"] as String);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("E-posta Düzenle"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "E-posta",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["email"] = controller.text;
              });
              Navigator.pop(context);
              _showSuccessMessage("E-posta güncellendi");
            },
            child: Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog() {
    final TextEditingController controller =
        TextEditingController(text: userData["phone"] as String);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Telefon Düzenle"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Telefon",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData["phone"] = controller.text;
              });
              Navigator.pop(context);
              _showSuccessMessage("Telefon numarası güncellendi");
            },
            child: Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _removePaymentMethod(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ödeme Yöntemini Sil"),
        content: Text("Bu ödeme yöntemini silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                paymentMethods
                    .removeWhere((method) => (method["id"] as int) == id);
              });
              Navigator.pop(context);
              _showSuccessMessage("Ödeme yöntemi silindi");
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error),
            child: Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ödeme Yöntemi Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'credit_card',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w),
              title: Text("Kredi/Banka Kartı"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage("Kart ekleme sayfası açılıyor...");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w),
              title: Text("Dijital Cüzdan"),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage("Dijital cüzdan bağlantısı kuruluyor...");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditVehicleDialog() {
    _showSuccessMessage("Araç bilgileri düzenleme sayfası açılıyor...");
  }

  void _showDocumentsScreen() {
    _showSuccessMessage("Belgeler sayfası açılıyor...");
  }

  void _showEarningsSettings() {
    _showSuccessMessage("Kazanç ayarları sayfası açılıyor...");
  }

  void _updateNotificationSetting(String key, bool value) {
    setState(() {
      notificationSettings[key] = value;
    });
    _showSuccessMessage("Bildirim ayarı güncellendi");
  }

  void _showLocationSharingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konum Paylaşımı"),
        content: Text(
            "Servis sırasında konumunuz sürücü ile paylaşılacaktır. Bu ayarı değiştirmek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage("Konum paylaşım ayarı güncellendi");
            },
            child: Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  void _showDataUsageSettings() {
    _showSuccessMessage("Veri kullanım ayarları sayfası açılıyor...");
  }

  void _showMarketingSettings() {
    _showSuccessMessage("Pazarlama iletişim ayarları sayfası açılıyor...");
  }

  void _editEmergencyContact(int id) {
    _showSuccessMessage("Acil durum kişisi düzenleme sayfası açılıyor...");
  }

  void _removeEmergencyContact(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Acil Durum Kişisini Sil"),
        content: Text(
            "Bu kişiyi acil durum listesinden çıkarmak istediğinizden emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                emergencyContacts
                    .removeWhere((contact) => (contact["id"] as int) == id);
              });
              Navigator.pop(context);
              _showSuccessMessage("Acil durum kişisi silindi");
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error),
            child: Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _showAddEmergencyContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController relationshipController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Acil Durum Kişisi Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Ad Soyad",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Telefon",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: relationshipController,
              decoration: InputDecoration(
                labelText: "Yakınlık",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                setState(() {
                  emergencyContacts.add({
                    "id": emergencyContacts.length + 1,
                    "name": nameController.text,
                    "phone": phoneController.text,
                    "relationship": relationshipController.text.isEmpty
                        ? "Yakın"
                        : relationshipController.text,
                  });
                });
                Navigator.pop(context);
                _showSuccessMessage("Acil durum kişisi eklendi");
              }
            },
            child: Text("Ekle"),
          ),
        ],
      ),
    );
  }

  void _updateAppPreference(String key, dynamic value) {
    setState(() {
      appPreferences[key] = value;
    });
    _showSuccessMessage("Uygulama ayarı güncellendi");
  }

  void _showLanguageSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Dil Seçimi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Türkçe"),
              trailing: appPreferences["language"] == "Türkçe"
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w)
                  : null,
              onTap: () {
                setState(() {
                  appPreferences["language"] = "Türkçe";
                });
                Navigator.pop(context);
                _showSuccessMessage("Dil Türkçe olarak ayarlandı");
              },
            ),
            ListTile(
              title: Text("English"),
              trailing: appPreferences["language"] == "English"
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 5.w)
                  : null,
              onTap: () {
                setState(() {
                  appPreferences["language"] = "English";
                });
                Navigator.pop(context);
                _showSuccessMessage("Language set to English");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessibilitySettings() {
    _showSuccessMessage("Erişilebilirlik ayarları sayfası açılıyor...");
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Şifre Değiştir"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mevcut Şifre",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Yeni Şifre",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Yeni Şifre Tekrar",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newController.text == confirmController.text &&
                  newController.text.isNotEmpty) {
                Navigator.pop(context);
                _showSuccessMessage("Şifre başarıyla değiştirildi");
              } else {
                _showErrorMessage("Şifreler eşleşmiyor");
              }
            },
            child: Text("Değiştir"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hesabı Sil"),
        content: Text(
            "Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showErrorMessage("Hesap silme işlemi iptal edildi");
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error),
            child: Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    _showSuccessMessage("Sık sorulan sorular sayfası açılıyor...");
  }

  void _showContactSupport() {
    _showSuccessMessage("Müşteri hizmetleri ile iletişim kuruluyor...");
  }

  void _showFeedbackForm() {
    _showSuccessMessage("Geri bildirim formu açılıyor...");
  }

  void _showTermsOfService() {
    _showSuccessMessage("Kullanım koşulları sayfası açılıyor...");
  }

  void _showPrivacyPolicy() {
    _showSuccessMessage("Gizlilik politikası sayfası açılıyor...");
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
