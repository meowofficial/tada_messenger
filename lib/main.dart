import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tada_messenger/app_route_generator.dart';
import 'package:tada_messenger/domain/entities/authentication_status.dart';
import 'package:tada_messenger/injection_container.dart' as di;
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/theme/app_text_theme.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/theme/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(App());
}

class App extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  AppThemeData _buildTheme() {
    return AppThemeData(
      brightness: Brightness.light,
      primaryColor: Styles.primaryColor,
      defaultTextColor: Styles.defaultTextColor,
      appBackgroundColor: Styles.appBackgroundColor,
      navigationBarColor: Styles.navigationBarColor,
      dividerColor: Styles.dividerColor,
      placeholderColor: Styles.placeholderColor,
      pressedTileColor: Styles.pressedTileColor,
      tileColor: Styles.tileColor,
      materialAlertDialogBackgroundColor: Styles.materialAlertDialogBackgroundColor,
      loginPageBackgroundColor: Styles.loginPageBackgroundColor,
      textTheme: AppTextTheme(
        defaultFontFamilyText: Styles.defaultFontFamilyTextStyle,
        cupertinoActionSheetMessage: Styles.cupertinoActionSheetMessageTextStyle,
        defaultText: Styles.defaultTextStyle,
        defaultBoldText: Styles.defaultBoldTextStyle,
        title: Styles.titleTextStyle,
        navigationButton: Styles.navigationButtonTextStyle,
        navigationBoldButton: Styles.navigationBoldButtonTextStyle,
        cupertinoAlertDialogBody: Styles.cupertinoAlertDialogBodyTextStyle,
        materialAlertDialogTitle: Styles.materialAlertDialogTitleTextStyle,
        materialAlertDialogContent: Styles.materialAlertDialogContentTextStyle,
        materialAlertDialogActionTitle: Styles.materialAlertDialogActionTitleTextStyle,
        loginPageTitle: Styles.loginPageTitleTextStyle,
        loginTextField: Styles.loginTextFieldTextStyle,
        logInButton: Styles.logInButtonTextStyle,
        menuGroupTitle: Styles.menuGroupTitleTextStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
        bloc: di.sl(),
        listener: (context, state) {
          di.onAuthenticationChanged();
        },
        builder: (context, state) {
          if (state.authenticationStatus == AuthenticationStatus.unknown) {
            return Container();
          }

          return MaterialApp(
            navigatorKey: _navigatorKey,
            builder: (context, child) {
              const brightness = Brightness.light;
              final themeData = _buildTheme();

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: AppTheme(
                  data: themeData,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Styles.primaryColor,
                      primaryColorDark: Styles.primaryColor,
                      brightness: brightness,
                      fontFamily: Styles.defaultFontFamily,
                      pageTransitionsTheme: PageTransitionsTheme(
                        builders: {
                          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                        },
                      ),
                    ),
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        primaryColor: Styles.primaryColor,
                        brightness: brightness,
                        textTheme: CupertinoTextThemeData(
                          textStyle: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                fontFamily: Styles.defaultFontFamily,
                              ),
                          pickerTextStyle:
                              CupertinoTheme.of(context).textTheme.pickerTextStyle.copyWith(
                                    fontFamily: Styles.defaultFontFamily,
                                    color: Styles.defaultTextColor,
                                  ),
                        ),
                      ),
                      child: Material(
                        child: BlocListener<AuthenticationCubit, AuthenticationState>(
                          bloc: di.sl(),
                          listenWhen: (oldState, newState) {
                            return oldState != newState;
                          },
                          listener: (context, state) {
                            switch (state.authenticationStatus) {
                              case AuthenticationStatus.authenticated:
                                _navigatorKey.currentState!.pushNamedAndRemoveUntil<void>(
                                  AppRoutes.rooms,
                                  (route) => false,
                                );
                                break;
                              case AuthenticationStatus.unauthenticated:
                                _navigatorKey.currentState!.pushNamedAndRemoveUntil<void>(
                                  AppRoutes.login,
                                  (route) => false,
                                );
                                break;
                              default:
                                break;
                            }
                          },
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            onGenerateRoute: AppRouteGenerator.generateRoute,
            initialRoute: state.authenticationStatus == AuthenticationStatus.unauthenticated
                ? AppRoutes.login
                : AppRoutes.rooms,
          );
        });
  }
}
