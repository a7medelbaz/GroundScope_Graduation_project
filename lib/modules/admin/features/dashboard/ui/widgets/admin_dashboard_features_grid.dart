import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_feature_card.dart';

class AdminDashboardFeaturesGrid extends StatelessWidget {
  const AdminDashboardFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      AdminFeatureCardData(
        title: 'service_types',
        icon: Icons.build_circle_outlined,
        route: Routes.adminServiceTypesScreen,
        iconColor: AppColors.primary200,
        subtitle: 'manage_service_types'.tr(),
        isAvailable: true,
      ),
      AdminFeatureCardData(
        title: 'stands',
        icon: Icons.local_parking_outlined,
        route: Routes.adminStandsScreen,
        iconColor: AppColors.blue200,
        subtitle: 'manage_stands'.tr(),
        isAvailable: true,
      ),
      AdminFeatureCardData(
        title: 'units',
        icon: Icons.groups_outlined,
        route: Routes.adminUnitsScreen,
        iconColor: AppColors.green200,
        subtitle: 'manage_units'.tr(),
        isAvailable: true,
      ),
      AdminFeatureCardData(
        title: 'users',
        icon: Icons.people_outline_rounded,
        iconColor: AppColors.amber200,
        subtitle: 'manage_users'.tr(),
        isAvailable: true,
      ),
      AdminFeatureCardData(
        title: 'flights',
        icon: Icons.flight_outlined,
        route: Routes.adminFlightsScreen,
        iconColor: AppColors.secondary200,
        subtitle: 'manage_flights'.tr(),
        isAvailable: true,
      ),
      AdminFeatureCardData(
        title: 'reports',
        icon: Icons.bar_chart_outlined,
        iconColor: AppColors.primary300,
        subtitle: 'manage_reports'.tr(),
        isAvailable: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: rw(12),
        mainAxisSpacing: rh(12),
        childAspectRatio: 0.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final delay = Duration(milliseconds: 400 + (index * 50).clamp(0, 300));
        return AdminFeatureCard(
          data: feature,
          animationDelay: delay,
          onTap: () {
            if (feature.route != null) {
              context.pushNamed(feature.route!);
            } else {
              context.showInfoSnackBar('coming_soon'.tr());
            }
          },
        );
      },
    );
  }
}
