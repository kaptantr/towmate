import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationSearchWidget extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final bool isListening;
  final VoidCallback onVoiceSearch;

  const NotificationSearchWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.isListening,
    required this.onVoiceSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: Colors.blue[700],
        child: Container(
            decoration: BoxDecoration(color: Colors.white.withAlpha(51)),
            child: TextField(
                onChanged: onSearchChanged,
                style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp, color: Colors.white70),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.white70, size: 20.sp),
                    suffixIcon: IconButton(
                        onPressed: onVoiceSearch,
                        icon: Icon(isListening ? Icons.mic : Icons.mic_none,
                            color:
                                isListening ? Colors.red[400] : Colors.white70,
                            size: 20.sp)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h)))));
  }
}
