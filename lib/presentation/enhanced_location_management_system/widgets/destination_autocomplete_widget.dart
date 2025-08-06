import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DestinationAutocompleteWidget extends StatefulWidget {
  final String? currentAddress;
  final Function(String address, double? lat, double? lng)
      onDestinationSelected;

  const DestinationAutocompleteWidget({
    Key? key,
    this.currentAddress,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  State<DestinationAutocompleteWidget> createState() =>
      _DestinationAutocompleteWidgetState();
}

class _DestinationAutocompleteWidgetState
    extends State<DestinationAutocompleteWidget> {
  final TextEditingController _typeAheadController = TextEditingController();
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress != null) {
      _typeAheadController.text = widget.currentAddress!;
    }
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _searchPlaces(String query) async {
    if (query.length < 3) return [];

    try {
      // Use geocoding to search for places
      List<Location> locations = await locationFromAddress(query);

      List<Map<String, dynamic>> results = [];
      for (Location location in locations.take(5)) {
        try {
          // Get place details
          List<Placemark> placemarks = await placemarkFromCoordinates(
              location.latitude, location.longitude);

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            String formattedAddress = _formatPlacemarkToAddress(place);

            results.add({
              'address': formattedAddress,
              'lat': location.latitude,
              'lng': location.longitude,
              'place': place,
            });
          }
        } catch (e) {
          // Skip this location if reverse geocoding fails
          continue;
        }
      }

      return results;
    } catch (e) {
      debugPrint('Places search failed: $e');
      return [];
    }
  }

  String _formatPlacemarkToAddress(Placemark place) {
    List<String> addressParts = [];

    // Street number and name
    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    } else if (place.name?.isNotEmpty == true && place.name != place.locality) {
      addressParts.add(place.name!);
    }

    // Neighborhood
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }

    // City and state
    if (place.locality?.isNotEmpty == true) {
      String cityPart = place.locality!;
      if (place.administrativeArea?.isNotEmpty == true &&
          place.administrativeArea != place.locality) {
        cityPart += ', ${place.administrativeArea!}';
      }
      addressParts.add(cityPart);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Bilinmeyen Konum';
  }

  Widget _buildPlaceSuggestion(Map<String, dynamic> place) {
    final Placemark placemark = place['place'];

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getPlaceIcon(placemark),
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        place['address'],
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildPlaceSubtitle(placemark),
      trailing: Icon(
        Icons.north_west,
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
    );
  }

  Widget _buildPlaceSubtitle(Placemark place) {
    List<String> subtitleParts = [];

    if (place.locality?.isNotEmpty == true) {
      subtitleParts.add(place.locality!);
    }

    if (place.administrativeArea?.isNotEmpty == true) {
      subtitleParts.add(place.administrativeArea!);
    }

    return Text(
      subtitleParts.join(', '),
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  IconData _getPlaceIcon(Placemark place) {
    // Determine icon based on place type
    if (place.name?.toLowerCase().contains('hastane') == true ||
        place.name?.toLowerCase().contains('hospital') == true) {
      return Icons.local_hospital;
    }

    if (place.name?.toLowerCase().contains('okul') == true ||
        place.name?.toLowerCase().contains('school') == true ||
        place.name?.toLowerCase().contains('üniversite') == true) {
      return Icons.school;
    }

    if (place.name?.toLowerCase().contains('alışveriş') == true ||
        place.name?.toLowerCase().contains('avm') == true ||
        place.name?.toLowerCase().contains('mall') == true) {
      return Icons.shopping_cart;
    }

    if (place.name?.toLowerCase().contains('havaalanı') == true ||
        place.name?.toLowerCase().contains('airport') == true) {
      return Icons.flight;
    }

    if (place.name?.toLowerCase().contains('istasyon') == true ||
        place.name?.toLowerCase().contains('station') == true) {
      return Icons.train;
    }

    return Icons.location_on;
  }

  Future<void> _validateAndSelectAddress(String address) async {
    if (address.trim().isEmpty) return;

    setState(() {
      _isValidating = true;
    });

    try {
      // Try to get coordinates for the address
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;

        // Validate by reverse geocoding
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);

        String validatedAddress = address;
        if (placemarks.isNotEmpty) {
          validatedAddress = _formatPlacemarkToAddress(placemarks.first);
        }

        widget.onDestinationSelected(
            validatedAddress, location.latitude, location.longitude);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Varış noktası onaylandı'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Adres bulunamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adres doğrulanamadı: ${e.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
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
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Varış Noktası (İsteğe Bağlı)',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Nereye gitmek istediğinizi belirtin',
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

          // TypeAhead search field
          TypeAheadField<Map<String, dynamic>>(
            controller: _typeAheadController,
            suggestionsCallback: _searchPlaces,
            itemBuilder: (context, suggestion) =>
                _buildPlaceSuggestion(suggestion),
            onSelected: (suggestion) {
              widget.onDestinationSelected(
                  suggestion['address'], suggestion['lat'], suggestion['lng']);
            },
            decorationBuilder: (context, child) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: child,
              );
            },
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Varış noktanızı yazın (örn: Taksim, İstanbul)',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _isValidating
                      ? Padding(
                          padding: EdgeInsets.all(3.w),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : _typeAheadController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _typeAheadController.clear();
                                widget.onDestinationSelected('', null, null);
                              },
                              icon: Icon(
                                Icons.clear,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                  filled: true,
                  fillColor:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: _validateAndSelectAddress,
              );
            },
          ),

          SizedBox(height: 2.h),

          // Manual validation button
          if (_typeAheadController.text.isNotEmpty && !_isValidating)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _validateAndSelectAddress(_typeAheadController.text),
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                label: Text(
                  'Adresi Doğrula ve Seç',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
