import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/reports/data/models/report_model.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/report_image_gallery.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/spacing.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ReportModel report;
  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: responsiveHeight(30),
            ),
          ),
          title: Text(
            'Report Details',
            style: AppTextStyles.font18SemiBold,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(45),
                Text(report.title, style: AppTextStyles.font24Bold),
                verticalSpacing(8),
                Text(
                  report.description,
                  style: AppTextStyles.font16Regular,
                ),
                Text(
                  'DATE: ${DateFormat('dd-MM-yyyy').format(report.date)}',
                  style: AppTextStyles.font16Regular,
                ),
                verticalSpacing(24),
                // 1. Description Header
                Text(
                  'Description',
                  style: AppTextStyles.font18SemiBold.copyWith(
                    color: AppColors
                        .lightBlue, // Using your brand color for the label
                  ),
                ),
                verticalSpacing(8),
                // 2. The actual Description content
                Text(
                  report.description,
                  style: AppTextStyles.font16Regular.copyWith(
                    height: 1.5, // Better readability for long text
                    color: AppColors.white,
                  ),
                ),
                verticalSpacing(50),
                ReportImageGallery(images: report.images),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
