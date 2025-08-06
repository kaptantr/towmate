import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DestinationInputField extends StatefulWidget {
  final String? destination;
  final Function(String) onDestinationChanged;
  final Function(String, double?, double?)? onPlaceSelected;

  const DestinationInputField({
    Key? key,
    this.destination,
    required this.onDestinationChanged,
    this.onPlaceSelected,
  }) : super(key: key);

  @override
  State<DestinationInputField> createState() => _DestinationInputFieldState();
}

class _DestinationInputFieldState extends State<DestinationInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  final Dio _dio = Dio();

  // Google Places API key - should be configured in env.json
  static const String _googleApiKey = "YOUR_GOOGLE_PLACES_API_KEY";

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _controller.text = widget.destination!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _dio.close();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onTextChanged(String value) {
    widget.onDestinationChanged(value);

    if (value.isEmpty) {
      setState(() {
        _predictions = [];
        _showSuggestions = false;
      });
      return;
    }

    if (value.length > 2) {
      _searchPlaces(value);
    }
  }

  Future<void> _searchPlaces(String input) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to use real Google Places API first
      if (_googleApiKey != "YOUR_GOOGLE_PLACES_API_KEY" &&
          _googleApiKey.isNotEmpty) {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': input,
            'key': _googleApiKey,
            'language': 'tr',
            'components': 'country:tr',
            'types': 'establishment|geocode',
          },
        );

        if (response.statusCode == 200 &&
            response.data['predictions'] != null) {
          final predictions = (response.data['predictions'] as List)
              .map((e) => Prediction.fromJson(e))
              .toList();

          setState(() {
            _predictions = predictions.take(5).toList();
            _showSuggestions = predictions.isNotEmpty && _focusNode.hasFocus;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // Fall back to mock data if API fails
      print('Google Places API error: $e');
    }

    // Enhanced mock predictions with more comprehensive Turkish locations
    _getMockPredictions(input);
  }

  void _getMockPredictions(String input) {
    final mockSuggestions = [
      'İstanbul Havalimanı, Arnavutköy/İstanbul',
      'Sabiha Gökçen Havalimanı, Pendik/İstanbul',
      'Atatürk Havalimanı, Bakırköy/İstanbul',
      'Taksim Meydanı, Beyoğlu/İstanbul',
      'Sultanahmet Camii, Fatih/İstanbul',
      'Galata Kulesi, Beyoğlu/İstanbul',
      'İstanbul Üniversitesi, Beyazıt/İstanbul',
      'Boğaziçi Köprüsü, İstanbul',
      'Kapalıçarşı, Fatih/İstanbul',
      'Dolmabahçe Sarayı, Beşiktaş/İstanbul',
      'İstiklal Caddesi, Beyoğlu/İstanbul',
      'Kadıköy İskelesi, Kadıköy/İstanbul',
      'Üsküdar Meydanı, Üsküdar/İstanbul',
      'Levent Metro, Beşiktaş/İstanbul',
      'Maslak Acıbadem Hastanesi, Sarıyer/İstanbul',
      'İstanbul Teknik Üniversitesi, Maslak/İstanbul',
      'Zorlu Center, Beşiktaş/İstanbul',
      'Mall of İstanbul, Başakşehir/İstanbul',
      'Forum İstanbul AVM, Bayrampaşa/İstanbul',
      'Ankara Esenboğa Havalimanı, Ankara',
      'Kızılay Meydanı, Çankaya/Ankara',
      'Anıtkabir, Çankaya/Ankara',
      'İzmir Adnan Menderes Havalimanı, İzmir',
      'Konak Meydanı, İzmir',
      'Antalya Havalimanı, Antalya',
      'Kalekapısı, Muratpaşa/Antalya',
    ];

    // Filter based on input and add more locations
    final filtered = mockSuggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(input.toLowerCase()) ||
            input.toLowerCase().split(' ').any((word) =>
                suggestion.toLowerCase().contains(word) && word.length > 2))
        .take(8)
        .map((text) => Prediction(
              description: text,
              placeId: text.hashCode.toString(),
              structuredFormatting: StructuredFormatting(
                mainText: text.split(',').first,
                secondaryText: text.contains(',')
                    ? text.split(',').skip(1).join(',').trim()
                    : '',
              ),
            ))
        .toList();

    // Add generic suggestions if no specific matches
    if (filtered.isEmpty && input.length > 2) {
      filtered.addAll([
        Prediction(
          description: '$input Caddesi, İstanbul',
          placeId: '${input}_street'.hashCode.toString(),
          structuredFormatting: StructuredFormatting(
            mainText: '$input Caddesi',
            secondaryText: 'İstanbul',
          ),
        ),
        Prediction(
          description: '$input Mahallesi, İstanbul',
          placeId: '${input}_district'.hashCode.toString(),
          structuredFormatting: StructuredFormatting(
            mainText: '$input Mahallesi',
            secondaryText: 'İstanbul',
          ),
        ),
      ]);
    }

    setState(() {
      _predictions = filtered;
      _showSuggestions = filtered.isNotEmpty && _focusNode.hasFocus;
      _isLoading = false;
    });
  }

  Future<void> _selectPrediction(Prediction prediction) async {
    _controller.text = prediction.description ?? '';
    widget.onDestinationChanged(prediction.description ?? '');

    // Try to get place details if using real API
    if (_googleApiKey != "YOUR_GOOGLE_PLACES_API_KEY" &&
        _googleApiKey.isNotEmpty &&
        widget.onPlaceSelected != null) {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/details/json',
          queryParameters: {
            'place_id': prediction.placeId,
            'key': _googleApiKey,
            'fields': 'geometry',
          },
        );

        if (response.statusCode == 200 &&
            response.data['result']?['geometry']?['location'] != null) {
          final location = response.data['result']['geometry']['location'];
          widget.onPlaceSelected!(
            prediction.description ?? '',
            location['lat']?.toDouble(),
            location['lng']?.toDouble(),
          );
        }
      } catch (e) {
        print('Error fetching place details: $e');
        // Fallback to mock coordinates
        widget.onPlaceSelected!(
          prediction.description ?? '',
          41.0082 +
              (prediction.placeId.hashCode % 100) / 10000, // Slight variation
          28.9784 + (prediction.placeId.hashCode % 100) / 10000,
        );
      }
    } else if (widget.onPlaceSelected != null) {
      // Use mock coordinates based on location
      double lat = 41.0082;
      double lng = 28.9784;

      final description = prediction.description?.toLowerCase() ?? '';
      if (description.contains('ankara')) {
        lat = 39.9334;
        lng = 32.8597;
      } else if (description.contains('izmir')) {
        lat = 38.4192;
        lng = 27.1287;
      } else if (description.contains('antalya')) {
        lat = 36.8969;
        lng = 30.7133;
      } else if (description.contains('havalimanı') ||
          description.contains('airport')) {
        if (description.contains('sabiha')) {
          lat = 40.8986;
          lng = 29.3092;
        } else if (description.contains('atatürk')) {
          lat = 40.9769;
          lng = 28.8146;
        } else {
          lat = 41.2753;
          lng = 28.7519; // Istanbul Airport
        }
      }

      widget.onPlaceSelected!(prediction.description ?? '', lat, lng);
    }

    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varış Noktası (İsteğe Bağlı)',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Nereye gitmek istediğinizi yazın, öneriler görünecektir.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: _focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                hintText: 'Örn: Taksim, İstanbul Havalimanı, Galata Kulesi...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: _focusNode.hasFocus
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                suffixIcon: _isLoading
                    ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _controller.clear();
                              widget.onDestinationChanged('');
                              setState(() {
                                _predictions = [];
                                _showSuggestions = false;
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          )
                        : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
          ),
          if (_showSuggestions && _predictions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 1.h),
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: 60.h, // Limit height for better UX
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _predictions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectPrediction(prediction),
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(12))
                          : index == _predictions.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(12))
                              : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prediction.structuredFormatting?.mainText ??
                                        prediction.description ??
                                        '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (prediction.structuredFormatting
                                          ?.secondaryText?.isNotEmpty ??
                                      false)
                                    Text(
                                      prediction
                                          .structuredFormatting!.secondaryText!,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'north_west',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                          ],
                        ),
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
