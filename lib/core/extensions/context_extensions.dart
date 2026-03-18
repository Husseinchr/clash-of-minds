import 'package:flutter/material.dart';

/// Context extensions for easier access to theme and navigation
extension ContextExtensions on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get the screen width
  double get width => MediaQuery.of(this).size.width;

  /// Get the screen height
  double get height => MediaQuery.of(this).size.height;

  /// Show a snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Navigate to a route
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Replace current route
  Future<T?> pushReplacement<T extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement<T, T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pop the current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
