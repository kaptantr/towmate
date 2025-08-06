import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriceCalculationWidget extends StatelessWidget {
  final List<String> selectedServices;
  final Map<String, double> servicePrices;
  final double totalPrice;
  final double totalDiscount;
  final bool emergencyPriority;

  const PriceCalculationWidget({
    Key? key,
    required this.selectedServices,
    required this.servicePrices,
    required this.totalPrice,
    required this.totalDiscount,
    required this.emergencyPriority,
  }) : super(key: key);

  String _getServiceDisplayName(String serviceType) {
    const serviceNames = {
      'towing': 'Çekici',
      'jumpstart': 'Akü Takviye',
      'tire_change': 'Lastik Değişimi',
      'lockout': 'Kapı Açma',
      'fuel_delivery': 'Yakıt Getirme',
      'winch_service': 'Vinç Hizmeti',
    };
    return serviceNames[serviceType] ?? serviceType;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal =
        servicePrices.values.fold(0.0, (sum, price) => sum + price);
    final emergencySurcharge = emergencyPriority ? subtotal * 0.25 : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'receipt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Fiyat Hesabı',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedServices.length} Hizmet',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Service breakdown
          ...selectedServices.map((serviceType) {
            final price = servicePrices[serviceType] ?? 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 0.5.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getServiceDisplayName(serviceType),
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '₺${price.toStringAsFixed(0)}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Subtotal
          Divider(height: 2.h),
          Row(
            children: [
              Text(
                'Ara Toplam',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '₺${subtotal.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Multi-service discount
          if (totalDiscount > 0) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'discount',
                  color: Colors.green,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Çoklu Hizmet İndirimi',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  '-₺${totalDiscount.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Emergency surcharge
          if (emergencyPriority && emergencySurcharge > 0) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Acil Durum Önceliği (+25%)',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                const Spacer(),
                Text(
                  '+₺${emergencySurcharge.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Total
          Divider(height: 2.h),
          Row(
            children: [
              Text(
                'Toplam',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '₺${totalPrice.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Discount savings message
          if (totalDiscount > 0) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'savings',
                    color: Colors.green,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      '${selectedServices.length} hizmet seçerek ₺${totalDiscount.toStringAsFixed(0)} tasarruf ettiniz!',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
