import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/injection_container.dart' as di;
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/room_page/room_page_cubit.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/widgets/navigation_bar_back_button.dart';
import 'package:tada_messenger/presentation/widgets/platform_keyboard_placeholder.dart';

class RoomPage extends StatefulWidget {
  static Route route({
    required Room room,
    required RouteSettings settings,
  }) {
    return CupertinoPageRoute<void>(
      settings: settings,
      builder: (context) {
        return RoomPage(
          room: room,
        );
      },
    );
  }

  RoomPage({
    required this.room,
  });

  final Room room;

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late RoomPageCubit _roomPageCubit;

  String _getTitle({
    required RoomPageState state,
  }) {
    if (state is RoomPageFoundState) {
      if (state.serverConnectionStatus != ServerConnectionStatus.connected) {
        return 'Connecting...';
      }
      if (state.outdatableReversedMessageHistory.dataStatus == OutdatableDataStatus.updating) {
        return 'Updating...';
      }
    } else if (state is RoomPageUnknownState) {
      if (state.serverConnectionStatus != ServerConnectionStatus.connected) {
        return 'Connecting...';
      }
      if (state.status == RoomPageUnknownStatus.checking) {
        return 'Updating...';
      }
    }

    return _roomPageCubit.room.name;
  }

  Widget _buildContent({
    required RoomPageState state,
  }) {
    if (state is RoomPageUnknownState) {
      return _buildUnknownStateContent();
    }
    if (state is RoomPageNotFoundState) {
      return _buildNotFoundStateContent();
    }
    if (state is RoomPageFoundState) {
      return _buildFoundStateContent(state: state);
    }
    return Container();
  }

  Widget _buildUnknownStateContent() {
    return Container();
  }

  Widget _buildNotFoundStateContent() {
    return Center(
      child: Text('Room not found'),
    );
  }

  Widget _buildFoundStateContent({
    required RoomPageFoundState state,
  }) {
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              reverse: true,
              itemCount: state.outdatableReversedMessageHistory.messages.length,
              itemBuilder: (context, index) {
                final message = state.outdatableReversedMessageHistory.messages[index];
                return _MessageBubble(
                  text: message.text,
                  time: message.time,
                  deliveryStatus: message.deliveryStatus,
                  username: message.sender.username,
                  isUserMessage: message.sender == di.sl<AuthenticationCubit>().state.user,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 16,
                );
              },
            ),
          ),
        ),
        _MessagePane(),
        PlatformKeyboardPlaceholder(
          backgroundColor: Colors.grey[100]!,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _roomPageCubit = RoomPageCubit(
      room: widget.room,
      messagesCubit: di.sl(),
      serverConnectionCubit: di.sl(),
      authenticationCubit: di.sl(),
    );
    _roomPageCubit.updateMessageHistoryIfPossible();
  }

  @override
  void dispose() {
    _roomPageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _roomPageCubit,
      child: BlocBuilder<RoomPageCubit, RoomPageState>(
        bloc: _roomPageCubit,
        builder: (context, state) {
          return CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.lightBlue[50],
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.grey[100],
              padding: EdgeInsetsDirectional.zero,
              middle: Text(
                _getTitle(state: state),
                style: AppTheme.of(context).textTheme.title,
                overflow: TextOverflow.ellipsis,
              ),
              leading: NavigationBarBackButton(
                onPressed: Navigator.of(context).pop,
              ),
            ),
            child: _buildContent(state: state),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.username,
    required this.isUserMessage,
    required this.deliveryStatus,
    Key? key,
  }) : super(key: key);

  final String text;
  final DateTime time;
  final String username;
  final bool isUserMessage;
  final MessageDeliveryStatus deliveryStatus;

  @override
  Widget build(BuildContext context) {
    return Bubble(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.66,
            ),
            child: Column(
              crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUserMessage)
                  Text(
                    username,
                    style: AppTheme.of(context).textTheme.defaultText.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  text,
                  style: isUserMessage
                      ? AppTheme.of(context).textTheme.defaultText.copyWith(
                            color: Colors.white,
                          )
                      : AppTheme.of(context).textTheme.defaultText,
                  softWrap: true,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          if (deliveryStatus == MessageDeliveryStatus.undelivered)
            SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: SizedBox(
                  height: 8,
                  width: 8,
                  child: CircularProgressIndicator(
                    backgroundColor:
                        isUserMessage ? AppTheme.of(context).primaryColor : Colors.white,
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isUserMessage ? Colors.grey[350]! : Colors.grey),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: 33,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(time.toLocal()),
                  style: AppTheme.of(context).textTheme.defaultText.copyWith(
                        fontSize: 11,
                        color: isUserMessage ? Colors.grey[350] : Colors.grey,
                      ),
                ),
              ),
            ),
        ],
      ),
      nip: isUserMessage ? BubbleNip.rightBottom : BubbleNip.leftBottom,
      alignment: isUserMessage ? Alignment.topRight : Alignment.topLeft,
      margin: BubbleEdges.only(
        left: isUserMessage ? 0 : 12,
        right: isUserMessage ? 12 : 0,
      ),
      padding: BubbleEdges.fromLTRB(12, 10, 12, 10),
      radius: Radius.circular(16),
      color: isUserMessage ? AppTheme.of(context).primaryColor : Colors.white,
    );
  }
}

class _MessagePane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: SafeArea(
        bottom: true,
        left: false,
        right: false,
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 50,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: CupertinoTextField(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  controller: context.read<RoomPageCubit>().messageTextEditingController,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 10500,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  cursorColor: AppTheme.of(context).primaryColor,
                  placeholder: 'Message',
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppTheme.of(context).primaryColor,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: context.read<RoomPageCubit>().sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
