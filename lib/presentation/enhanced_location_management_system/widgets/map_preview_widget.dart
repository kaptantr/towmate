import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

class MapPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> destination;

  const MapPreviewWidget({
    Key? key,
    required this.pickupLocation,
    required this.destination,
  }) : super(key: key);

  String _getStaticMapUrl() {
    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final pickupLat = pickupLocation['latitude'];
    final pickupLng = pickupLocation['longitude'];
    final destLat = destination['latitude'];
    final destLng = destination['longitude'];

    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'size=400x200&'
        'maptype=roadmap&'
        'markers=color:green%7Clabel:A%7C$pickupLat,$pickupLng&'
        'markers=color:red%7Clabel:B%7C$destLat,$destLng&'
        'path=color:0x0000ff%7Cweight:3%7C$pickupLat,$pickupLng%7C$destLat,$destLng&'
        'key=$apiKey';
  }

  double _calculateDistance() {
    // Simple distance calculation (Haversine formula approximation)
    final pickupLat = pickupLocation['latitude'] as double;
    final pickupLng = pickupLocation['longitude'] as double;
    final destLat = destination['latitude'] as double;
    final destLng = destination['longitude'] as double;

    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = (destLat - pickupLat) * (3.14159 / 180);
    final double dLng = (destLng - pickupLng) * (3.14159 / 180);

    final double a = (dLat / 2).abs() * (dLat / 2).abs() +
        (pickupLat * 3.14159 / 180).abs() *
            (destLat * 3.14159 / 180).abs() *
            (dLng / 2).abs() *
            (dLng / 2).abs();

    final double c = 2 * math.atan2(math.sqrt(a.abs()), math.sqrt((1 - a).abs()));

    return earthRadius * c;
  }

  String _getEstimatedTime() {
    final distance = _calculateDistance();
    // Rough estimate: 30 km/h average speed in city traffic
    final timeInHours = distance / 30;
    final timeInMinutes = (timeInHours * 60).round();

    if (timeInMinutes < 60) {
      return '$timeInMinutes min';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return '${hours}h ${minutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Preview',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Map Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 25.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: CachedNetworkImage(
                    imageUrl: _getStaticMapUrl(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 30.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Loading map...',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 30.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Map Preview',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Route Information
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.straighten,
                          color: Theme.of(context).primaryColor,
                          size: 18.sp,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_calculateDistance().toStringAsFixed(1)} km',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Distance',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 6.h,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).primaryColor,
                          size: 18.sp,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getEstimatedTime(),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Est. Time',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 6.h,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Theme.of(context).primaryColor,
                          size: 18.sp,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Road',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Route Type',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}