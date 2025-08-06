import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/payment_service.dart';

class AddPaymentMethodDialog extends StatefulWidget {
  final VoidCallback onPaymentMethodAdded;

  const AddPaymentMethodDialog({
    Key? key,
    required this.onPaymentMethodAdded,
  }) : super(key: key);

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedType = 'credit_card';
  String _selectedCountry = 'TR';
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Payment Method',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Type
                      Text(
                        'Payment Type',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: _inputDecoration('Select payment type'),
                        items: const [
                          DropdownMenuItem(
                              value: 'credit_card', child: Text('Credit Card')),
                          DropdownMenuItem(
                              value: 'debit_card', child: Text('Debit Card')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                        validator: (value) =>
                            value == null ? 'Please select payment type' : null,
                      ),
                      SizedBox(height: 3.h),

                      // Card Number
                      Text(
                        'Card Number',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: _inputDecoration('1234 5678 9012 3456'),
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        onChanged: _formatCardNumber,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.replaceAll(' ', '').length < 13) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),

                      // Expiry and CVV
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expiry Date',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  controller: _expiryController,
                                  decoration: _inputDecoration('MM/YY'),
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  onChanged: _formatExpiry,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 5) {
                                      return 'Invalid format';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CVV',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  controller: _cvvController,
                                  decoration: _inputDecoration('123'),
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'Invalid CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Card Holder Name
                      Text(
                        'Card Holder Name',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _cardHolderController,
                        decoration: _inputDecoration('Enter name on card'),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card holder name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Billing Address
                      Text(
                        'Billing Address',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      TextFormField(
                        controller: _addressLine1Controller,
                        decoration: _inputDecoration('Address Line 1'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: _inputDecoration('City'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: _inputDecoration('Postal Code'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Add Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addPaymentMethod,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Add Payment Method',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[600]!),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      counterText: '',
    );
  }

  void _formatCardNumber(String value) {
    String formatted = value.replaceAll(' ', '');
    String newValue = '';

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) {
        newValue += ' ';
      }
      newValue += formatted[i];
    }

    _cardNumberController.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
  }

  void _formatExpiry(String value) {
    String formatted = value.replaceAll('/', '');
    String newValue = '';

    for (int i = 0; i < formatted.length && i < 4; i++) {
      if (i == 2) {
        newValue += '/';
      }
      newValue += formatted[i];
    }

    _expiryController.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Extract expiry month and year
      final expiryParts = _expiryController.text.split('/');
      final expiryMonth = int.parse(expiryParts[0]);
      final expiryYear = 2000 + int.parse(expiryParts[1]);

      // Determine card brand from card number
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final cardBrand = _getCardBrand(cardNumber);
      final lastFour = cardNumber.substring(cardNumber.length - 4);

      await PaymentService.instance.addPaymentMethod(
        type: _selectedType,
        provider: 'stripe',
        lastFour: lastFour,
        cardBrand: cardBrand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        billingAddress: {
          'line1': _addressLine1Controller.text,
          'city': _cityController.text,
          'postal_code': _postalCodeController.text,
          'country': _selectedCountry,
        },
        providerPaymentMethodId:
            'pm_mock_${DateTime.now().millisecondsSinceEpoch}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method added successfully')),
      );

      widget.onPaymentMethodAdded();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'amex';
    }
    return 'unknown';
  }
}
