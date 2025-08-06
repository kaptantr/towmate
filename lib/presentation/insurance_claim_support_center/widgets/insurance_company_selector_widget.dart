import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class InsuranceCompanySelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> companies;
  final String selectedCompany;
  final Function(String) onCompanySelected;

  const InsuranceCompanySelectorWidget({
    Key? key,
    required this.companies,
    required this.selectedCompany,
    required this.onCompanySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Insurance Company',
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900])),
          SizedBox(height: 8.h),
          Text('Select your insurance company for direct claim submission',
              style: GoogleFonts.inter(
                  fontSize: 14.sp, color: Colors.grey[600], height: 1.4)),
          SizedBox(height: 24.h),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                final isSelected = selectedCompany == company['name'];

                return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: isSelected
                                ? Colors.green[700]!
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ]),
                    child: InkWell(
                        onTap: () => onCompanySelected(company['name']),
                        child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(children: [
                              Row(children: [
                                Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration:
                                        BoxDecoration(color: Colors.grey[100]),
                                    child: ClipRRect(
                                        child: CachedNetworkImage(
                                            imageUrl: company['logo'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors
                                                                .green[700]))),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                    Icons.business,
                                                    color: Colors.grey[400],
                                                    size: 24.sp)))),
                                SizedBox(width: 16.w),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(company['name'],
                                          style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[900])),
                                      SizedBox(height: 4.h),
                                      Text('Direct claim submission available',
                                          style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600])),
                                      SizedBox(height: 8.h),
                                      Row(
                                          children: company['supportedLanguages']
                                              .map<Widget>((lang) => Container(
                                                  margin: EdgeInsets.only(
                                                      right: 4.w),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue[100]),
                                                  child: Text(
                                                      lang.toUpperCase(),
                                                      style: GoogleFonts.inter(
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .blue[700]))))
                                              .toList()),
                                    ])),
                                if (isSelected)
                                  Icon(Icons.check_circle,
                                      color: Colors.green[700], size: 24.sp),
                              ]),
                              if (isSelected) ...[
                                SizedBox(height: 16.h),
                                Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        border: Border.all(
                                            color: Colors.green[200]!)),
                                    child: Column(children: [
                                      Row(children: [
                                        Icon(Icons.phone,
                                            color: Colors.green[700],
                                            size: 16.sp),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                            child: Text(company['claimPhone'],
                                                style: GoogleFonts.inter(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.green[700]))),
                                        IconButton(
                                            onPressed: () async {
                                              final phoneUrl =
                                                  'tel:${company['claimPhone']}';
                                              if (await canLaunchUrl(
                                                  Uri.parse(phoneUrl))) {
                                                await launchUrl(
                                                    Uri.parse(phoneUrl));
                                              }
                                            },
                                            icon: Icon(Icons.call,
                                                color: Colors.green[700],
                                                size: 16.sp)),
                                      ]),
                                      SizedBox(height: 8.h),
                                      Row(children: [
                                        Icon(Icons.web,
                                            color: Colors.green[700],
                                            size: 16.sp),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                            child: Text(
                                                'Online Portal Available',
                                                style: GoogleFonts.inter(
                                                    fontSize: 13.sp,
                                                    color: Colors.green[700]))),
                                        IconButton(
                                            onPressed: () async {
                                              final webUrl =
                                                  company['onlinePortal'];
                                              if (await canLaunchUrl(
                                                  Uri.parse(webUrl))) {
                                                await launchUrl(
                                                    Uri.parse(webUrl));
                                              }
                                            },
                                            icon: Icon(Icons.open_in_new,
                                                color: Colors.green[700],
                                                size: 16.sp)),
                                      ]),
                                    ])),
                              ],
                            ]))));
              }),
          SizedBox(height: 24.h),
          Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange[700], size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('Don\'t see your company?',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700])),
                    ]),
                    SizedBox(height: 8.h),
                    Text(
                        'You can still submit your claim manually. Our system will generate all required documents and help you contact your insurance provider.',
                        style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.orange[600],
                            height: 1.4)),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                        onPressed: () {
                          onCompanySelected('Other Insurance Company');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            shape: RoundedRectangleBorder()),
                        child: Text('Continue with Other Company',
                            style: GoogleFonts.inter(
                                fontSize: 13.sp, color: Colors.white))),
                  ])),
        ]));
  }
}
