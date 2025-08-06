import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.onSetDefault,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDefault = paymentMethod['is_default'] == true;
    final cardBrand = paymentMethod['card_brand'] ?? 'card';
    final lastFour = paymentMethod['last_four'] ?? '****';
    final type = paymentMethod['type'] ?? 'card';

    return Container(
        margin: EdgeInsets.only(bottom: 3.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isDefault
                ? Border.all(color: Colors.blue[600]!, width: 2)
                : Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(children: [
          Row(children: [
            // Card Icon
            Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: _getCardColor(cardBrand),
                    borderRadius: BorderRadius.circular(8)),
                child: CustomIconWidget(
                    iconName: _getCardIcon(cardBrand),
                    size: 6.w,
                    color: Colors.white)),
            SizedBox(width: 4.w),

            // Card Details
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text('**** $lastFour',
                        style: GoogleFonts.inter(
                            fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    if (isDefault) ...[
                      SizedBox(width: 2.w),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('DEFAULT',
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white))),
                    ],
                  ]),
                  SizedBox(height: 0.5.h),
                  Text('${_formatCardBrand(cardBrand)} ${_formatType(type)}',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[600])),
                  if (paymentMethod['expiry_month'] != null &&
                      paymentMethod['expiry_year'] != null)
                    Text(
                        'Expires ${paymentMethod['expiry_month']}/${paymentMethod['expiry_year']}',
                        style: GoogleFonts.inter(
                            fontSize: 12.sp, color: Colors.grey[600])),
                ])),

            // Actions
            PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  switch (value) {
                    case 'set_default':
                      onSetDefault();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                      if (!isDefault)
                        const PopupMenuItem(
                            value: 'set_default',
                            child: Text('Set as Default')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Remove')),
                    ]),
          ]),

          // Billing Address (if available)
          if (paymentMethod['billing_city'] != null) ...[
            SizedBox(height: 2.h),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Billing Address',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700])),
                      SizedBox(height: 1.h),
                      Text(_formatBillingAddress(),
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, color: Colors.grey[600])),
                    ])),
          ],
        ]));
  }

  String _getCardIcon(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return 'credit_card';
      case 'mastercard':
        return 'credit_card';
      case 'amex':
      case 'american_express':
        return 'credit_card';
      default:
        return 'credit_card';
    }
  }

  Color _getCardColor(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return Colors.blue[700]!;
      case 'mastercard':
        return Colors.red[700]!;
      case 'amex':
      case 'american_express':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatCardBrand(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
      case 'american_express':
        return 'American Express';
      default:
        return cardBrand.toUpperCase();
    }
  }

  String _formatType(String type) {
    switch (type.toLowerCase()) {
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'digital_wallet':
        return 'Digital Wallet';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatBillingAddress() {
    final parts = <String>[];

    if (paymentMethod['billing_address_line1'] != null) {
      parts.add(paymentMethod['billing_address_line1']);
    }
    if (paymentMethod['billing_city'] != null) {
      parts.add(paymentMethod['billing_city']);
    }
    if (paymentMethod['billing_state'] != null) {
      parts.add(paymentMethod['billing_state']);
    }
    if (paymentMethod['billing_postal_code'] != null) {
      parts.add(paymentMethod['billing_postal_code']);
    }
    if (paymentMethod['billing_country'] != null) {
      parts.add(paymentMethod['billing_country']);
    }

    return parts.join(', ');
  }
}