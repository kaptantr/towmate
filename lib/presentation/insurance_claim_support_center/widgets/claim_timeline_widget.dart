import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ClaimTimelineWidget extends StatelessWidget {
  final Map<String, dynamic> claim;
  final VoidCallback onTap;

  const ClaimTimelineWidget({
    Key? key,
    required this.claim,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green[700]!;
      case 'under review':
        return Colors.orange[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'pending':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeline = claim['timeline'] as List<Map<String, dynamic>>;
    final progress = claim['progress'] as double;

    return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: Offset(0, 3)),
        ]),
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(claim['id'],
                                  style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[900])),
                              SizedBox(height: 4.h),
                              Text(claim['vehicleInfo'],
                                  style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: Colors.grey[600])),
                            ])),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                                color: _getStatusColor(claim['status'])
                                    .withAlpha(26)),
                            child: Text(claim['status'],
                                style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(claim['status'])))),
                      ]),
                      SizedBox(height: 16.h),

                      // Progress Bar
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Progress',
                                      style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          color: Colors.grey[600])),
                                  Text('${(progress * 100).toInt()}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(
                                              claim['status']))),
                                ]),
                            SizedBox(height: 8.h),
                            LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                    _getStatusColor(claim['status'])),
                                minHeight: 6.h),
                          ]),
                      SizedBox(height: 20.h),

                      // Claim Details
                      Row(children: [
                        Expanded(
                            child: _buildDetailItem('Incident Type',
                                claim['incidentType'], Icons.report_problem)),
                        Expanded(
                            child: _buildDetailItem('Estimated Amount',
                                claim['estimatedAmount'], Icons.payments)),
                      ]),
                      SizedBox(height: 12.h),
                      Row(children: [
                        Expanded(
                            child: _buildDetailItem('Insurance Company',
                                claim['insuranceCompany'], Icons.business)),
                        Expanded(
                            child: _buildDetailItem(
                                'Submitted',
                                DateFormat('MMM dd, yyyy')
                                    .format(claim['submittedDate']),
                                Icons.calendar_today)),
                      ]),
                      SizedBox(height: 20.h),

                      // Timeline Steps
                      Text('Timeline',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900])),
                      SizedBox(height: 12.h),
                      ...timeline.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        final isCompleted = step['completed'] as bool;
                        final isLast = index == timeline.length - 1;

                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                Container(
                                    width: 20.w,
                                    height: 20.w,
                                    decoration: BoxDecoration(
                                        color: isCompleted
                                            ? _getStatusColor(claim['status'])
                                            : Colors.grey[300],
                                        shape: BoxShape.circle),
                                    child: isCompleted
                                        ? Icon(Icons.check,
                                            color: Colors.white, size: 12.sp)
                                        : null),
                                if (!isLast)
                                  Container(
                                      width: 2.w,
                                      height: 24.h,
                                      color: isCompleted
                                          ? _getStatusColor(claim['status'])
                                          : Colors.grey[300]),
                              ]),
                              SizedBox(width: 12.w),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(step['step'],
                                        style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: isCompleted
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            color: isCompleted
                                                ? Colors.grey[900]
                                                : Colors.grey[600])),
                                    if (step['date'] != null)
                                      Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(step['date']),
                                          style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              color: Colors.grey[500])),
                                  ])),
                            ]);
                      }).toList(),
                      SizedBox(height: 16.h),

                      // Action Button
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: _getStatusColor(claim['status'])),
                                  shape: RoundedRectangleBorder(),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 12.h)),
                              child: Text('View Details',
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          _getStatusColor(claim['status']))))),
                    ]))));
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16.sp, color: Colors.grey[500]),
      SizedBox(width: 8.w),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey[500])),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[900]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}
