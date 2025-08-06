import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';

class LocationSharingWidget extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final Position? currentPosition;
  final Map<String, dynamic>? destination;

  const LocationSharingWidget({
    Key? key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.currentPosition,
    this.destination,
  }) : super(key: key);

  String _generateShareableLink() {
    if (currentPosition == null) return '';

    final pickupLat = currentPosition!.latitude;
    final pickupLng = currentPosition!.longitude;

    if (destination != null) {
      final destLat = destination!['latitude'];
      final destLng = destination!['longitude'];
      return 'https://www.google.com/maps/dir/$pickupLat,$pickupLng/$destLat,$destLng';
    } else {
      return 'https://www.google.com/maps/@$pickupLat,$pickupLng,15z';
    }
  }

  void _shareLocation(BuildContext context, String method) {
    final shareableLink = _generateShareableLink();
    final shareText = '''
🚗 TowMate Service Request

📍 Pickup: $pickupAddress
${destinationAddress.isNotEmpty ? '🎯 Destination: $destinationAddress' : ''}

📱 Track live location: $shareableLink

Service requested via TowMate App
''';

    switch (method) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: shareText));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location details copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'sms':
        // In a real app, would integrate with SMS sharing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS sharing would open here'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'email':
        // In a real app, would integrate with email sharing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sharing would open here'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Title
              Text(
                'Share Location',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Share your service location with family or insurance company',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 3.h),

              // Location Details
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                          size: 16.sp,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            pickupAddress,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (destinationAddress.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 16.sp,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              destinationAddress,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Sharing Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.copy,
                    label: 'Copy Link',
                    color: Colors.blue,
                    onTap: () => _shareLocation(context, 'copy'),
                  ),
                  _ShareOption(
                    icon: Icons.sms,
                    label: 'Text Message',
                    color: Colors.green,
                    onTap: () => _shareLocation(context, 'sms'),
                  ),
                  _ShareOption(
                    icon: Icons.email,
                    label: 'Email',
                    color: Colors.orange,
                    onTap: () => _shareLocation(context, 'email'),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
