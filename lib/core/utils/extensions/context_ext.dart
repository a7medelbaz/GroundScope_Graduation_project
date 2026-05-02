import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/widgets/massage_snack_bar.dart';

import '../../themes/custom_colors.dart';

// ─── Theme ───────────────────────────────────────────────────────────────────

extension ThemeExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  CustomColors get customColors => theme.customColors;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}

extension CustomColorsExtension on ThemeData {
  CustomColors get customColors => brightness == Brightness.light
      ? CustomColors.light()
      : CustomColors.dark();
}

// ─── MediaQuery ───────────────────────────────────────────────────────────────

extension MediaQueryExt on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
}

// ─── Locale & Font ───────────────────────────────────────────────────────────

extension LocaleExt on BuildContext {
  Locale get currentLocale => EasyLocalization.of(this)!.locale;
  bool get isArabic => currentLocale.languageCode == 'ar';
}

// ─── SnackBar ─────────────────────────────────────────────────────────────────
enum SnackBarType { error, success }

extension SnackBarExt on BuildContext {
  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(
    final String message, {
    final Duration duration = const Duration(seconds: 3),
    final SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration, action: action),
    );
  }

  void showErrorSnackBar(final String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(final String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showMessageSnackBar(
    // BuildContext context,
    String message, {
    required SnackBarType type,
  }) {
    final overlay = Overlay.of(this);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => MessageSnackBar(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

// ─── Navigation ───────────────────────────────────────────────────────────────

extension NavigationExt on BuildContext {
  // Push a Widget
  Future<T?> push<T>(final Widget page, {bool rootNavigator = false}) {
    final route = MaterialPageRoute<T>(builder: (final _) => page);
    return rootNavigator
        ? Navigator.of(this, rootNavigator: true).push(route)
        : Navigator.push(this, route);
  }

  // Push Replacement Widget
  Future<T?> pushReplacement<T, TO>(
    final Widget page, {
    final TO? result,
    bool rootNavigator = false,
  }) {
    final route = MaterialPageRoute<T>(builder: (final _) => page);
    return rootNavigator
        ? Navigator.of(
            this,
            rootNavigator: true,
          ).pushReplacement(route, result: result)
        : Navigator.pushReplacement(this, route, result: result);
  }

  // Push Widget and Remove All
  Future<T?> pushAndRemoveAll<T>(
    final Widget page, {
    bool rootNavigator = false,
  }) {
    final route = MaterialPageRoute<T>(builder: (final _) => page);
    return rootNavigator
        ? Navigator.of(
            this,
            rootNavigator: true,
          ).pushAndRemoveUntil(route, (final _) => false)
        : Navigator.pushAndRemoveUntil(this, route, (final _) => false);
  }

  // Pop
  void pop<T>([final T? result, bool rootNavigator = false]) {
    if (mounted) {
      rootNavigator
          ? Navigator.of(this, rootNavigator: true).pop(result)
          : Navigator.pop(this, result);
    }
  }

  // Push Named Route
  Future<T?> pushNamed<T>(
    final String routeName, {
    final Object? arguments,
    bool rootNavigator = false,
  }) {
    return rootNavigator
        ? Navigator.of(
            this,
            rootNavigator: true,
          ).pushNamed<T>(routeName, arguments: arguments)
        : Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  // Push Replacement Named Route
  Future<T?> pushReplacementNamed<T, TO>(
    final String routeName, {
    final Object? arguments,
    final TO? result,
    bool rootNavigator = false,
  }) {
    return rootNavigator
        ? Navigator.of(this, rootNavigator: true).pushReplacementNamed(
            routeName,
            arguments: arguments,
            result: result,
          )
        : Navigator.pushReplacementNamed(
            this,
            routeName,
            arguments: arguments,
            result: result,
          );
  }

  // Push Named Route and Remove All
  Future<T?> pushNamedAndRemoveAll<T>(
    final String routeName, {
    final Object? arguments,
    bool rootNavigator = false,
  }) {
    return rootNavigator
        ? Navigator.of(this, rootNavigator: true).pushNamedAndRemoveUntil(
            routeName,
            (final _) => false,
            arguments: arguments,
          )
        : Navigator.pushNamedAndRemoveUntil(
            this,
            routeName,
            (final _) => false,
            arguments: arguments,
          );
  }
}
