import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme({
    required this.defaultFontFamilyText,
    required this.cupertinoActionSheetMessage,
    required this.defaultText,
    required this.defaultBoldText,
    required this.title,
    required this.navigationButton,
    required this.navigationBoldButton,
    required this.cupertinoAlertDialogBody,
    required this.materialAlertDialogTitle,
    required this.materialAlertDialogContent,
    required this.materialAlertDialogActionTitle,
    required this.loginPageTitle,
    required this.loginTextField,
    required this.logInButton,
    required this.menuGroupTitle,
  });

  final TextStyle defaultFontFamilyText;
  final TextStyle cupertinoActionSheetMessage;
  final TextStyle defaultText;
  final TextStyle defaultBoldText;
  final TextStyle title;
  final TextStyle navigationButton;
  final TextStyle navigationBoldButton;
  final TextStyle cupertinoAlertDialogBody;
  final TextStyle materialAlertDialogTitle;
  final TextStyle materialAlertDialogContent;
  final TextStyle materialAlertDialogActionTitle;
  final TextStyle loginPageTitle;
  final TextStyle loginTextField;
  final TextStyle logInButton;
  final TextStyle menuGroupTitle;
}
