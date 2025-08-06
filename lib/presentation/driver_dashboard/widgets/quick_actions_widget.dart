import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  'Acil Durum',
                  Icons.emergency,
                  Colors.red,
                  () => _showEmergencyDialog(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionItem(
                  'Destek',
                  Icons.support_agent,
                  Colors.blue,
                  () => _callSupport(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionItem(
                  'Konum Paylaş',
                  Icons.share_location,
                  AppTheme.lightTheme.colorScheme.tertiary,
                  () => _shareLocation(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.w),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  'Mola Ver',
                  Icons.pause_circle,
                  Colors.orange,
                  () => _takeBreak(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionItem(
                  'Yakıt İstasyonu',
                  Icons.local_gas_station,
                  Colors.purple,
                  () => _findGasStation(context),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionItem(
                  'Raporla',
                  Icons.report_problem,
                  Colors.amber,
                  () => _reportIssue(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 2.w),
            Text('Acil Durum'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Acil durumunuzun türünü seçin:'),
            SizedBox(height: 2.h),
            _buildEmergencyOption(context, 'Kaza', Icons.car_crash),
            _buildEmergencyOption(
                context, 'Sağlık Sorunu', Icons.local_hospital),
            _buildEmergencyOption(context, 'Araç Arızası', Icons.build),
            _buildEmergencyOption(context, 'Güvenlik', Icons.security),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyOption(
      BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$title acil durumu bildirildi. Destek ekibi bilgilendirildi.'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 20),
            SizedBox(width: 3.w),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _callSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Destek'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Destek ekibi ile iletişime geçmek istediğinizden emin misiniz?'),
            SizedBox(height: 2.h),
            Text(
              'Destek Hattı: 0850 123 45 67',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Destek ekibi aranıyor...'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            },
            child: Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Konum paylaşıldı. Destek ekibi konumunuzu görüyor.'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        action: SnackBarAction(
          label: 'Tamam',
          onPressed: () {},
        ),
      ),
    );
  }

  void _takeBreak(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mola'),
        content: Text(
            'Mola verme moduna geçmek istediğinizden emin misiniz? Bu sürede yeni talep alamazsınız.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mola moduna geçildi. İyi dinlenmeler!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Mola Ver'),
          ),
        ],
      ),
    );
  }

  void _findGasStation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('En yakın yakıt istasyonları gösteriliyor...'),
        backgroundColor: Colors.purple,
        action: SnackBarAction(
          label: 'Navigasyon',
          onPressed: () {
            // Launch navigation to nearest gas station
          },
        ),
      ),
    );
  }

  void _reportIssue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sorun Bildir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hangi konuda sorun yaşıyorsunuz?'),
            SizedBox(height: 2.h),
            _buildIssueOption(context, 'Uygulama Sorunu', Icons.smartphone),
            _buildIssueOption(context, 'Müşteri Sorunu', Icons.person),
            _buildIssueOption(context, 'Ödeme Sorunu', Icons.payment),
            _buildIssueOption(context, 'Diğer', Icons.more_horiz),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueOption(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$title raporu gönderildi. En kısa sürede dönüş yapılacak.'),
            backgroundColor: Colors.amber,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20),
            SizedBox(width: 3.w),
            Text(title),
          ],
        ),
      ),
    );
  }
}
