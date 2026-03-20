import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/core/widgets/custom_rounded_app_bar.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/personal_info_container.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/settings_container.dart';
import '../../../../../core/utils/spacing.dart';

class PersonalInfoSettings extends StatelessWidget {
  const PersonalInfoSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomRoundedAppBar(
          title: 'worker_profile.profile'.tr(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(responsiveRadius(15)),
            child: Column(
              children: [
                verticalSpacing(15),
                const PersonalInfoContainer(),
                verticalSpacing(20),
                const SettingsContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
