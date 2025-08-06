import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_icon_widget.dart';

class DocumentUploadCard extends StatelessWidget {
  final String documentType;
  final Map<String, dynamic> requirement;
  final Map<String, dynamic>? uploadedDocument;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;

  const DocumentUploadCard({
    Key? key,
    required this.documentType,
    required this.requirement,
    this.uploadedDocument,
    required this.onUpload,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUploaded = uploadedDocument != null;
    final isRequired = requirement['required'] == true;
    final verificationStatus =
        uploadedDocument?['verification_status'] ?? 'pending';

    return Container(
        margin: EdgeInsets.only(bottom: 3.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    _getBorderColor(isUploaded, verificationStatus, isRequired),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Document Icon
            Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color:
                        _getIconBackgroundColor(isUploaded, verificationStatus),
                    borderRadius: BorderRadius.circular(8)),
                child: CustomIconWidget(
                    iconName: documentType,
                    size: 6.w,
                    color: _getIconColor(isUploaded, verificationStatus))),
            SizedBox(width: 4.w),

            // Document Info
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(requirement['title'] ?? documentType,
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, fontWeight: FontWeight.w600))),
                    if (isRequired)
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('REQUIRED',
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700]))),
                  ]),
                  SizedBox(height: 0.5.h),
                  Text(requirement['description'] ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp, color: Colors.grey[600])),
                  if (isUploaded) ...[
                    SizedBox(height: 1.h),
                    Row(children: [
                      Text(uploadedDocument!['file_name'],
                          style: GoogleFonts.inter(
                              fontSize: 11.sp, color: Colors.grey[500])),
                      SizedBox(width: 2.w),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                              color:
                                  _getStatusBackgroundColor(verificationStatus),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(_getStatusText(verificationStatus),
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusTextColor(
                                      verificationStatus)))),
                    ]),
                  ],
                ])),
          ]),

          SizedBox(height: 3.h),

          // Action Buttons
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: Icon(isUploaded ? Icons.refresh : Icons.upload_file,
                        size: 4.w, color: Colors.white),
                    label: Text(isUploaded ? 'Replace' : 'Upload',
                        style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))))),
            if (isUploaded && onDelete != null) ...[
              SizedBox(width: 3.w),
              ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 4.w, color: Colors.white),
                  label: Text('Delete',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)))),
            ],
          ]),

          // Rejection Reason (if applicable)
          if (verificationStatus == 'rejected' &&
              uploadedDocument?['rejection_reason'] != null) ...[
            SizedBox(height: 2.h),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rejection Reason:',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700])),
                      SizedBox(height: 0.5.h),
                      Text(uploadedDocument!['rejection_reason'],
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, color: Colors.red[600])),
                    ])),
          ],
        ]));
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'drivers_license':
        return Icons.credit_card;
      case 'vehicle_registration':
        return Icons.directions_car;
      case 'insurance_certificate':
        return Icons.security;
      case 'tow_license':
        return Icons.local_shipping;
      case 'vehicle_inspection':
        return Icons.build;
      case 'business_permit':
        return Icons.business;
      case 'criminal_background':
        return Icons.verified_user;
      default:
        return Icons.description;
    }
  }

  Color _getBorderColor(
      bool isUploaded, String verificationStatus, bool isRequired) {
    if (!isUploaded && isRequired) {
      return Colors.red[300]!;
    }

    switch (verificationStatus) {
      case 'verified':
        return Colors.green[400]!;
      case 'rejected':
        return Colors.red[400]!;
      case 'pending':
        return Colors.orange[400]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getIconBackgroundColor(bool isUploaded, String verificationStatus) {
    if (!isUploaded) {
      return Colors.grey[100]!;
    }

    switch (verificationStatus) {
      case 'verified':
        return Colors.green[100]!;
      case 'rejected':
        return Colors.red[100]!;
      case 'pending':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getIconColor(bool isUploaded, String verificationStatus) {
    if (!isUploaded) {
      return Colors.grey[600]!;
    }

    switch (verificationStatus) {
      case 'verified':
        return Colors.green[600]!;
      case 'rejected':
        return Colors.red[600]!;
      case 'pending':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green[100]!;
      case 'rejected':
        return Colors.red[100]!;
      case 'pending':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'pending':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'VERIFIED';
      case 'rejected':
        return 'REJECTED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }
}