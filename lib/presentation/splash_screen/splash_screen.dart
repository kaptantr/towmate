import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Başlatılıyor...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo scale animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Fade animation for smooth transition
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate checking authentication status
      setState(() {
        _initializationStatus = 'Kimlik doğrulanıyor...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate loading user preferences
      setState(() {
        _initializationStatus = 'Kullanıcı tercihleri yükleniyor...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // Simulate fetching driver availability
      setState(() {
        _initializationStatus = 'Sürücü durumu kontrol ediliyor...';
      });
      await Future.delayed(const Duration(milliseconds: 700));

      // Simulate preparing location services
      setState(() {
        _initializationStatus = 'Konum servisleri hazırlanıyor...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isInitializing = false;
        _initializationStatus = 'Hazır!';
      });

      // Wait a moment before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      // Start fade out animation
      await _fadeAnimationController.forward();

      // Navigate based on user status (mock logic)
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors
      setState(() {
        _initializationStatus = 'Bağlantı hatası - Yeniden deneniyor...';
      });

      // Retry after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      _initializeApp();
    }
  }

  void _navigateToNextScreen() {
    // Mock navigation logic - in real app, this would check actual auth status
    final bool isAuthenticated = false; // Mock value
    final bool isDriver = false; // Mock value

    if (isAuthenticated) {
      if (isDriver) {
        Navigator.pushReplacementNamed(context, '/driver-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/customer-service-request');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryLight,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryLight,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.primaryVariantLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo section
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _logoScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Logo
                                    Container(
                                      width: 25.w,
                                      height: 25.w,
                                      decoration: BoxDecoration(
                                        color: AppTheme.onPrimaryLight,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CustomIconWidget(
                                          iconName: 'local_shipping',
                                          color: AppTheme.primaryLight,
                                          size: 12.w,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 3.h),

                                    // App Name
                                    Text(
                                      'TowMate',
                                      style: AppTheme
                                          .lightTheme.textTheme.displaySmall
                                          ?.copyWith(
                                        color: AppTheme.onPrimaryLight,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                      ),
                                    ),

                                    SizedBox(height: 1.h),

                                    // Tagline
                                    Text(
                                      'Güvenilir Çekici Hizmeti',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: AppTheme.onPrimaryLight
                                            .withValues(alpha: 0.8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Loading section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Loading indicator
                            SizedBox(
                              width: 8.w,
                              height: 8.w,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.onPrimaryLight,
                                ),
                                strokeWidth: 3.0,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Status text
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _initializationStatus,
                                key: ValueKey(_initializationStatus),
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.onPrimaryLight
                                      .withValues(alpha: 0.9),
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom section with version info
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Column(
                          children: [
                            Text(
                              'Versiyon 1.0.0',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.onPrimaryLight
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '© 2024 TowMate. Tüm hakları saklıdır.',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.onPrimaryLight
                                    .withValues(alpha: 0.5),
                                fontSize: 10.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
