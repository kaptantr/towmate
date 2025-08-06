import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoDocumentationWidget extends StatelessWidget {
  final List<XFile> capturedImages;
  final VoidCallback onCapturePhoto;
  final VoidCallback onPickFromGallery;
  final Function(int) onRemoveImage;

  const PhotoDocumentationWidget({
    Key? key,
    required this.capturedImages,
    required this.onCapturePhoto,
    required this.onPickFromGallery,
    required this.onRemoveImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Photo Documentation',
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900])),
          SizedBox(height: 8.h),
          Text(
              'Capture multiple angles of vehicle damage with automatic metadata tagging',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: Colors.grey[600], height: 1.4)),
          SizedBox(height: 24.h),
          Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!)),
              child: Column(children: [
                Icon(Icons.camera_alt, size: 48.sp, color: Colors.blue[700]),
                SizedBox(height: 12.h),
                Text('Photo Guidelines',
                    style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700])),
                SizedBox(height: 8.h),
                Text(
                    '• Take photos from multiple angles\n• Ensure good lighting\n• Include vehicle plates and surroundings\n• Capture close-ups of damage areas\n• Photo location and time are automatically saved',
                    style: GoogleFonts.inter(
                        fontSize: 13.sp, color: Colors.blue[600], height: 1.5)),
              ])),
          SizedBox(height: 24.h),
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: onCapturePhoto,
                    icon: Icon(Icons.camera_alt, size: 20.sp),
                    label: Text('Take Photo',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder()))),
            SizedBox(width: 12.w),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: onPickFromGallery,
                    icon: Icon(Icons.photo_library, size: 20.sp),
                    label: Text('From Gallery',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        foregroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder()))),
          ]),
          if (capturedImages.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text('Captured Photos (${capturedImages.length})',
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900])),
            SizedBox(height: 12.h),
            GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.2),
                itemCount: capturedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 8,
                            offset: Offset(0, 2)),
                      ]),
                      child: Stack(children: [
                        ClipRRect(
                            child: Image.file(File(capturedImages[index].path),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover)),
                        Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                                onTap: () => onRemoveImage(index),
                                child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                        color: Colors.red[700],
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withAlpha(51),
                                              blurRadius: 4,
                                              offset: Offset(0, 2)),
                                        ]),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 16.sp)))),
                        Positioned(
                            bottom: 8.h,
                            left: 8.w,
                            right: 8.w,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(179)),
                                child: Text('Photo ${index + 1}',
                                    style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center))),
                      ]));
                }),
          ],
          if (capturedImages.isEmpty)
            Container(
                height: 120.h,
                width: double.infinity,
                margin: EdgeInsets.only(top: 24.h),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(
                        color: Colors.grey[300]!, style: BorderStyle.solid)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48.sp, color: Colors.grey[400]),
                      SizedBox(height: 8.h),
                      Text('No photos captured yet',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, color: Colors.grey[500])),
                    ])),
        ]));
  }
}
