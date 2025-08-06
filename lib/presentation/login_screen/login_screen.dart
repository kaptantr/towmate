import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  late TabController _tabController;
  int _selectedUserType = 0; // 0: Customer, 1: Tow/Driver, 2: Admin

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'customer': {
      'email': 'customer@towmate.com',
      'password': 'customer123',
      'type': 'customer'
    },
    'driver': {
      'email': 'driver@towmate.com',
      'password': 'driver123',
      'type': 'driver'
    },
    'admin': {
      'email': 'admin@towmate.com',
      'password': 'admin123',
      'type': 'admin'
    }
  };

  final List<String> _userTypes = ['customer', 'driver', 'admin'];
  final List<String> _userTypeLabels = ['Müşteri', 'Sürücü', 'Admin'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedUserType = _tabController.index;
        });
        _fillDemoCredentials();
      }
    });
    // Fill demo credentials for initial user type (Customer)
    _fillDemoCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    final userType = _userTypes[_selectedUserType];
    final credentials = _mockCredentials[userType]!;

    setState(() {
      _emailController.text = credentials['email']!;
      _passwordController.text = credentials['password']!;
      _emailError = null;
      _passwordError = null;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^(\+90|0)?[5][0-9]{9}$')
        .hasMatch(phone.replaceAll(' ', ''));
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'E-posta veya telefon gerekli';
      } else if (!_isValidEmail(value) && !_isValidPhone(value)) {
        _emailError = 'Geçerli bir e-posta veya telefon girin';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Şifre gerekli';
      } else if (value.length < 6) {
        _passwordError = 'Şifre en az 6 karakter olmalı';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() ||
        _emailError != null ||
        _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Check mock credentials
    bool isValidCredentials = false;
    String userType = '';

    for (var credentials in _mockCredentials.values) {
      if ((_emailController.text.trim() == credentials['email'] ||
              _emailController.text.trim() ==
                  credentials['email']!.split('@')[0]) &&
          _passwordController.text == credentials['password']) {
        isValidCredentials = true;
        userType = credentials['type']!;
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (isValidCredentials) {
      // Navigate based on user type
      if (userType == 'customer') {
        Navigator.pushReplacementNamed(
            context, AppRoutes.multiServiceSelectionHub);
      } else if (userType == 'driver') {
        Navigator.pushReplacementNamed(context, AppRoutes.driverDashboard);
      } else if (userType == 'admin') {
        Navigator.pushReplacementNamed(
            context, AppRoutes.comprehensiveAdminControlPanel);
      }
    } else {
      _showErrorDialog(
          'Geçersiz kimlik bilgileri. Lütfen e-posta/telefon ve şifrenizi kontrol edin.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Giriş Hatası',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Navigate based on selected user type
    if (_selectedUserType == 0) {
      // Customer - Navigate to multi-service selection hub
      Navigator.pushReplacementNamed(
          context, AppRoutes.multiServiceSelectionHub);
    } else if (_selectedUserType == 1) {
      // Driver
      Navigator.pushReplacementNamed(context, AppRoutes.driverDashboard);
    } else {
      // Admin - Navigate to comprehensive admin control panel
      Navigator.pushReplacementNamed(
          context, AppRoutes.comprehensiveAdminControlPanel);
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Şifremi Unuttum',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Şifre sıfırlama bağlantısı e-posta adresinize gönderilecek.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style:
                  TextStyle(color: AppTheme.lightTheme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre sıfırlama bağlantısı gönderildi!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Logo Section
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'local_shipping',
                      color: Colors.white,
                      size: 12.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Welcome Text
                Text(
                  'TowMate\'e Hoş Geldiniz',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                Text(
                  'Kullanıcı tipinizi seçin ve giriş yapın',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 3.h),

                // User Type Selection Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme
                        .lightTheme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    labelStyle:
                        AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle:
                        AppTheme.lightTheme.textTheme.titleSmall,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.person, size: 5.w),
                        text: 'Müşteri',
                      ),
                      Tab(
                        icon: Icon(Icons.local_shipping, size: 5.w),
                        text: 'Sürücü',
                      ),
                      Tab(
                        icon: Icon(Icons.admin_panel_settings, size: 5.w),
                        text: 'Admin',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Demo Credentials Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Demo Hesabı - Test için hazır!',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Seçtiğiniz kullanıcı tipine göre demo bilgileri otomatik dolduruldu. Doğrudan giriş yapabilir veya kendi bilgilerinizi girebilirsiniz.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Email/Phone Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: _validateEmail,
                      decoration: InputDecoration(
                        labelText: 'E-posta veya Telefon',
                        hintText: 'ornek@email.com veya 05XX XXX XX XX',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          onPressed: _fillDemoCredentials,
                          tooltip: 'Demo bilgileri yükle',
                        ),
                        errorText: _emailError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bu alan gerekli';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: _validatePassword,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: 'Şifrenizi girin',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        errorText: _passwordError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bu alan gerekli';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text(
                          'Beni Hatırla',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        'Şifremi Unuttum?',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            '${_userTypeLabels[_selectedUserType]} Girişi',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Divider with "veya" text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'veya',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Social Login Buttons
                Column(
                  children: [
                    // Google Login
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('google'),
                        icon: CustomImageWidget(
                          imageUrl:
                              'https://developers.google.com/identity/images/g-logo.png',
                          width: 5.w,
                          height: 5.w,
                          fit: BoxFit.contain,
                        ),
                        label: Text(
                          'Google ile Giriş Yap',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Apple Login (iOS style)
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('apple'),
                        icon: CustomIconWidget(
                          iconName: 'apple',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 5.w,
                        ),
                        label: Text(
                          'Apple ile Giriş Yap',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Facebook Login
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('facebook'),
                        icon: CustomIconWidget(
                          iconName: 'facebook',
                          color: const Color(0xFF1877F2),
                          size: 5.w,
                        ),
                        label: Text(
                          'Facebook ile Giriş Yap',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yeni kullanıcı mısınız? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up screen (not implemented in this scope)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kayıt ekranı yakında eklenecek!'),
                          ),
                        );
                      },
                      child: Text(
                        'Kayıt Ol',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
