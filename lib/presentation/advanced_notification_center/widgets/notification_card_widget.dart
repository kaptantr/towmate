import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCardWidget extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final Future<String> Function(String) onTranslate;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onTranslate,
  }) : super(key: key);

  @override
  State<NotificationCardWidget> createState() => _NotificationCardWidgetState();
}

class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  bool _isExpanded = false;
  bool _isTranslated = false;
  String _translatedTitle = '';
  String _translatedBody = '';

  Color _getPriorityColor() {
    switch (widget.notification['priority']) {
      case 'emergency':
        return Colors.red[700]!;
      case 'high':
        return Colors.orange[700]!;
      case 'medium':
        return Colors.blue[700]!;
      case 'low':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.notification['category']) {
      case 'service_updates':
        return Icons.build;
      case 'system_alerts':
        return Icons.info;
      case 'promotions':
        return Icons.local_offer;
      case 'emergency':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _toggleTranslation() async {
    if (!_isTranslated) {
      _translatedTitle = await widget.onTranslate(widget.notification['title']);
      _translatedBody = await widget.onTranslate(widget.notification['body']);
    }
    setState(() {
      _isTranslated = !_isTranslated;
    });
  }

  void _openLocation() async {
    if (widget.notification['location'] != null) {
      final location = widget.notification['location'];
      final url =
          'https://maps.google.com/?q=${location['lat']},${location['lng']}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.notification['timestamp'] as DateTime;
    final timeAgo = _getTimeAgo(timestamp);
    final isRead = widget.notification['isRead'] as bool;

    return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: Offset(0, 2)),
            ],
            border: Border.all(
                color: isRead ? Colors.transparent : _getPriorityColor(),
                width: isRead ? 0 : 2)),
        child: InkWell(
            onTap: () {
              widget.onTap();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                    color: _getPriorityColor().withAlpha(26)),
                                child: Icon(_getCategoryIcon(),
                                    color: _getPriorityColor(), size: 20.sp)),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text(
                                            _isTranslated
                                                ? _translatedTitle
                                                : widget.notification['title'],
                                            style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w600,
                                                color: Colors.grey[900]))),
                                    if (!isRead)
                                      Container(
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: BoxDecoration(
                                              color: _getPriorityColor(),
                                              shape: BoxShape.circle)),
                                  ]),
                                  SizedBox(height: 4.h),
                                  Text(timeAgo,
                                      style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600])),
                                ])),
                            if (widget.notification['priority'] == 'emergency')
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration:
                                      BoxDecoration(color: Colors.red[100]),
                                  child: Text('URGENT',
                                      style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[700]))),
                          ]),
                      SizedBox(height: 12.h),
                      Text(
                          _isTranslated
                              ? _translatedBody
                              : widget.notification['body'],
                          style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                              height: 1.4),
                          maxLines: _isExpanded ? null : 2,
                          overflow: _isExpanded ? null : TextOverflow.ellipsis),
                      if (_isExpanded) ...[
                        SizedBox(height: 16.h),
                        if (widget.notification['hasMedia'] == true)
                          Container(
                              height: 120.h,
                              width: double.infinity,
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              child: ClipRRect(
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1558618047-3c8c89c99013?w=400',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      _getPriorityColor()))),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.grey[400],
                                                  size: 32.sp))))),
                        SizedBox(height: 12.h),
                        Row(children: [
                          if (widget.notification['actionRequired'] == true)
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      // Handle action
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _getPriorityColor(),
                                        shape: RoundedRectangleBorder()),
                                    child: Text('Take Action',
                                        style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)))),
                          if (widget.notification['actionRequired'] == true &&
                              widget.notification['location'] != null)
                            SizedBox(width: 8.w),
                          if (widget.notification['location'] != null)
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: _openLocation,
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: _getPriorityColor()),
                                        shape: RoundedRectangleBorder()),
                                    child: Text('View Location',
                                        style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: _getPriorityColor())))),
                          SizedBox(width: 8.w),
                          IconButton(
                              onPressed: _toggleTranslation,
                              icon: Icon(
                                  _isTranslated
                                      ? Icons.help_outline
                                      : Icons.translate,
                                  color: _getPriorityColor(),
                                  size: 20.sp)),
                        ]),
                      ],
                    ]))));
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}
