import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();

  PaymentService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Initialize Stripe
  Future<void> initializeStripe() async {
    try {
      // Configure Stripe with publishable key
      Stripe.publishableKey = const String.fromEnvironment(
          'STRIPE_PUBLISHABLE_KEY',
          defaultValue: 'pk_test_mock_key');

      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization failed: $e');
      throw Exception('Payment system initialization failed');
    }
  }

  // Get user's saved payment methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods() async {
    try {
      final response = await _client
          .from('payment_methods')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('is_active', true)
          .order('is_default', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get payment methods error: $error');
      throw Exception('Failed to load payment methods');
    }
  }

  // Add new payment method
  Future<Map<String, dynamic>> addPaymentMethod({
    required String type,
    required String provider,
    String? lastFour,
    String? cardBrand,
    int? expiryMonth,
    int? expiryYear,
    Map<String, String>? billingAddress,
    String? providerPaymentMethodId,
  }) async {
    try {
      final paymentMethodData = {
        'user_id': _client.auth.currentUser!.id,
        'type': type,
        'provider': provider,
        'last_four': lastFour,
        'card_brand': cardBrand,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'provider_payment_method_id': providerPaymentMethodId,
        'is_default': false,
        'is_active': true,
      };

      // Add billing address if provided
      if (billingAddress != null) {
        paymentMethodData.addAll({
          'billing_address_line1': billingAddress['line1'],
          'billing_address_line2': billingAddress['line2'],
          'billing_city': billingAddress['city'],
          'billing_state': billingAddress['state'],
          'billing_postal_code': billingAddress['postal_code'],
          'billing_country': billingAddress['country'] ?? 'TR',
        });
      }

      final response = await _client
          .from('payment_methods')
          .insert(paymentMethodData)
          .select()
          .single();

      return response;
    } catch (error) {
      debugPrint('Add payment method error: $error');
      throw Exception('Failed to add payment method');
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Remove default from all existing methods
      await _client
          .from('payment_methods')
          .update({'is_default': false}).eq('user_id', userId);

      // Set new default
      await _client
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', paymentMethodId)
          .eq('user_id', userId);
    } catch (error) {
      debugPrint('Set default payment method error: $error');
      throw Exception('Failed to set default payment method');
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      await _client
          .from('payment_methods')
          .update({'is_active': false})
          .eq('id', paymentMethodId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      debugPrint('Remove payment method error: $error');
      throw Exception('Failed to remove payment method');
    }
  }

  // Process payment for service request
  Future<Map<String, dynamic>> processPayment({
    required String serviceRequestId,
    required double amount,
    String? paymentMethodId,
    double tipAmount = 0.0,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Get service request details
      final serviceRequest = await _client
          .from('service_requests')
          .select('*, driver_profiles!inner(*)')
          .eq('id', serviceRequestId)
          .eq('customer_id', userId)
          .single();

      final driverId = serviceRequest['driver_id'];
      final platformFee = amount * 0.15; // 15% platform fee
      final driverEarnings = (amount + tipAmount) - platformFee;

      // Create payment record
      final paymentData = {
        'customer_id': userId,
        'driver_id': driverId,
        'service_request_id': serviceRequestId,
        'amount': amount + tipAmount,
        'tip_amount': tipAmount,
        'platform_fee': platformFee,
        'driver_earnings': driverEarnings,
        'payment_method': paymentMethodId != null ? 'card' : 'cash',
        'payment_status': 'pending',
        'payment_gateway': 'stripe'
      };

      final paymentResponse =
          await _client.from('payments').insert(paymentData).select().single();

      // If paying with card, process through Stripe
      if (paymentMethodId != null) {
        await _processStripePayment(
          paymentId: paymentResponse['id'],
          amount: ((amount + tipAmount) * 100).toInt(), // Convert to cents
          paymentMethodId: paymentMethodId,
        );
      } else {
        // Cash payment - mark as completed
        await _client.from('payments').update({
          'payment_status': 'completed',
          'processed_at': DateTime.now().toIso8601String(),
        }).eq('id', paymentResponse['id']);
      }

      return paymentResponse;
    } catch (error) {
      debugPrint('Process payment error: $error');
      throw Exception('Payment processing failed');
    }
  }

  // Process Stripe payment
  Future<void> _processStripePayment({
    required String paymentId,
    required int amount,
    required String paymentMethodId,
  }) async {
    try {
      // Get payment method details
      final paymentMethod = await _client
          .from('payment_methods')
          .select()
          .eq('id', paymentMethodId)
          .single();

      // Create payment intent
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret:
            'pi_mock_client_secret', // In real app, get from backend
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              address: Address(
                city: paymentMethod['billing_city'],
                country: paymentMethod['billing_country'],
                line1: paymentMethod['billing_address_line1'],
                line2: paymentMethod['billing_address_line2'],
                postalCode: paymentMethod['billing_postal_code'],
                state: paymentMethod['billing_state'],
              ),
            ),
          ),
        ),
      );

      // Record successful transaction
      await _recordTransaction(
        paymentId: paymentId,
        transactionType: 'charge',
        amount: amount / 100, // Convert back to currency amount
        status: 'succeeded',
        providerTransactionId: 'txn_mock_success',
      );

      // Update payment status
      await _client.from('payments').update({
        'payment_status': 'completed',
        'processed_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);
    } catch (error) {
      debugPrint('Stripe payment error: $error');

      // Record failed transaction
      await _recordTransaction(
        paymentId: paymentId,
        transactionType: 'charge',
        amount: amount / 100,
        status: 'failed',
        failureReason: error.toString(),
      );

      // Update payment status
      await _client
          .from('payments')
          .update({'payment_status': 'failed'}).eq('id', paymentId);

      throw Exception('Payment processing failed: $error');
    }
  }

  // Record payment transaction
  Future<void> _recordTransaction({
    required String paymentId,
    required String transactionType,
    required double amount,
    required String status,
    String? providerTransactionId,
    String? failureReason,
  }) async {
    try {
      await _client.from('payment_transactions').insert({
        'payment_id': paymentId,
        'transaction_type': transactionType,
        'amount': amount,
        'currency': 'TRY',
        'provider_transaction_id': providerTransactionId,
        'status': status,
        'failure_reason': failureReason,
        'processed_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      debugPrint('Record transaction error: $error');
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('payments')
          .select('''
            *,
            service_requests!inner(
              pickup_location,
              destination_location,
              service_type,
              created_at
            ),
            driver_profiles!inner(
              user_profiles!inner(full_name)
            )
          ''')
          .eq('customer_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get payment history error: $error');
      throw Exception('Failed to load payment history');
    }
  }

  // Calculate service price
  Future<Map<String, double>> calculateServicePrice({
    required String serviceType,
    required double distanceKm,
    required String urgencyLevel,
  }) async {
    try {
      // Get pricing settings
      final baseFeeSetting = await _client
          .from('system_settings')
          .select('setting_value')
          .eq('setting_key', 'base_service_fee')
          .single();

      final distanceRateSetting = await _client
          .from('system_settings')
          .select('setting_value')
          .eq('setting_key', 'distance_rate_per_km')
          .single();

      final emergencyMultiplierSetting = await _client
          .from('system_settings')
          .select('setting_value')
          .eq('setting_key', 'emergency_service_multiplier')
          .single();

      double baseFee =
          (baseFeeSetting['setting_value']['amount'] as num).toDouble();
      double distanceRate =
          (distanceRateSetting['setting_value']['amount'] as num).toDouble();
      double emergencyMultiplier = urgencyLevel == 'emergency'
          ? (emergencyMultiplierSetting['setting_value']['multiplier'] as num)
              .toDouble()
          : 1.0;

      double subtotal =
          (baseFee + (distanceKm * distanceRate)) * emergencyMultiplier;
      double platformFee = subtotal * 0.15;
      double total = subtotal + platformFee;

      return {
        'base_fee': baseFee,
        'distance_cost': distanceKm * distanceRate,
        'emergency_multiplier_cost':
            (subtotal / emergencyMultiplier) * (emergencyMultiplier - 1),
        'subtotal': subtotal,
        'platform_fee': platformFee,
        'total': total,
      };
    } catch (error) {
      debugPrint('Calculate price error: $error');
      throw Exception('Failed to calculate service price');
    }
  }

  // Refund payment
  Future<void> refundPayment({
    required String paymentId,
    double? refundAmount,
    String? reason,
  }) async {
    try {
      // Get payment details
      final payment =
          await _client.from('payments').select().eq('id', paymentId).single();

      final refundAmountFinal = refundAmount ?? payment['amount'];

      // Record refund transaction
      await _recordTransaction(
        paymentId: paymentId,
        transactionType: 'refund',
        amount: refundAmountFinal,
        status: 'succeeded',
        providerTransactionId: 'rfnd_mock_success',
      );

      // Update payment status
      await _client
          .from('payments')
          .update({'payment_status': 'refunded'}).eq('id', paymentId);
    } catch (error) {
      debugPrint('Refund payment error: $error');
      throw Exception('Refund processing failed');
    }
  }
}