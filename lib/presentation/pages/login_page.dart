import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tada_messenger/injection_container.dart' as di;
import 'package:tada_messenger/presentation/blocs/login_page/login_page_cubit.dart';
import 'package:tada_messenger/presentation/models/username_input.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/widgets/material_alert_dialog.dart';
import 'package:tada_messenger/presentation/widgets/platform_keyboard_placeholder.dart';
import 'package:tada_messenger/presentation/widgets/sizable_button.dart';

class LoginPage extends StatefulWidget {
  static Route route({
    required RouteSettings settings,
  }) {
    return CupertinoPageRoute<void>(
      settings: settings,
      builder: (context) {
        return LoginPage();
      },
    );
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginPageCubit _loginPageCubit;

  String _getSubmissionErrorMessage(LoginFormSubmissionFailure submissionFailure) {
    if (submissionFailure is LoginFormSubmissionNetworkFailure) {
      return 'Something went wrong. Check your Internet connection and try again.';
    } else if (submissionFailure is LoginFormSubmissionValidationFailure) {
      if (submissionFailure.validationError is UsernameValidationError) {
        switch (submissionFailure.validationError.runtimeType) {
          case EmptyUsernameValidationError:
            return "The username shouldn't be empty.";
          case WrongSymbolUsernameValidationError:
            return 'The username can only contain Latin letters and numbers and should start with a letter.';
        }
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loginPageCubit = LoginPageCubit(
      authenticationRepository: di.sl(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _loginPageCubit,
      child: BlocListener<LoginPageCubit, LoginPageState>(
        bloc: _loginPageCubit,
        listener: (context, state) async {
          if (state.submissionStatus is LoginFormSubmissionFailure) {
            if (Platform.isIOS) {
              await showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    content: Text(
                      _getSubmissionErrorMessage(
                          state.submissionStatus as LoginFormSubmissionFailure),
                      style: AppTheme.of(context).textTheme.cupertinoAlertDialogBody,
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          'OK',
                          style: AppTheme.of(context).textTheme.defaultFontFamilyText,
                        ),
                        onPressed: Navigator.of(context).pop,
                      ),
                    ],
                  );
                },
              );
            } else if (Platform.isAndroid) {
              await showDialog(
                context: context,
                builder: (context) {
                  return MaterialAlertDialog(
                    content: _getSubmissionErrorMessage(
                        state.submissionStatus as LoginFormSubmissionFailure),
                    actions: [
                      MaterialAlertDialogAction(
                        title: 'OK',
                        onPressed: Navigator.of(context).pop,
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
        child: CupertinoPageScaffold(
          resizeToAvoidBottomInset: false,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: AppTheme.of(context).loginPageBackgroundColor,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height / 5,
                                  ),
                                  Text.rich(TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Tada ',
                                        style:
                                            AppTheme.of(context).textTheme.loginPageTitle.copyWith(
                                                  color: AppTheme.of(context).primaryColor,
                                                ),
                                      ),
                                      TextSpan(
                                        text: 'Messenger',
                                        style: AppTheme.of(context).textTheme.loginPageTitle,
                                      ),
                                    ],
                                  )),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  _LoginTextField(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  _LoginButton(
                                    onPressed: _loginPageCubit.logIn,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PlatformKeyboardPlaceholder(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginPageCubit, LoginPageState>(
      buildWhen: (previousState, currentState) {
        return previousState.usernameInput != currentState.usernameInput;
      },
      builder: (context, state) {
        return CupertinoTextField(
          padding: EdgeInsets.all(13),
          autocorrect: false,
          enableSuggestions: false,
          textAlign: TextAlign.center,
          style: AppTheme.of(context).textTheme.loginTextField,
          cursorColor: AppTheme.of(context).primaryColor,
          keyboardType: TextInputType.visiblePassword,
          maxLength: UsernameInput.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          placeholder: 'Login',
          onChanged: context.read<LoginPageCubit>().usernameChanged,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginPageCubit, LoginPageState>(
      buildWhen: (previousState, currentState) {
        return previousState.submissionStatus != currentState.submissionStatus;
      },
      builder: (context, state) {
        return SizableButton(
          color: AppTheme.of(context).primaryColor,
          child: state.submissionStatus == LoginFormSubmissionInProgress()
              ? SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    backgroundColor: AppTheme.of(context).primaryColor,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.of(context).loginPageBackgroundColor),
                  ),
                )
              : Text(
                  'Log In',
                  style: AppTheme.of(context).textTheme.logInButton,
                ),
          borderRadius: 8,
          height: 55,
          onPressed: onPressed,
        );
      },
    );
  }
}
