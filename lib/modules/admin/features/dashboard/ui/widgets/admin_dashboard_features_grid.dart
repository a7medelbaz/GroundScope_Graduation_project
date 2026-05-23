import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/core/widgets/admin_feature_card.dart';

class AdminDashboardFeaturesGrid extends StatelessWidget {
  const AdminDashboardFeaturesGrid({super.key});

  static const List<AdminFeatureCardData> _features = [
    AdminFeatureCardData(
      title: 'service_types',
      icon: Icons.build_circle_outlined,
      route: Routes.adminServiceTypesScreen,
      isAvailable: true,
    ),
    AdminFeatureCardData(
      title: 'stands',
      icon: Icons.local_parking_outlined,
      isAvailable: false,
    ),
    AdminFeatureCardData(
      title: 'units',
      icon: Icons.local_shipping_outlined,
      isAvailable: false,
    ),
    AdminFeatureCardData(
      title: 'users',
      icon: Icons.person_outlined,
      isAvailable: false,
    ),
    AdminFeatureCardData(
      title: 'flights',
      icon: Icons.flight_outlined,
      isAvailable: false,
    ),
    AdminFeatureCardData(
      title: 'reports',
      icon: Icons.bar_chart_outlined,
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: rw(12),
      mainAxisSpacing: rh(12),
      childAspectRatio: 1.3,
      children: _features.map((feature) {
        return AdminFeatureCard(
          data: feature,
          onTap: () => _onFeatureTap(context, feature),
        );
      }).toList(),
    );
  }

  void _onFeatureTap(BuildContext context, AdminFeatureCardData feature) {
    if (!feature.isAvailable || feature.route == null) {
      context.showInfoSnackBar('coming_soon'.tr());
      return;
    }
    context.pushNamed(feature.route!);
  }
}
