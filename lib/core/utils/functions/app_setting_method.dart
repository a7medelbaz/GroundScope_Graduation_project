import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/cubit/app_settings_cubit.dart';

/// Switch Language between Arabic and English
void switchLanguage(final BuildContext context) {
  context.read<AppSettingsCubit>().toggleLocale(context);
}

/// Switch Theme between Light and Dark
void switchTheme(final BuildContext context) {
  context.read<AppSettingsCubit>().toggleTheme();
}
