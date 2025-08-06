import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyContactWidget extends StatelessWidget {
  const EmergencyContactWidget({Key? key}) : super(key: key);

  void _callEmergency(BuildContext context, String number, String service) {
    // In a real app, this would use url_launcher to make actual calls
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$service aranıyor: $number'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: AppTheme.lightTheme.colorScheme.onError,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> emergencyContacts = [
      {
        'name': 'Polis',
        'number': '155',
        'icon': 'local_police',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'name': 'İtfaiye',
        'number': '110',
        'icon': 'fire_truck',
        'color': AppTheme.lightTheme.colorScheme.error,
      },
      {
        'name': 'Ambulans',
        'number': '112',
        'icon': 'local_hospital',
        'color': AppTheme.lightTheme.colorScheme.tertiary,
      },
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emergency',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Acil Durum İletişim',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Acil durumda aşağıdaki numaraları arayabilirsiniz',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emergencyContacts.map((contact) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _callEmergency(
                        context,
                        contact['number'],
                        contact['name'],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: (contact['color'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: contact['color'],
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: contact['icon'],
                              color: contact['color'],
                              size: 24,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              contact['name'],
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: contact['color'],
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              contact['number'],
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: contact['color'],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
