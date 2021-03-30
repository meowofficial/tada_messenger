import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tada_messenger/injection_container.dart' as di;
import 'package:tada_messenger/presentation/blocs/room_creation_page/room_creation_page_cubit.dart';
import 'package:tada_messenger/presentation/models/message_input.dart';
import 'package:tada_messenger/presentation/models/room_name_input.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/widgets/cupertino_modal_navigation_bar.dart';
import 'package:tada_messenger/presentation/widgets/material_alert_dialog.dart';
import 'package:tada_messenger/presentation/widgets/menu_group.dart';
import 'package:tada_messenger/presentation/widgets/navigation_button.dart';
import 'package:tada_messenger/presentation/widgets/platform_divider.dart';
import 'package:tada_messenger/presentation/widgets/platform_keyboard_placeholder.dart';

class RoomCreationPage extends StatefulWidget {
  @override
  _RoomCreationPageState createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  late RoomCreationPageCubit _roomCreationPageCubit;

  String _getSubmissionErrorMessage(NewRoomSubmissionFailure newRoomSubmissionFailure) {
    if (newRoomSubmissionFailure is NewRoomSubmissionValidationFailure) {
      final newRoomSubmissionValidationFailure = newRoomSubmissionFailure;
      final validationError = newRoomSubmissionValidationFailure.validationError;
      if (validationError is RoomNameValidationError) {
        switch (validationError.runtimeType) {
          case EmptyRoomNameValidationError:
            return "The room name shouldn't be empty.";
        }
      } else if (validationError is MessageValidationError) {
        switch (validationError.runtimeType) {
          case EmptyMessageValidationError:
            return "The message shouldn't be empty.";
        }
      }
    } else if (newRoomSubmissionFailure is NewRoomSubmissionExistenceFailure) {
      return 'This room already exists.';
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    _roomCreationPageCubit = RoomCreationPageCubit(
      messagesCubit: di.sl(),
      authenticationCubit: di.sl(),
      serverConnectionCubit: di.sl(),
    );
  }

  @override
  void dispose() {
    _roomCreationPageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomCreationPageCubit, RoomCreationPageState>(
      bloc: _roomCreationPageCubit,
      listener: (context, state) async {
        if (state.submissionStatus is NewRoomSubmissionSuccess) {
          Navigator.of(context).pop();
        } else if (state.submissionStatus is NewRoomSubmissionFailure) {
          if (Platform.isIOS) {
            await showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  content: Text(
                    _getSubmissionErrorMessage(state.submissionStatus as NewRoomSubmissionFailure),
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
                      state.submissionStatus as NewRoomSubmissionFailure),
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
        backgroundColor: Color(0xfff2f2f7),
        navigationBar: CupertinoModalNavigationBar(
          padding: EdgeInsetsDirectional.zero,
          middle: Text(
            'New Room',
            style: AppTheme.of(context).textTheme.title,
          ),
          leading: NavigationButton(
            text: 'Cancel',
            textStyle: AppTheme.of(context).textTheme.navigationButton,
            onPressed: Navigator.of(context).pop,
          ),
          trailing: NavigationButton(
            text: 'Create',
            textStyle: AppTheme.of(context).textTheme.navigationBoldButton,
            onPressed: _roomCreationPageCubit.submitNewRoom,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 5,
                          ),
                          MenuGroupHeader(title: 'Room name'),
                          PlatformDivider(),
                          CupertinoTextField(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            controller: _roomCreationPageCubit.roomNameTextEditingController,
                            textInputAction: TextInputAction.newline,
                            maxLines: 1,
                            maxLength: RoomNameInput.maxLength,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            cursorColor: AppTheme.of(context).primaryColor,
                            placeholder: 'Room Name',
                          ),
                          PlatformDivider(),
                          SizedBox(
                            height: 22,
                          ),
                          MenuGroupHeader(title: 'First message'),
                          PlatformDivider(),
                          CupertinoTextField(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            controller: _roomCreationPageCubit.messageTextEditingController,
                            textInputAction: TextInputAction.newline,
                            minLines: 1,
                            maxLines: 3,
                            maxLength: MessageInput.maxLength,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            cursorColor: AppTheme.of(context).primaryColor,
                            placeholder: 'Message',
                          ),
                          PlatformDivider(),
                          SizedBox(
                            height: 22,
                          ),
                        ],
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
    );
  }
}
