import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/driver_profile_card.dart';
import './widgets/driver_status_indicator.dart';
import './widgets/emergency_contact_button.dart';
import './widgets/messaging_overlay.dart';
import './widgets/rating_modal.dart';

class DriverMatchingAndTracking extends StatefulWidget {
  @override
  State<DriverMatchingAndTracking> createState() =>
      _DriverMatchingAndTrackingState();
}

class _DriverMatchingAndTrackingState extends State<DriverMatchingAndTracking>
    with TickerProviderStateMixin {
  String _currentStatus = 'matching';
  Map<String, dynamic>? _assignedDriver;
  String? _estimatedArrival;
  bool _showMessaging = false;
  Timer? _statusTimer;
  Timer? _etaTimer;

  // Mock data for driver and messages
  final List<Map<String, dynamic>> _mockDrivers = [
    {
      "id": 1,
      "name": "Mehmet Yılmaz",
      "photo":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "rating": 4.8,
      "reviewCount": 127,
      "vehicleType": "Çekici Kamyon",
      "plateNumber": "34 ABC 123",
      "isVerified": true,
      "phone": "+90 555 123 4567",
      "location": {"lat": 41.0082, "lng": 28.9784}
    },
    {
      "id": 2,
      "name": "Ali Demir",
      "photo":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "rating": 4.6,
      "reviewCount": 89,
      "vehicleType": "Hafif Çekici",
      "plateNumber": "06 XYZ 789",
      "isVerified": true,
      "phone": "+90 555 987 6543",
      "location": {"lat": 41.0122, "lng": 28.9834}
    }
  ];

  List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Merhaba, size doğru geliyorum. Yaklaşık 15 dakika içinde orada olacağım.",
      "isFromUser": false,
      "time": "14:32",
      "timestamp": DateTime.now().subtract(Duration(minutes: 10))
    },
    {
      "text": "Teşekkürler, bekliyorum.",
      "isFromUser": true,
      "time": "14:33",
      "timestamp": DateTime.now().subtract(Duration(minutes: 9))
    }
  ];

  @override
  void initState() {
    super.initState();
    _startMatchingProcess();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  void _startMatchingProcess() {
    // Simulate driver matching process
    _statusTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentStatus = 'matched';
          _assignedDriver = _mockDrivers[0];
          _estimatedArrival = '15 dakika';
        });

        // Start ETA updates
        _startEtaUpdates();

        // Simulate status progression
        _simulateStatusProgression();
      }
    });
  }

  void _startEtaUpdates() {
    _etaTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted && _estimatedArrival != null) {
        setState(() {
          // Simulate ETA countdown
          final currentMinutes =
              int.tryParse(_estimatedArrival!.split(' ')[0]) ?? 15;
          if (currentMinutes > 1) {
            _estimatedArrival = '${currentMinutes - 1} dakika';
          } else {
            _estimatedArrival = '1 dakika';
          }
        });
      }
    });
  }

  void _simulateStatusProgression() {
    Timer(Duration(seconds: 10), () {
      if (mounted) setState(() => _currentStatus = 'en_route_to_customer');
    });

    Timer(Duration(seconds: 20), () {
      if (mounted) setState(() => _currentStatus = 'arrived');
    });

    Timer(Duration(seconds: 30), () {
      if (mounted) setState(() => _currentStatus = 'loading_vehicle');
    });

    Timer(Duration(seconds: 40), () {
      if (mounted) setState(() => _currentStatus = 'en_route_to_destination');
    });

    Timer(Duration(seconds: 50), () {
      if (mounted) {
        setState(() => _currentStatus = 'completed');
        _showRatingModal();
      }
    });
  }

  void _callDriver() {
    if (_assignedDriver != null) {
      // In a real app, this would use url_launcher to make a phone call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_assignedDriver!['phone']} aranıyor...'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
        ),
      );
    }
  }

  void _openMessaging() {
    setState(() {
      _showMessaging = true;
    });
  }

  void _hideMessaging() {
    setState(() {
      _showMessaging = false;
    });
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({
        "text": message,
        "isFromUser": true,
        "time":
            "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        "timestamp": DateTime.now()
      });
    });

    // Simulate driver response
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "text": "Mesajınızı aldım, teşekkürler.",
            "isFromUser": false,
            "time":
                "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
            "timestamp": DateTime.now()
          });
        });
      }
    });
  }

  void _cancelRequest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Talebi İptal Et',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Çekici talebinizi iptal etmek istediğinizden emin misiniz?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hayır'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: Text('Evet, İptal Et'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RatingModal(
          driverName: _assignedDriver?['name'] ?? 'Sürücü',
          onSubmitRating: (rating, feedback) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Değerlendirmeniz kaydedildi. Teşekkürler!'),
                backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            );
            // Navigate back after rating
            Timer(Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });
          },
          onSkip: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleEmergencyCall() {
    // In a real app, this would use url_launcher to call 112
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('112 Acil Servis aranıyor...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.lightTheme.colorScheme.surface,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'map',
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                    size: 120,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Harita Yükleniyor...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status indicator
          SafeArea(
            child: Column(
              children: [
                DriverStatusIndicator(
                  status: _currentStatus,
                  eta: _estimatedArrival,
                ),
              ],
            ),
          ),

          // Emergency contact button
          EmergencyContactButton(
            onEmergencyCall: _handleEmergencyCall,
          ),

          // Cancel button (only show before completion)
          if (_currentStatus != 'completed')
            Positioned(
              top: 12.h,
              left: 4.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _cancelRequest,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 15.w,
                      height: 15.w,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Driver profile card (show when driver is assigned)
          if (_assignedDriver != null && _currentStatus != 'matching')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DriverProfileCard(
                driverData: _assignedDriver!,
                onCallDriver: _callDriver,
                onMessageDriver: () => setState(() {
                  _showMessaging = true;
                }),
              ),
            ),

          // Messaging overlay
          if (_showMessaging)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MessagingOverlay(
                driverName: _assignedDriver?['name'] ?? 'Sürücü',
                messages: _messages,
                onSendMessage: _sendMessage,
                onClose: _hideMessaging,
              ),
            ),

          // Loading overlay for matching
          if (_currentStatus == 'matching')
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Sürücü Aranıyor...',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Size en yakın sürücüyü buluyoruz',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
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
