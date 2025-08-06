import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationFilterWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool showOnlyUnread;
  final Function(String) onCategoryChanged;
  final Function(bool) onUnreadToggle;

  const NotificationFilterWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.showOnlyUnread,
    required this.onCategoryChanged,
    required this.onUnreadToggle,
  }) : super(key: key);

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'service_updates':
        return 'Service';
      case 'system_alerts':
        return 'System';
      case 'promotions':
        return 'Promos';
      case 'emergency':
        return 'Emergency';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.blue[700],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return Container(
                        margin: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(
                            _getCategoryDisplayName(category),
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected ? Colors.blue[700] : Colors.white,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              onCategoryChanged(category);
                            }
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: showOnlyUnread,
                      onChanged: (value) => onUnreadToggle(value ?? false),
                      fillColor: WidgetStateProperty.all(Colors.white),
                      checkColor: Colors.blue[700],
                    ),
                    Text(
                      'Show only unread',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${categories.length - 1} categories',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
