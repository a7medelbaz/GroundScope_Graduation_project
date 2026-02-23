import 'package:flutter/material.dart';
import 'navigation_transitions.dart';

extension Navigation on BuildContext {
  /// Push a new route by widget with default transition
  void push(Widget page) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new route with slide from right to left (Home → Profile)
  void pushSlideRight(Widget page) {
    Navigator.push(this, SlideRightRoute(page));
  }

  /// Push a new route with slide from left to right (Profile → Home)
  void pushSlideLeft(Widget page) {
    Navigator.push(this, SlideLeftRoute(page));
  }

  /// Push a new route with slide from bottom to top (Home → Task Details)
  void pushSlideUp(Widget page) {
    Navigator.push(this, SlideUpRoute(page));
  }

  /// Push a new route with slide from top to bottom (Task Details → Home)
  void pushSlideDown(Widget page) {
    Navigator.push(this, SlideDownRoute(page));
  }

  /// Replace current screen with a new one
  void pushReplacement(Widget page) {
    Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));
  }

  /// Push and remove all previous routes
  void pushAndRemoveUntil(Widget page) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop current route
  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }

  /// Push a named route
  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  /// Push replacement with a named route
  void pushReplacementNamed(String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
  }

  /// Push named and remove all
  void pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}
