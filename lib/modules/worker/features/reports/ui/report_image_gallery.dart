import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/spacing.dart';

class ReportImageGallery extends StatelessWidget {
  final List<String> images;

  const ReportImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // Height for the entire gallery section
    final double galleryHeight = responsiveHeight(280);
    // Width for each individual image card
    final double imageWidth =
        MediaQuery.of(context).size.width * 0.85;

    if (images.isEmpty) {
      return _buildPlaceholder(
        height: galleryHeight,
        width: double.infinity,
        message: 'No images attached to this report',
        icon: Icons.image_not_supported_outlined,
      );
    }

    return SizedBox(
      height: galleryHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // BouncingScrollPhysics gives it a premium "iOS" feel
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            // Extra spacing between big images
            padding: EdgeInsetsDirectional.only(
              end: responsiveWidth(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                responsiveRadius(16),
              ),
              child: Image.network(
                images[index],
                width: imageWidth,
                height: galleryHeight,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(
                    height: galleryHeight,
                    width: imageWidth,
                    isLoading: true,
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(
                      height: galleryHeight,
                      width: imageWidth,
                      message: 'Failed to load image',
                      icon: Icons.broken_image,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder({
    required double height,
    required double width,
    String? message,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(responsiveRadius(16)),
        border: Border.all(color: AppColors.grey700, width: 1.5),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(strokeWidth: 3)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.grey500, size: 48),
                  if (message != null) ...[
                    verticalSpacing(12),
                    Text(
                      message,
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
