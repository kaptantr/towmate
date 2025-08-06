import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const NotificationSettingsWidget({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = TimeOfDay(hour: 7, minute: 0);

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.only()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                  color: Colors.blue[700], borderRadius: BorderRadius.only()),
              child: Row(children: [
                Expanded(
                    child: Text('Notification Settings',
                        style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white)),
              ])),
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Delivery Methods'),
                        _buildSwitchTile(
                            'Push Notifications',
                            'Receive notifications on your device',
                            _pushNotifications,
                            (value) =>
                                setState(() => _pushNotifications = value),
                            Icons.notifications),
                        _buildSwitchTile(
                            'Email Notifications',
                            'Receive notifications via email',
                            _emailNotifications,
                            (value) =>
                                setState(() => _emailNotifications = value),
                            Icons.email),
                        _buildSwitchTile(
                            'SMS Notifications',
                            'Receive notifications via SMS',
                            _smsNotifications,
                            (value) =>
                                setState(() => _smsNotifications = value),
                            Icons.sms),
                        SizedBox(height: 24.h),
                        _buildSectionTitle('Alert Settings'),
                        _buildSwitchTile(
                            'Sound',
                            'Play sound for notifications',
                            _soundEnabled,
                            (value) => setState(() => _soundEnabled = value),
                            Icons.volume_up),
                        _buildSwitchTile(
                            'Vibration',
                            'Vibrate for notifications',
                            _vibrationEnabled,
                            (value) =>
                                setState(() => _vibrationEnabled = value),
                            Icons.vibration),
                        SizedBox(height: 24.h),
                        _buildSectionTitle('Quiet Hours'),
                        _buildSwitchTile(
                            'Enable Quiet Hours',
                            'Mute non-emergency notifications during specified hours',
                            _quietHoursEnabled,
                            (value) =>
                                setState(() => _quietHoursEnabled = value),
                            Icons.bedtime),
                        if (_quietHoursEnabled) ...[
                          SizedBox(height: 16.h),
                          Row(children: [
                            Expanded(
                                child: _buildTimePicker(
                                    'Start Time',
                                    _quietHoursStart,
                                    (time) => setState(
                                        () => _quietHoursStart = time))),
                            SizedBox(width: 16.w),
                            Expanded(
                                child: _buildTimePicker(
                                    'End Time',
                                    _quietHoursEnd,
                                    (time) =>
                                        setState(() => _quietHoursEnd = time))),
                          ]),
                        ],
                        SizedBox(height: 24.h),
                        _buildSectionTitle('Language'),
                        _buildLanguageSelector(),
                        SizedBox(height: 24.h),
                        _buildSectionTitle('Notification History'),
                        _buildActionTile(
                            'Export Notification History',
                            'Download your notification history as CSV',
                            Icons.file_download, () {
                          // Handle export
                        }),
                        _buildActionTile(
                            'Clear All Notifications',
                            'Remove all notifications except emergency alerts',
                            Icons.clear_all, () {
                          _showClearConfirmationDialog();
                        }),
                      ]))),
        ]));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Text(title,
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900])));
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      Function(bool) onChanged, IconData icon) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: Row(children: [
          Icon(icon, color: Colors.blue[700], size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[900])),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.grey[600])),
              ])),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue[700]),
        ]));
  }

  Widget _buildTimePicker(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
        onTap: () async {
          final pickedTime =
              await showTimePicker(context: context, initialTime: time);
          if (pickedTime != null) {
            onChanged(pickedTime);
          }
        },
        child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(height: 4.h),
              Text(time.format(context),
                  style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900])),
            ])));
  }

  Widget _buildLanguageSelector() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: DropdownButtonFormField<String>(
            value: widget.selectedLanguage,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.language, color: Colors.blue[700])),
            items: _languages.map((language) {
              return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']!,
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, color: Colors.grey[900])));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onLanguageChanged(value);
              }
            }));
  }

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: ListTile(
            leading: Icon(icon, color: Colors.blue[700], size: 24.sp),
            title: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900])),
            subtitle: Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, color: Colors.grey[600])),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: onTap,
            shape: RoundedRectangleBorder(),
            tileColor: Colors.grey[50]));
  }

  void _showClearConfirmationDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Clear All Notifications',
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, fontWeight: FontWeight.w600)),
                content: Text(
                    'This will remove all notifications except emergency alerts. This action cannot be undone.',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, color: Colors.grey[700])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle clear all
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700]),
                      child: Text('Clear All',
                          style: TextStyle(color: Colors.white))),
                ]));
  }
}
