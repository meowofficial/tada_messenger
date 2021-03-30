import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class Styles {
  static const Color primaryColor = Color(0xffe91e63);

  static const Color defaultTextColor = Color(0xff000000);

  static const Color appBackgroundColor = Color(0xfff2f2f7);

  static const Color navigationBarColor = Color(0xffffffff);

  static const Color tileColor = Color(0xffffffff);

  static const Color pressedTileColor = Color(0xffd1d1d6);

  static const Color dividerColor = Color(0xffc6c6c8);

  static const Color placeholderColor = Color(0xffc3c4c6);

  static const Color materialAlertDialogBackgroundColor = Colors.white;

  static const Color loginPageBackgroundColor = Colors.white;

  static const Color menuGroupTitleColor = Color(0xff6d6d72);

  static const String defaultFontFamily = 'SF Pro Text';

  static const TextStyle defaultFontFamilyTextStyle = TextStyle(
    fontFamily: defaultFontFamily,
  );

  static const TextStyle cupertinoActionSheetMessageTextStyle = TextStyle(
    fontFamily: defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: defaultFontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    decoration: TextDecoration.none,
    color: defaultTextColor,
  );

  static TextStyle defaultBoldTextStyle = defaultTextStyle.copyWith(
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleTextStyle = defaultTextStyle.copyWith(
    letterSpacing: 0,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle navigationButtonTextStyle = defaultTextStyle.copyWith(
    fontSize: 17,
    letterSpacing: -0.41,
    color: Styles.primaryColor,
  );

  static TextStyle navigationBoldButtonTextStyle = navigationButtonTextStyle.copyWith(
    fontWeight: FontWeight.w600,
  );

  static TextStyle cupertinoAlertDialogBodyTextStyle = TextStyle(
    fontFamily: defaultFontFamily,
    letterSpacing: 0,
  );

  static TextStyle materialAlertDialogTitleTextStyle = defaultTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static TextStyle materialAlertDialogContentTextStyle = defaultTextStyle.copyWith(
    fontSize: 17.5,
  );

  static TextStyle materialAlertDialogActionTitleTextStyle = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryColor,
  );

  static TextStyle loginPageTitleTextStyle = defaultTextStyle.copyWith(
    fontSize: 35,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle loginTextFieldTextStyle = defaultTextStyle.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w400,
  );

  static TextStyle logInButtonTextStyle = defaultTextStyle.copyWith(
    fontSize: 20,
    color: Colors.white,
    letterSpacing: 0,
  );

  static TextStyle menuGroupTitleTextStyle = defaultTextStyle.copyWith(
    fontSize: 13,
    letterSpacing: 0,
    color: menuGroupTitleColor,
  );
}
