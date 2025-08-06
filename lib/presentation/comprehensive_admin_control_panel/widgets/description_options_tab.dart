import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DescriptionOptionsTab extends StatefulWidget {
  const DescriptionOptionsTab({super.key});

  @override
  State<DescriptionOptionsTab> createState() => _DescriptionOptionsTabState();
}

class _DescriptionOptionsTabState extends State<DescriptionOptionsTab> {
  Map<String, List<Map<String, dynamic>>> _descriptionOptions = {};
  bool _isLoading = false;
  String _selectedServiceType = 'towing';

  final Map<String, String> _serviceTypeLabels = {
    'towing': 'Çekici Hizmeti',
    'jumpstart': 'Akü Takviye',
    'tire_change': 'Lastik Değişimi',
    'lockout': 'Kapı Açma',
    'fuel_delivery': 'Yakıt Getirme',
    'winch_service': 'Vinç Hizmeti',
  };

  @override
  void initState() {
    super.initState();
    _loadDescriptionOptions();
  }

  Future<void> _loadDescriptionOptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock description options data
      _descriptionOptions = {
        'towing': [
          {
            'id': '1',
            'option_text': 'Araç çalışmıyor, çekici gerekli',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '2',
            'option_text': 'Kaza sonrası çekici talebi',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '3',
            'option_text': 'Motor arızası, hareket edemiyor',
            'display_order': 3,
            'is_active': true
          },
          {
            'id': '4',
            'option_text': 'Lastik patladı, yedek yok',
            'display_order': 4,
            'is_active': true
          },
          {
            'id': '5',
            'option_text': 'Yakıt bitti, en yakın istasyona',
            'display_order': 5,
            'is_active': false
          },
        ],
        'jumpstart': [
          {
            'id': '6',
            'option_text': 'Akü boş, motor çalışmıyor',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '7',
            'option_text': 'Farlar açık kalmış, akü bitmiş',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '8',
            'option_text': 'Soğuk havada akü bitti',
            'display_order': 3,
            'is_active': true
          },
          {
            'id': '9',
            'option_text': 'Uzun süre kullanılmamış araç',
            'display_order': 4,
            'is_active': true
          },
        ],
        'tire_change': [
          {
            'id': '10',
            'option_text': 'Lastik patladı, yedek var',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '11',
            'option_text': 'Lastik patladı, yedek yok',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '12',
            'option_text': 'Lastik havalı değil',
            'display_order': 3,
            'is_active': true
          },
          {
            'id': '13',
            'option_text': 'Jant zarar gördü',
            'display_order': 4,
            'is_active': true
          },
        ],
        'lockout': [
          {
            'id': '14',
            'option_text': 'Anahtarlar araçta kaldı',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '15',
            'option_text': 'Anahtar kırıldı',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '16',
            'option_text': 'Kumanda çalışmıyor',
            'display_order': 3,
            'is_active': true
          },
          {
            'id': '17',
            'option_text': 'Çocuk kilidi aktif',
            'display_order': 4,
            'is_active': true
          },
        ],
        'fuel_delivery': [
          {
            'id': '18',
            'option_text': 'Benzin bitti, istasyona gidemiyorum',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '19',
            'option_text': 'Dizel yakıt gerekli',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '20',
            'option_text': 'LPG tüpü boş',
            'display_order': 3,
            'is_active': false
          },
          {
            'id': '21',
            'option_text': 'Yanlış yakıt konuldu',
            'display_order': 4,
            'is_active': true
          },
        ],
        'winch_service': [
          {
            'id': '22',
            'option_text': 'Araç çamura saplandı',
            'display_order': 1,
            'is_active': true
          },
          {
            'id': '23',
            'option_text': 'Kara saplanmış araç',
            'display_order': 2,
            'is_active': true
          },
          {
            'id': '24',
            'option_text': 'Hendekten çıkarma',
            'display_order': 3,
            'is_active': true
          },
          {
            'id': '25',
            'option_text': 'Buzda kaymış araç',
            'display_order': 4,
            'is_active': true
          },
        ],
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Açıklama seçenekleri yüklenirken hata oluştu: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddOptionDialog() {
    final TextEditingController optionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${_serviceTypeLabels[_selectedServiceType]} için Yeni Seçenek',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: optionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama Seçeneği',
                hintText: 'Müşterinin seçebileceği hızlı açıklama',
              ),
              maxLines: 2,
              autofocus: true,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İpucu:',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '• Kısa ve anlaşılır olsun\n• Müşterinin durumunu tam açıklasın\n• Pozitif dil kullanın',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (optionController.text.isNotEmpty) {
                _addNewOption(optionController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addNewOption(String optionText) {
    setState(() {
      final currentOptions = _descriptionOptions[_selectedServiceType] ?? [];
      final newOrder = currentOptions.length + 1;
      final newOption = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'option_text': optionText,
        'display_order': newOrder,
        'is_active': true,
      };

      if (_descriptionOptions[_selectedServiceType] == null) {
        _descriptionOptions[_selectedServiceType] = [];
      }
      _descriptionOptions[_selectedServiceType]!.add(newOption);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni açıklama seçeneği eklendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editOption(Map<String, dynamic> option) {
    final TextEditingController optionController =
        TextEditingController(text: option['option_text']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Açıklama Seçeneğini Düzenle'),
        content: TextFormField(
          controller: optionController,
          decoration: const InputDecoration(
            labelText: 'Açıklama Seçeneği',
          ),
          maxLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (optionController.text.isNotEmpty) {
                setState(() {
                  option['option_text'] = optionController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Açıklama seçeneği güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _toggleOptionStatus(Map<String, dynamic> option) {
    setState(() {
      option['is_active'] = !option['is_active'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seçenek ${option['is_active'] ? 'aktif' : 'pasif'} edildi',
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _deleteOption(Map<String, dynamic> option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seçeneği Sil'),
        content: Text(
          'Bu açıklama seçeneğini silmek istediğinizden emin misiniz?\n\n"${option['option_text']}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _descriptionOptions[_selectedServiceType]
                    ?.removeWhere((item) => item['id'] == option['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Açıklama seçeneği silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDescriptionOptions,
      child: Column(
        children: [
          // Service Type Selector
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Servis Tipi Seçin',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddOptionDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Yeni Seçenek'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _serviceTypeLabels.entries.map((entry) {
                      final isSelected = _selectedServiceType == entry.key;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedServiceType = entry.key;
                            });
                          },
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.surface,
                          selectedColor: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          checkmarkColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Description Options List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                : (_descriptionOptions[_selectedServiceType]?.isEmpty ?? true)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'description',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Bu servis için henüz açıklama seçeneği yok',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Müşterilerin hızlı seçim yapabilmesi için açıklama seçenekleri ekleyin',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 3.h),
                            ElevatedButton.icon(
                              onPressed: _showAddOptionDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('İlk Seçeneği Ekle'),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: EdgeInsets.all(4.w),
                        itemCount:
                            _descriptionOptions[_selectedServiceType]?.length ??
                                0,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final items =
                                _descriptionOptions[_selectedServiceType]!;
                            final item = items.removeAt(oldIndex);
                            items.insert(newIndex, item);

                            // Update display orders
                            for (int i = 0; i < items.length; i++) {
                              items[i]['display_order'] = i + 1;
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          final option =
                              _descriptionOptions[_selectedServiceType]![index];

                          return Container(
                            key: ValueKey(option['id']),
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: option['is_active']
                                    ? AppTheme.lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.3)
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.lightTheme.shadowColor
                                      .withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(4.w),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.drag_handle,
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: option['is_active']
                                          ? AppTheme
                                              .lightTheme.colorScheme.primary
                                          : AppTheme
                                              .lightTheme.colorScheme.outline,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${option['display_order']}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                option['option_text'],
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: option['is_active']
                                      ? AppTheme
                                          .lightTheme.colorScheme.onSurface
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Container(
                                margin: EdgeInsets.only(top: 1.h),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: option['is_active']
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        option['is_active'] ? 'Aktif' : 'Pasif',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _editOption(option);
                                      break;
                                    case 'toggle':
                                      _toggleOptionStatus(option);
                                      break;
                                    case 'delete':
                                      _deleteOption(option);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Düzenle'),
                                      dense: true,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: ListTile(
                                      leading: Icon(option['is_active']
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                      title: Text(option['is_active']
                                          ? 'Deaktif Et'
                                          : 'Aktif Et'),
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading:
                                          Icon(Icons.delete, color: Colors.red),
                                      title: Text('Sil',
                                          style: TextStyle(color: Colors.red)),
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
