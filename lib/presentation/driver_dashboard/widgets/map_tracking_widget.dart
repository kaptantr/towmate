import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../services/location_service.dart';

class MapTrackingWidget extends StatefulWidget {
  final Map<String, dynamic>? activeJob;
  final Function? onLocationUpdate;

  const MapTrackingWidget({
    Key? key,
    this.activeJob,
    this.onLocationUpdate,
  }) : super(key: key);

  @override
  State<MapTrackingWidget> createState() => _MapTrackingWidgetState();
}

class _MapTrackingWidgetState extends State<MapTrackingWidget> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      final position = await LocationService.instance.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
        _updateMarkers();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      // Driver current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Mevcut Konumunuz',
            snippet: 'Sürücü Konumu',
          ),
        ),
      );
    }

    if (widget.activeJob != null) {
      // Pickup location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_location'),
          position: LatLng(
            widget.activeJob!['pickup_latitude'].toDouble(),
            widget.activeJob!['pickup_longitude'].toDouble(),
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Alış Noktası',
            snippet: widget.activeJob!['pickup_address'],
          ),
        ),
      );

      // Destination marker if available
      if (widget.activeJob!['destination_latitude'] != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('destination_location'),
            position: LatLng(
              widget.activeJob!['destination_latitude'].toDouble(),
              widget.activeJob!['destination_longitude'].toDouble(),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Varış Noktası',
              snippet:
                  widget.activeJob!['destination_address'] ?? 'Varış Noktası',
            ),
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _openGoogleMaps() async {
    if (widget.activeJob != null) {
      final String googleMapsUrl = LocationService.instance.getDirectionsUrl(
        _currentPosition?.latitude ?? 0,
        _currentPosition?.longitude ?? 0,
        widget.activeJob!['pickup_latitude'].toDouble(),
        widget.activeJob!['pickup_longitude'].toDouble(),
      );

      try {
        await launchUrl(Uri.parse(googleMapsUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 40.h,
        margin: EdgeInsets.all(4.w),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Container(
        height: 40.h,
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'location_off',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Konum Servisi Mevcut Değil',
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Lütfen konum izinlerini kontrol edin',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 40.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),

            // Navigation button
            if (widget.activeJob != null)
              Positioned(
                top: 2.h,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _openGoogleMaps,
                    icon: CustomIconWidget(
                      iconName: 'navigation',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Location info card
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.activeJob != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'location_on',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  'Müşteri Konumu',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            widget.activeJob!['pickup_address'],
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'my_location',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Mevcut konumunuz izleniyor',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
