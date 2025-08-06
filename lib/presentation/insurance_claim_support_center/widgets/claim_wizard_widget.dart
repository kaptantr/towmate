import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ClaimWizardWidget extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int) onStepTapped;

  const ClaimWizardWidget({
    Key? key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: Offset(0, 2)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step ${currentStep + 1} of ${steps.length}',
              style:
                  GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(steps[currentStep],
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900])),
          SizedBox(height: 16.h),
          Row(
              children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
                child: GestureDetector(
                    onTap: () => onStepTapped(index),
                    child: Container(
                        margin: EdgeInsets.only(
                            right: index < steps.length - 1 ? 8.w : 0),
                        child: Column(children: [
                          Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                  color: isCompleted || isActive
                                      ? Colors.green[700]
                                      : Colors.grey[300])),
                          SizedBox(height: 8.h),
                          if (isActive)
                            Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    shape: BoxShape.circle)),
                        ]))));
          })),
        ]));
  }
}
