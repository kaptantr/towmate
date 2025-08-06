import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CommunicationCenterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> drivers;
  final Function(String, List<String>) onMessageSent;
  final Function(String) onEmergencyAlert;

  const CommunicationCenterWidget({
    super.key,
    required this.drivers,
    required this.onMessageSent,
    required this.onEmergencyAlert,
  });

  @override
  State<CommunicationCenterWidget> createState() =>
      _CommunicationCenterWidgetState();
}

class _CommunicationCenterWidgetState extends State<CommunicationCenterWidget> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  List<String> _selectedDrivers = [];
  String _messageType = 'general';
  bool _scheduleMessage = false;
  DateTime? _scheduledTime;

  @override
  void dispose() {
    _messageController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildBroadcastMessaging(),
          SizedBox(height: 16.h),
          _buildEmergencyAlerts(),
          SizedBox(height: 16.h),
          _buildShiftScheduling(),
          SizedBox(height: 16.h),
          _buildCommunicationHistory(),
        ]));
  }

  Widget _buildBroadcastMessaging() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Broadcast Messaging',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),

          // Message Type Selection
          Row(children: [
            Text('Message Type:',
                style: GoogleFonts.inter(
                    fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
            SizedBox(width: 12.w),
            Expanded(
                child: DropdownButton<String>(
                    value: _messageType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'general', child: Text('General Update')),
                      DropdownMenuItem(
                          value: 'operational',
                          child: Text('Operational Notice')),
                      DropdownMenuItem(
                          value: 'weather', child: Text('Weather Alert')),
                      DropdownMenuItem(
                          value: 'traffic', child: Text('Traffic Update')),
                      DropdownMenuItem(
                          value: 'policy', child: Text('Policy Change')),
                    ],
                    onChanged: (value) =>
                        setState(() => _messageType = value!))),
          ]),

          SizedBox(height: 12.h),

          // Driver Selection
          Text('Recipients:',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
          SizedBox(height: 8.h),
          Container(
              constraints: BoxConstraints(maxHeight: 120.h),
              child: SingleChildScrollView(
                  child: Column(children: [
                CheckboxListTile(
                    title: const Text('All Drivers'),
                    value: _selectedDrivers.length == widget.drivers.length,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedDrivers = widget.drivers
                              .map((d) => d['id'].toString())
                              .toList();
                        } else {
                          _selectedDrivers.clear();
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero),
                ...widget.drivers.map((driver) {
                  final driverId = driver['id'].toString();
                  return CheckboxListTile(
                      title: Text(
                          driver['user_profiles']?['full_name'] ??
                              'Unknown Driver',
                          style: GoogleFonts.inter(fontSize: 14.sp)),
                      subtitle: Text(
                          'Status: ${driver['current_status']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                          style: GoogleFonts.inter(fontSize: 12.sp)),
                      value: _selectedDrivers.contains(driverId),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedDrivers.add(driverId);
                          } else {
                            _selectedDrivers.remove(driverId);
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 16.w));
                }).toList(),
              ]))),

          SizedBox(height: 12.h),

          // Message Content
          TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                  labelText: 'Message Content',
                  hintText: 'Enter your message here...',
                  border: OutlineInputBorder())),

          SizedBox(height: 12.h),

          // Schedule Option
          Row(children: [
            Checkbox(
                value: _scheduleMessage,
                onChanged: (value) =>
                    setState(() => _scheduleMessage = value!)),
            Text('Schedule Message', style: GoogleFonts.inter(fontSize: 14.sp)),
            if (_scheduleMessage) ...[
              const Spacer(),
              TextButton(
                  onPressed: _selectScheduleTime,
                  child: Text(_scheduledTime != null
                      ? 'Scheduled: ${_formatDateTime(_scheduledTime!)}'
                      : 'Select Time')),
            ],
          ]),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: _clearMessage, child: const Text('Clear'))),
            SizedBox(width: 12.w),
            Expanded(
                child: ElevatedButton(
                    onPressed: _canSendMessage() ? _sendBroadcastMessage : null,
                    child:
                        Text(_scheduleMessage ? 'Schedule' : 'Send Message'))),
          ]),
        ]));
  }

  Widget _buildEmergencyAlerts() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.emergency, color: AppTheme.errorLight, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Emergency Alerts',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight)),
          ]),
          SizedBox(height: 12.h),

          // Emergency Message Input
          TextField(
              controller: _emergencyController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'Emergency Alert Message',
                  hintText: 'Critical information for all drivers...',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.errorLight)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppTheme.errorLight, width: 2)))),

          SizedBox(height: 12.h),

          // Quick Emergency Templates
          Text('Quick Templates:',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: [
            _buildEmergencyTemplate('Severe Weather Alert'),
            _buildEmergencyTemplate('Road Closure Notice'),
            _buildEmergencyTemplate('Safety Advisory'),
            _buildEmergencyTemplate('System Maintenance'),
          ]),

          SizedBox(height: 16.h),

          // Emergency Alert Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: _emergencyController.text.isNotEmpty
                      ? _sendEmergencyAlert
                      : null,
                  icon: const Icon(Icons.warning),
                  label: const Text('Send Emergency Alert'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorLight,
                      foregroundColor: Colors.white))),
        ]));
  }

  Widget _buildEmergencyTemplate(String template) {
    return GestureDetector(
        onTap: () => _emergencyController.text = template,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
                color: AppTheme.errorLight.withAlpha(26),
                border: Border.all(color: AppTheme.errorLight.withAlpha(77))),
            child: Text(template,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: AppTheme.errorLight))));
  }

  Widget _buildShiftScheduling() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shift Scheduling & Notifications',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),

          // Upcoming Shifts
          Text('Upcoming Shifts:',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppTheme.textSecondaryLight)),
          SizedBox(height: 8.h),

          _buildShiftItem('Morning Shift', '6:00 AM - 2:00 PM', '5 drivers',
              AppTheme.successLight),
          _buildShiftItem('Afternoon Shift', '2:00 PM - 10:00 PM', '7 drivers',
              AppTheme.primaryLight),
          _buildShiftItem('Night Shift', '10:00 PM - 6:00 AM', '3 drivers',
              AppTheme.warningLight),

          SizedBox(height: 16.h),

          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _manageShifts,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Manage Shifts'))),
            SizedBox(width: 12.w),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: _sendShiftReminders,
                    icon: const Icon(Icons.notifications),
                    label: const Text('Send Reminders'))),
          ]),
        ]));
  }

  Widget _buildShiftItem(
      String title, String time, String drivers, Color color) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: color.withAlpha(13),
            border: Border.all(color: color.withAlpha(51))),
        child: Row(children: [
          Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight)),
                Text(time,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: AppTheme.textSecondaryLight)),
              ])),
          Text(drivers,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, fontWeight: FontWeight.w500, color: color)),
        ]));
  }

  Widget _buildCommunicationHistory() {
    final recentMessages = [
      {
        'type': 'general',
        'message': 'New safety protocols effective immediately',
        'time': '2 hours ago',
        'recipients': '12 drivers',
      },
      {
        'type': 'emergency',
        'message': 'Heavy rain warning - exercise caution',
        'time': '4 hours ago',
        'recipients': 'All drivers',
      },
      {
        'type': 'operational',
        'message': 'Downtown area construction delays',
        'time': '1 day ago',
        'recipients': '8 drivers',
      },
    ];

    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Communication History',
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight)),
          SizedBox(height: 12.h),
          ...recentMessages
              .map((message) => _buildHistoryItem(message))
              .toList(),
          SizedBox(height: 12.h),
          Center(
              child: TextButton(
                  onPressed: _viewFullHistory,
                  child: const Text('View Full History'))),
        ]));
  }

  Widget _buildHistoryItem(Map<String, dynamic> message) {
    Color typeColor = _getMessageTypeColor(message['type']);

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: AppTheme.backgroundLight),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: typeColor.withAlpha(26)),
                child: Text(message['type'].toString().toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: typeColor))),
            const Spacer(),
            Text(message['time'],
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: AppTheme.textSecondaryLight)),
          ]),
          SizedBox(height: 8.h),
          Text(message['message'],
              style: GoogleFonts.inter(
                  fontSize: 13.sp, color: AppTheme.textPrimaryLight)),
          SizedBox(height: 4.h),
          Text('Sent to: ${message['recipients']}',
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: AppTheme.textSecondaryLight)),
        ]));
  }

  bool _canSendMessage() {
    return _messageController.text.isNotEmpty && _selectedDrivers.isNotEmpty;
  }

  void _sendBroadcastMessage() {
    if (_canSendMessage()) {
      widget.onMessageSent(_messageController.text, _selectedDrivers);
      _clearMessage();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_scheduleMessage
              ? 'Message scheduled successfully'
              : 'Message sent to ${_selectedDrivers.length} drivers'),
          backgroundColor: AppTheme.successLight));
    }
  }

  void _sendEmergencyAlert() {
    if (_emergencyController.text.isNotEmpty) {
      widget.onEmergencyAlert(_emergencyController.text);
      _emergencyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Emergency alert sent to all drivers'),
          backgroundColor: AppTheme.errorLight));
    }
  }

  void _clearMessage() {
    _messageController.clear();
    _selectedDrivers.clear();
    _scheduleMessage = false;
    _scheduledTime = null;
    setState(() {});
  }

  void _selectScheduleTime() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)));

    if (date != null) {
      final time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (time != null) {
        setState(() {
          _scheduledTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _manageShifts() {
    debugPrint('Opening shift management interface');
  }

  void _sendShiftReminders() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Shift reminders sent to all scheduled drivers'),
        backgroundColor: AppTheme.successLight));
  }

  void _viewFullHistory() {
    debugPrint('Opening full communication history');
  }

  Color _getMessageTypeColor(String type) {
    switch (type) {
      case 'emergency':
        return AppTheme.errorLight;
      case 'operational':
        return AppTheme.warningLight;
      case 'weather':
        return AppTheme.accentLight;
      case 'traffic':
        return AppTheme.primaryLight;
      default:
        return AppTheme.successLight;
    }
  }
}
