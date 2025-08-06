import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentMethodCardWidget extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final VoidCallback onRemove;

  const PaymentMethodCardWidget({
    Key? key,
    required this.paymentMethod,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDefault = paymentMethod["isDefault"] as bool;
    final String type = paymentMethod["type"] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: isDefault
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: isDefault ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: _getCardColor(type),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getCardIcon(type),
                color: Colors.white,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      paymentMethod["name"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    isDefault ? SizedBox(width: 2.w) : const SizedBox.shrink(),
                    isDefault
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.tertiary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              "Varsayılan",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  paymentMethod["details"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: onRemove,
                icon: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 5.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'digital_wallet':
        return AppTheme.lightTheme.primaryColor;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
      case 'mastercard':
        return 'credit_card';
      case 'digital_wallet':
        return 'account_balance_wallet';
      default:
        return 'payment';
    }
  }
}
