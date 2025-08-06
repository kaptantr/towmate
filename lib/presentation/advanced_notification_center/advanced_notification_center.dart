import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

import './widgets/emergency_notification_overlay.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_filter_widget.dart';
import './widgets/notification_search_widget.dart';
import './widgets/notification_settings_widget.dart';

class AdvancedNotificationCenter extends StatefulWidget {
  const AdvancedNotificationCenter({Key? key}) : super(key: key);

  @override
  State<AdvancedNotificationCenter> createState() =>
      _AdvancedNotificationCenterState();
}

class _AdvancedNotificationCenterState extends State<AdvancedNotificationCenter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GoogleTranslator translator = GoogleTranslator();
  final SpeechToText _speechToText = SpeechToText();

  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _showOnlyUnread = false;
  bool _isListening = false;
  bool _hasEmergencyNotification = false;
  String _selectedLanguage = 'en';

  List<Map<String, dynamic>> _notifications = [];
  List<String> _categories = [
    'all',
    'service_updates',
    'system_alerts',
    'promotions',
    'emergency'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeNotifications();
    _loadNotifications();
    _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Firebase messaging setup
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingMessage(message);
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.microphone.request();
  }

  void _handleIncomingMessage(RemoteMessage message) {
    if (message.data['priority'] == 'emergency') {
      setState(() {
        _hasEmergencyNotification = true;
      });
    }

    setState(() {
      _notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? 'New Notification',
        'body': message.notification?.body ?? '',
        'category': message.data['category'] ?? 'system_alerts',
        'priority': message.data['priority'] ?? 'medium',
        'timestamp': DateTime.now(),
        'isRead': false,
        'hasMedia': message.data['hasMedia'] == 'true',
        'actionRequired': message.data['actionRequired'] == 'true',
      });
    });
  }

  void _loadNotifications() {
    // Mock notification data for demonstration
    _notifications = [
      {
        'id': '1',
        'title': 'New Service Request',
        'body':
            'A customer needs towing service in downtown area. Tap to view details.',
        'category': 'service_updates',
        'priority': 'high',
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'isRead': false,
        'hasMedia': true,
        'actionRequired': true,
        'location': {'lat': 41.0082, 'lng': 28.978},
      },
      {
        'id': '2',
        'title': 'System Maintenance',
        'body':
            'Scheduled maintenance will occur tonight from 2:00 AM to 4:00 AM.',
        'category': 'system_alerts',
        'priority': 'medium',
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        'isRead': true,
        'hasMedia': false,
        'actionRequired': false,
      },
      {
        'id': '3',
        'title': 'Payment Received',
        'body': '₺450 payment received for service request #TR-2024-001',
        'category': 'service_updates',
        'priority': 'medium',
        'timestamp': DateTime.now().subtract(Duration(hours: 3)),
        'isRead': false,
        'hasMedia': false,
        'actionRequired': false,
      },
      {
        'id': '4',
        'title': 'Emergency Alert',
        'body': 'Weather warning: Heavy snow expected. Drive carefully.',
        'category': 'emergency',
        'priority': 'emergency',
        'timestamp': DateTime.now().subtract(Duration(hours: 1)),
        'isRead': false,
        'hasMedia': false,
        'actionRequired': true,
      },
    ];
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _searchQuery = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    try {
      var translation = await translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      return text; // Return original text if translation fails
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    return _notifications.where((notification) {
      bool matchesCategory = _selectedCategory == 'all' ||
          notification['category'] == _selectedCategory;
      bool matchesSearch = _searchQuery.isEmpty ||
          notification['title']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          notification['body']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      bool matchesUnread = !_showOnlyUnread || !notification['isRead'];

      return matchesCategory && matchesSearch && matchesUnread;
    }).toList();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      int index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _dismissEmergencyNotification() {
    setState(() {
      _hasEmergencyNotification = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Notification Center',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => NotificationSettingsWidget(
                  selectedLanguage: _selectedLanguage,
                  onLanguageChanged: (language) {
                    setState(() {
                      _selectedLanguage = language;
                    });
                  },
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(140.h),
          child: Column(
            children: [
              NotificationSearchWidget(
                searchQuery: _searchQuery,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                isListening: _isListening,
                onVoiceSearch: _isListening ? _stopListening : _startListening,
              ),
              NotificationFilterWidget(
                categories: _categories,
                selectedCategory: _selectedCategory,
                showOnlyUnread: _showOnlyUnread,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                onUnreadToggle: (value) {
                  setState(() {
                    _showOnlyUnread = value;
                  });
                },
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Service'),
                  Tab(text: 'System'),
                  Tab(text: 'Promos'),
                  Tab(text: 'Emergency'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList('service_updates'),
              _buildNotificationList('system_alerts'),
              _buildNotificationList('promotions'),
              _buildNotificationList('emergency'),
            ],
          ),
          if (_hasEmergencyNotification)
            EmergencyNotificationOverlay(
              onDismiss: _dismissEmergencyNotification,
              notification: _notifications.firstWhere(
                (n) => n['priority'] == 'emergency',
                orElse: () => {},
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mark all as read
          setState(() {
            for (var notification in _notifications) {
              notification['isRead'] = true;
            }
          });
        },
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.done_all, color: Colors.white),
      ),
    );
  }

  Widget _buildNotificationList(String category) {
    List<Map<String, dynamic>> categoryNotifications = _filteredNotifications
        .where((n) => category == 'all' || n['category'] == category)
        .toList();

    if (categoryNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No notifications',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadNotifications();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: categoryNotifications.length,
        itemBuilder: (context, index) {
          final notification = categoryNotifications[index];
          return NotificationCardWidget(
            notification: notification,
            onTap: () => _markAsRead(notification['id']),
            onTranslate: (text) => _translateText(text, _selectedLanguage),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
