import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyContactButton extends StatelessWidget {
  final VoidCallback onEmergencyCall;

  const EmergencyContactButton({
    Key? key,
    required this.onEmergencyCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.h,
      right: 4.w,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEmergencyDialog(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 15.w,
              height: 15.w,
              child: Center(
                child: CustomIconWidget(
                  iconName: 'emergency',
                  color: AppTheme.lightTheme.colorScheme.onError,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Acil Durum',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acil bir durumla mı karşılaştınız?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Aşağıdaki seçeneklerden birini kullanabilirsiniz:',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _callPolice();
              },
              child: Text(
                '155 Polis',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEmergencyCall();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: Text('112 Acil'),
            ),
          ],
        );
      },
    );
  }

  void _callPolice() {
    // In a real app, this would use url_launcher to call 155
    // For now, we'll show a toast
    // Fluttertoast.showToast(msg: "155 Polis aranıyor...");
  }
}
