import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/service_request_service.dart';

class QuickDescriptionSelectorWidget extends StatefulWidget {
  final List<String> selectedServices;
  final Function(List<String>) onDescriptionsChanged;
  final Function(String?) onCustomDescriptionChanged;

  const QuickDescriptionSelectorWidget({
    Key? key,
    required this.selectedServices,
    required this.onDescriptionsChanged,
    required this.onCustomDescriptionChanged,
  }) : super(key: key);

  @override
  State<QuickDescriptionSelectorWidget> createState() =>
      _QuickDescriptionSelectorWidgetState();
}

class _QuickDescriptionSelectorWidgetState
    extends State<QuickDescriptionSelectorWidget> {
  List<String> _selectedDescriptions = [];
  bool _showCustomDescription = false;
  String? _customDescription;
  bool _isLoading = true;

  // Description options loaded from admin settings
  Map<String, List<Map<String, dynamic>>> _descriptionOptions = {};

  @override
  void initState() {
    super.initState();
    _loadDescriptionOptions();
  }

  Future<void> _loadDescriptionOptions() async {
    try {
      final options = await ServiceRequestService.instance
          .getDescriptionOptions(widget.selectedServices);
      setState(() {
        _descriptionOptions = options;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Use default options on error
      _setDefaultDescriptions();
    }
  }

  void _setDefaultDescriptions() {
    _descriptionOptions = {
      'vehicle_condition': [
        {'id': '1', 'text': 'Araç çalışmıyor', 'service_type': null},
        {
          'id': '2',
          'text': 'Motor çalışıyor ama hareket etmiyor',
          'service_type': null
        },
        {'id': '3', 'text': 'Araç tamamen arızalı', 'service_type': null},
      ],
      'location_details': [
        {'id': '4', 'text': 'Ana yol kenarında', 'service_type': null},
        {'id': '5', 'text': 'Yan sokakta', 'service_type': null},
        {'id': '6', 'text': 'Otopark içinde', 'service_type': null},
      ],
      'urgency_details': [
        {'id': '7', 'text': 'Acil değil, zamanım var', 'service_type': null},
        {'id': '8', 'text': 'Mümkün olan en kısa sürede', 'service_type': null},
        {
          'id': '9',
          'text': 'Çok acil, işe geç kalacağım',
          'service_type': null
        },
      ],
    };
  }

  void _toggleDescription(String optionId, String text) {
    setState(() {
      if (_selectedDescriptions.contains(text)) {
        _selectedDescriptions.remove(text);
      } else {
        _selectedDescriptions.add(text);
      }
    });
    widget.onDescriptionsChanged(_selectedDescriptions);
  }

  void _toggleCustomDescription() {
    setState(() {
      _showCustomDescription = !_showCustomDescription;
      if (!_showCustomDescription) {
        _customDescription = null;
        widget.onCustomDescriptionChanged(null);
      }
    });
  }

  void _onCustomDescriptionTextChanged(String text) {
    setState(() {
      _customDescription = text.isEmpty ? null : text;
    });
    widget.onCustomDescriptionChanged(_customDescription);
  }

  Widget _buildDescriptionCategory(
      String category, List<Map<String, dynamic>> options) {
    final categoryTitles = {
      'vehicle_condition': 'Araç Durumu',
      'location_details': 'Konum Detayları',
      'urgency_details': 'Aciliyet Durumu',
      'additional_notes': 'Ek Notlar',
    };

    final categoryIcons = {
      'vehicle_condition': Icons.car_repair,
      'location_details': Icons.location_on,
      'urgency_details': Icons.schedule,
      'additional_notes': Icons.note_add,
    };

    // Filter options relevant to selected services
    final relevantOptions = options.where((option) {
      final serviceType = option['service_type'];
      return serviceType == null ||
          widget.selectedServices.contains(serviceType);
    }).toList();

    if (relevantOptions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              categoryIcons[category] ?? Icons.help,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              categoryTitles[category] ?? category,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: relevantOptions.map((option) {
            final text = option['text'];
            final isSelected = _selectedDescriptions.contains(text);

            return GestureDetector(
              onTap: () => _toggleDescription(option['id'], text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                    ],
                    Text(
                      text,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

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
                iconName: 'quiz',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hızlı Açıklama Seçenekleri',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Durumunuzu hızlıca açıklamak için seçenekleri işaretleyin',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          else ...[
            // Description categories
            ..._descriptionOptions.entries.map((entry) {
              return _buildDescriptionCategory(entry.key, entry.value);
            }),

            // Custom description toggle
            Row(
              children: [
                Checkbox(
                  value: _showCustomDescription,
                  onChanged: (value) => _toggleCustomDescription(),
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleCustomDescription,
                    child: Text(
                      'Özel açıklama eklemek istiyorum',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Custom description input
            if (_showCustomDescription) ...[
              SizedBox(height: 2.h),
              Container(
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Durumunuzu detaylı olarak açıklayın...',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(3.w),
                  ),
                  onChanged: _onCustomDescriptionTextChanged,
                ),
              ),
            ],
          ],

          // Summary of selections
          if (_selectedDescriptions.isNotEmpty ||
              _customDescription != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seçilen Açıklamalar:',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ..._selectedDescriptions.map((desc) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.25.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                desc,
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_customDescription != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.25.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              _customDescription!,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
