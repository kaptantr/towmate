import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/add_payment_method_dialog.dart';
import './widgets/payment_history_item.dart';
import './widgets/payment_method_card.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({Key? key}) : super(key: key);

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final methods = await PaymentService.instance.getUserPaymentMethods();
      final history = await PaymentService.instance.getPaymentHistory();

      setState(() {
        _paymentMethods = methods;
        _paymentHistory = history;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment data: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: Text('Payment Management',
                style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            backgroundColor: Colors.blue[600],
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Payment Methods'),
                  Tab(text: 'Payment History'),
                ])),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(controller: _tabController, children: [
                _buildPaymentMethodsTab(),
                _buildPaymentHistoryTab(),
              ]));
  }

  Widget _buildPaymentMethodsTab() {
    return Column(children: [
      // Add Payment Method Button
      Container(
          width: double.infinity,
          margin: EdgeInsets.all(4.w),
          child: ElevatedButton.icon(
              onPressed: _showAddPaymentMethodDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add Payment Method',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))))),

      // Payment Methods List
      Expanded(
          child: _paymentMethods.isEmpty
              ? _buildEmptyState('No payment methods added yet')
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod = _paymentMethods[index];
                    return PaymentMethodCard(
                        paymentMethod: paymentMethod,
                        onSetDefault: () =>
                            _setDefaultPaymentMethod(paymentMethod['id']),
                        onDelete: () =>
                            _deletePaymentMethod(paymentMethod['id']));
                  })),
    ]);
  }

  Widget _buildPaymentHistoryTab() {
    if (_paymentHistory.isEmpty) {
      return _buildEmptyState('No payment history found');
    }

    return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _paymentHistory.length,
        itemBuilder: (context, index) {
          final payment = _paymentHistory[index];
          return PaymentHistoryItem(
              payment: payment, onTap: () => _showPaymentDetails(payment));
        });
  }

  Widget _buildEmptyState(String message) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(size: 20.w, color: Colors.grey[400], iconName: 'payment'),
      SizedBox(height: 2.h),
      Text(message,
          style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
          textAlign: TextAlign.center),
    ]));
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
        context: context,
        builder: (context) => AddPaymentMethodDialog(onPaymentMethodAdded: () {
              Navigator.pop(context);
              _loadData();
            }));
  }

  Future<void> _setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await PaymentService.instance.setDefaultPaymentMethod(paymentMethodId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default payment method updated')));
      _loadData();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Remove Payment Method'),
                content: const Text(
                    'Are you sure you want to remove this payment method?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Remove',
                          style: TextStyle(color: Colors.white))),
                ]));

    if (confirmed == true) {
      try {
        await PaymentService.instance.removePaymentMethod(paymentMethodId);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment method removed')));
        _loadData();
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
            height: 70.h,
            padding: EdgeInsets.all(6.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Handle bar
              Center(
                  child: Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 3.h),

              // Title
              Text('Payment Details',
                  style: GoogleFonts.inter(
                      fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 3.h),

              // Payment Information
              _buildDetailRow('Amount', '₺${payment['amount']}'),
              _buildDetailRow('Status', payment['payment_status']),
              _buildDetailRow('Method', payment['payment_method']),
              if (payment['tip_amount'] > 0)
                _buildDetailRow('Tip', '₺${payment['tip_amount']}'),
              _buildDetailRow('Platform Fee', '₺${payment['platform_fee']}'),
              _buildDetailRow('Date', _formatDate(payment['created_at'])),

              SizedBox(height: 3.h),

              // Service Information
              Text('Service Details',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 2.h),

              _buildDetailRow(
                  'Service Type', payment['service_requests']['service_type']),
              _buildDetailRow(
                  'From', payment['service_requests']['pickup_location']),
              _buildDetailRow(
                  'To', payment['service_requests']['destination_location']),
            ])));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[600])),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14.sp, fontWeight: FontWeight.w500)),
        ]));
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}