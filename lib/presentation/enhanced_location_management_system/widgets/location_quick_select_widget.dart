import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationQuickSelectWidget extends StatelessWidget {
  final Function(String address, double? lat, double? lng) onLocationSelected;

  const LocationQuickSelectWidget({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  // Common locations in Istanbul for demo purposes
  final List<Map<String, dynamic>> _commonLocations = const [
    {
      'name': 'Taksim Meydanı',
      'address': 'Taksim Meydanı, Beyoğlu, İstanbul',
      'lat': 41.0367,
      'lng': 28.985,
      'icon': Icons.location_city,
    },
    {
      'name': 'Kadıköy İskelesi',
      'address': 'Kadıköy İskelesi, Kadıköy, İstanbul',
      'lat': 41.0082,
      'lng': 29.0246,
      'icon': Icons.directions_boat,
    },
    {
      'name': 'İstanbul Havaalanı',
      'address': 'İstanbul Havaalanı, Arnavutköy, İstanbul',
      'lat': 41.2753,
      'lng': 28.7519,
      'icon': Icons.flight,
    },
    {
      'name': 'Beşiktaş Çarşı',
      'address': 'Beşiktaş Çarşı, Beşiktaş, İstanbul',
      'lat': 41.0422,
      'lng': 29.0014,
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'Sultanahmet',
      'address': 'Sultanahmet Meydanı, Fatih, İstanbul',
      'lat': 41.0058,
      'lng': 28.9784,
      'icon': Icons.mosque,
    },
    {
      'name': 'Galata Kulesi',
      'address': 'Galata Kulesi, Beyoğlu, İstanbul',
      'lat': 41.0256,
      'lng': 28.9742,
      'icon': Icons.help_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'explore',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Hızlı Konum Seçimi',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Popüler konumlardan birini seçin',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 3.h),

          // Quick select grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 3.5,
            ),
            itemCount: _commonLocations.length,
            itemBuilder: (context, index) {
              final location = _commonLocations[index];

              return GestureDetector(
                onTap: () {
                  onLocationSelected(
                    location['address'],
                    location['lat'],
                    location['lng'],
                  );

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${location['name']} seçildi'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        location['icon'],
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          location['name'],
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 2.h),

          // Additional quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Open map picker (would need additional implementation)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Harita seçimi özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.map,
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  label: Text(
                    'Haritadan Seç',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share location functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Konum paylaşma özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.share_location,
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  label: Text(
                    'Konum Paylaş',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
