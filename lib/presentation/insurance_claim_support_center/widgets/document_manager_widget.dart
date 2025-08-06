import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class DocumentManagerWidget extends StatelessWidget {
  final List<PlatformFile> uploadedDocuments;
  final VoidCallback onUploadDocument;
  final Function(int) onRemoveDocument;
  final Function(PlatformFile) onShareDocument;

  const DocumentManagerWidget({
    Key? key,
    required this.uploadedDocuments,
    required this.onUploadDocument,
    required this.onRemoveDocument,
    required this.onShareDocument,
  }) : super(key: key);

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red[700]!;
      case 'doc':
      case 'docx':
        return Colors.blue[700]!;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Document Manager',
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900])),
          SizedBox(height: 8.h),
          Text(
              'Store photos, receipts, police reports, and correspondence with secure cloud backup',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: Colors.grey[600], height: 1.4)),
          SizedBox(height: 24.h),

          // Upload Section
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(
                      color: Colors.blue[200]!, style: BorderStyle.solid)),
              child: Column(children: [
                Icon(Icons.cloud_upload, size: 48.sp, color: Colors.blue[700]),
                SizedBox(height: 16.h),
                Text('Upload Documents',
                    style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700])),
                SizedBox(height: 8.h),
                Text(
                    'Support: PDF, DOC, DOCX, JPG, PNG\nMax size: 10MB per file',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.blue[600]),
                    textAlign: TextAlign.center),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                    onPressed: onUploadDocument,
                    icon: Icon(Icons.add, size: 20.sp),
                    label: Text('Choose Files',
                        style: GoogleFonts.inter(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder())),
              ])),
          SizedBox(height: 24.h),

          // Documents List
          if (uploadedDocuments.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Uploaded Documents (${uploadedDocuments.length})',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900])),
              TextButton.icon(
                  onPressed: () {
                    // Export all documents
                  },
                  icon: Icon(Icons.download, size: 16.sp),
                  label: Text('Export All',
                      style: GoogleFonts.inter(fontSize: 12.sp))),
            ]),
            SizedBox(height: 12.h),
            Expanded(
                child: ListView.builder(
                    itemCount: uploadedDocuments.length,
                    itemBuilder: (context, index) {
                      final document = uploadedDocuments[index];
                      final extension = document.extension ?? '';

                      return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ]),
                          child: ListTile(
                              contentPadding: EdgeInsets.all(16.w),
                              leading: Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                      color: _getFileColor(extension)
                                          .withAlpha(26)),
                                  child: Icon(_getFileIcon(extension),
                                      color: _getFileColor(extension),
                                      size: 24.sp)),
                              title: Text(document.name,
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[900]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4.h),
                                    Text(
                                        '${_formatFileSize(document.size)} • ${extension.toUpperCase()}',
                                        style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600])),
                                    Text(
                                        'Uploaded ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                                        style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: Colors.grey[500])),
                                  ]),
                              trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'share':
                                        onShareDocument(document);
                                        break;
                                      case 'remove':
                                        _showRemoveConfirmation(context, index);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                            value: 'share',
                                            child: Row(children: [
                                              Icon(Icons.share,
                                                  size: 16.sp,
                                                  color: Colors.grey[700]),
                                              SizedBox(width: 8.w),
                                              Text('Share',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 13.sp)),
                                            ])),
                                        PopupMenuItem(
                                            value: 'remove',
                                            child: Row(children: [
                                              Icon(Icons.delete,
                                                  size: 16.sp,
                                                  color: Colors.red[700]),
                                              SizedBox(width: 8.w),
                                              Text('Remove',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 13.sp,
                                                      color: Colors.red[700])),
                                            ])),
                                      ],
                                  child: Icon(Icons.more_vert,
                                      color: Colors.grey[600]))));
                    })),
          ] else
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.folder_open, size: 64.sp, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text('No documents uploaded',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Text('Upload documents to keep them organized and secure',
                      style: GoogleFonts.inter(
                          fontSize: 14.sp, color: Colors.grey[500]),
                      textAlign: TextAlign.center),
                ])),
        ]));
  }

  void _showRemoveConfirmation(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Remove Document',
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, fontWeight: FontWeight.w600)),
                content: Text(
                    'Are you sure you want to remove this document? This action cannot be undone.',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, color: Colors.grey[700])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRemoveDocument(index);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700]),
                      child: Text('Remove',
                          style: TextStyle(color: Colors.white))),
                ]));
  }
}
