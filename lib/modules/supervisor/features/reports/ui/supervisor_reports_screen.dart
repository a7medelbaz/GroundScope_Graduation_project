import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/supervisor/core/widgets/supervisor_screen_header.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/supervisor_send_report_screen.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/widgets/report_tab_bar.dart';
import 'package:ground_scope/modules/supervisor/features/reports/ui/widgets/supervisor_report_body.dart';

import '../logic/cubit/supervisor_reports_cubit.dart';

class SupervisorReportsScreen extends StatefulWidget {
  const SupervisorReportsScreen({super.key});

  @override
  State<SupervisorReportsScreen> createState() =>
      _SupervisorReportsScreenState();
}

class _SupervisorReportsScreenState extends State<SupervisorReportsScreen> {
  String get _serviceTypeId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthSuccess ? (auth.userModel.serviceTypeId ?? '') : '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupervisorReportsCubit>().load();
    });
  }

  void _showSendOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.customColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(20))),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(rw(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(
                icon: Icons.groups_rounded,
                label: 'reports.actions.send_to_unit'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SupervisorReportsCubit>(),
                        child: SupervisorSendReportScreen(
                          serviceTypeId: _serviceTypeId,
                          isBroadcast: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
              verticalSpacing(8),
              _ActionTile(
                icon: Icons.campaign_rounded,
                label: 'reports.actions.broadcast'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SupervisorReportsCubit>(),
                        child: SupervisorSendReportScreen(
                          serviceTypeId: _serviceTypeId,
                          isBroadcast: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SupervisorReportsStatus.submitSuccess) {
          context.showMessageSnackBar(
            'reports.send_form.send'.tr(),
            type: SnackBarType.success,
          );
          context.read<SupervisorReportsCubit>().resetSubmitStatus();
        } else if (state.status == SupervisorReportsStatus.failure &&
            state.error != null) {
          context.showMessageSnackBar(
            state.error!.messageKey,
            type: SnackBarType.error,
          );
        }
      },
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SupervisorScreenHeader(
              icon: Icons.flag_rounded,
              title: 'reports.title'.tr(),
              subtitle: 'supervisor_reports_title'.tr(),
              trailing: IconButton(
                onPressed: _showSendOptions,
                icon: const Icon(Icons.add_rounded, color: AppColors.white),
              ),
            ),
            const SupervisorReportTabBar(),
            const Expanded(child: SupervisorReportBody()),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      tileColor: cc.surfaceVariant,
      leading: Icon(icon, color: AppColors.primary200),
      title: Text(label, style: AppTextStyles.font14SemiBold),
    );
  }
}
