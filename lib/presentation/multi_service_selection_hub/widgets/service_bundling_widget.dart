import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ServiceBundlingWidget extends StatelessWidget {
  final List<String> selectedServices;
  final Map<String, double> servicePrices;
  final double totalDiscount;

  const ServiceBundlingWidget({
    Key? key,
    required this.selectedServices,
    required this.servicePrices,
    required this.totalDiscount,
  }) : super(key: key);

  String _getBundleMessage() {
    final count = selectedServices.length;
    if (count >= 4) {
      return 'Muhteşem! 4+ hizmet seçimi ile %20 indirim kazandınız';
    } else if (count >= 3) {
      return 'Harika! 3 hizmet seçimi ile %15 indirim kazandınız';
    } else if (count >= 2) {
      return 'Tebrikler! 2 hizmet seçimi ile %10 indirim kazandınız';
    }
    return '';
  }

  Color _getBundleColor() {
    final count = selectedServices.length;
    if (count >= 4) {
      return Colors.purple;
    } else if (count >= 3) {
      return Colors.orange;
    }
    return Colors.green;
  }

  IconData _getBundleIcon() {
    final count = selectedServices.length;
    if (count >= 4) {
      return Icons.military_tech;
    } else if (count >= 3) {
      return Icons.star;
    }
    return Icons.local_offer;
  }

  List<Widget> _buildServiceIndicators() {
    return selectedServices.map((serviceType) {
      final serviceNames = {
        'towing': 'Çekici',
        'jumpstart': 'Akü',
        'tire_change': 'Lastik',
        'lockout': 'Kapı',
        'fuel_delivery': 'Yakıt',
        'winch_service': 'Vinç',
      };

      return Container(
        margin: EdgeInsets.only(right: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: _getBundleColor().withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBundleColor().withAlpha(77),
          ),
        ),
        child: Text(
          serviceNames[serviceType] ?? serviceType,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: _getBundleColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedServices.length < 2 || totalDiscount <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getBundleColor().withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBundleColor().withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getBundleColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBundleIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hizmet Paketi İndirimi',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: _getBundleColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getBundleMessage(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getBundleColor().withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getBundleColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-₺${totalDiscount.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Service indicators
          Row(
            children: [
              Text(
                'Seçilen Hizmetler:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            children: _buildServiceIndicators(),
          ),

          SizedBox(height: 2.h),

          // Benefits information
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  'Tek teknisyen tüm hizmetleri gerçekleştirir',
                  Icons.person,
                ),
                SizedBox(height: 1.h),
                _buildBenefitItem(
                  'Aynı seferde tüm sorunlar çözülür',
                  Icons.check_circle,
                ),
                SizedBox(height: 1.h),
                _buildBenefitItem(
                  'Zamandan ve paradan tasarruf edin',
                  Icons.access_time,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: _getBundleColor(),
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
