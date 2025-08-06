import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

class EmergencyNotificationOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final Map<String, dynamic> notification;

  const EmergencyNotificationOverlay({
    Key? key,
    required this.onDismiss,
    required this.notification,
  }) : super(key: key);

  @override
  State<EmergencyNotificationOverlay> createState() =>
      _EmergencyNotificationOverlayState();
}

class _EmergencyNotificationOverlayState
    extends State<EmergencyNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.elasticOut));

    _animationController.forward();

    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Auto-dismiss after 10 seconds if not manually dismissed
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                          margin: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.red[700]!, Colors.red[900]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.red.withAlpha(77),
                                    blurRadius: 20,
                                    offset: Offset(0, 5)),
                              ]),
                          child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: _dismissWithAnimation,
                                  child: Padding(
                                      padding: EdgeInsets.all(20.w),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Icon(Icons.warning,
                                                  color: Colors.white,
                                                  size: 28.sp),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                  child: Text('EMERGENCY ALERT',
                                                      style: GoogleFonts.inter(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5))),
                                              IconButton(
                                                  onPressed:
                                                      _dismissWithAnimation,
                                                  icon: Icon(Icons.close,
                                                      color: Colors.white,
                                                      size: 24.sp)),
                                            ]),
                                            SizedBox(height: 12.h),
                                            Text(
                                                widget.notification['title'] ??
                                                    'Emergency Notification',
                                                style: GoogleFonts.inter(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    height: 1.3)),
                                            SizedBox(height: 8.h),
                                            Text(
                                                widget.notification['body'] ??
                                                    'Please take immediate action.',
                                                style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    color: Colors.white
                                                        .withAlpha(230),
                                                    height: 1.4)),
                                            SizedBox(height: 16.h),
                                            Row(children: [
                                              Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        // Handle emergency action
                                                        _dismissWithAnimation();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.red[700],
                                                          shape:
                                                              RoundedRectangleBorder(),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      12.h)),
                                                      child: Text('ACKNOWLEDGE',
                                                          style: GoogleFonts.inter(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)))),
                                              SizedBox(width: 12.w),
                                              OutlinedButton(
                                                  onPressed: () {
                                                    // Handle call emergency
                                                    _dismissWithAnimation();
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          color: Colors.white,
                                                          width: 2),
                                                      shape:
                                                          RoundedRectangleBorder(),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.w,
                                                              vertical: 12.h)),
                                                  child: Icon(Icons.phone,
                                                      color: Colors.white,
                                                      size: 20.sp)),
                                            ]),
                                          ]))))))));
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
