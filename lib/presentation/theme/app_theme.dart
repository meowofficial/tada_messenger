import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_text_theme.dart';

class AppTheme extends InheritedTheme {
  const AppTheme({
    required this.data,
    required Widget child,
    Key? key,
  })  : super(key: key, child: child);

  final AppThemeData data;

  static AppThemeData of(BuildContext context) {
    final AppTheme inheritedAppTheme =
        context.dependOnInheritedWidgetOfExactType<AppTheme>()!;
    AppThemeData appTheme = inheritedAppTheme.data;
    return appTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final AppTheme? ancestorTheme =
        context.findAncestorWidgetOfExactType<AppTheme>();
    return identical(this, ancestorTheme)
        ? child
        : AppTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => true;
}

class AppThemeData with Diagnosticable {
  const AppThemeData({
    required this.brightness,
    required this.primaryColor,
    required this.defaultTextColor,
    required this.appBackgroundColor,
    required this.navigationBarColor,
    required this.tileColor,
    required this.pressedTileColor,
    required this.dividerColor,
    required this.placeholderColor,
    required this.materialAlertDialogBackgroundColor,
    required this.loginPageBackgroundColor,
    required this.textTheme,
  });

  final Brightness brightness;
  final Color primaryColor;
  final Color defaultTextColor;
  final Color appBackgroundColor;
  final Color navigationBarColor;
  final Color tileColor;
  final Color pressedTileColor;
  final Color dividerColor;
  final Color placeholderColor;
  final Color materialAlertDialogBackgroundColor;
  final Color loginPageBackgroundColor;
  final AppTextTheme textTheme;
}
