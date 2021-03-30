import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tada_messenger/app_route_generator.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/injection_container.dart' as di;
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/rooms_page/rooms_page_cubit.dart';
import 'package:tada_messenger/presentation/pages/room_creation_page.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/widgets/platform_divider.dart';

class RoomsPage extends StatefulWidget {
  static Route route({
    required RouteSettings settings,
  }) {
    return MaterialWithModalsPageRoute<void>(
      settings: settings,
      builder: (context) {
        return RoomsPage();
      },
    );
  }

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late RoomsPageCubit _roomsPageCubit;

  String _getTitle({
    required RoomsPageState state,
  }) {
    if (state.serverConnectionStatus != ServerConnectionStatus.connected) {
      return 'Connecting...';
    }
    if (state.outdatableRoomsWithLastMessages.dataStatus == OutdatableDataStatus.updating) {
      return 'Updating...';
    }
    return 'Rooms';
  }

  @override
  void initState() {
    super.initState();
    _roomsPageCubit = RoomsPageCubit(
      messagesCubit: di.sl(),
      serverConnectionCubit: di.sl(),
    );
    _roomsPageCubit.updateRoomsWithLastMessagesIfPossible();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsPageCubit, RoomsPageState>(
      bloc: _roomsPageCubit,
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            padding: EdgeInsetsDirectional.zero,
            backgroundColor: Colors.grey[100],
            middle: Text(
              _getTitle(state: state),
              style: AppTheme.of(context).textTheme.title,
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: SizedBox(
                height: double.infinity,
                width: 56,
                child: Icon(
                  Icons.logout,
                  color: AppTheme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                di.sl<AuthenticationCubit>().requestAuthenticationLogout();
              },
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: SizedBox(
                height: double.infinity,
                width: 56,
                child: Icon(
                  CupertinoIcons.add,
                  size: 28,
                  color: AppTheme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                showCupertinoModalBottomSheet<bool>(
                  expand: true,
                  useRootNavigator: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return RoomCreationPage();
                  },
                );
              },
            ),
          ),
          child: ListView.separated(
            itemCount: state.outdatableRoomsWithLastMessages.roomsWithLastMessages.length,
            itemBuilder: (context, index) {
              final roomWithLastMessage =
                  state.outdatableRoomsWithLastMessages.roomsWithLastMessages[index];

              Widget item = _RoomTile(
                name: roomWithLastMessage.room.name,
                timeLabel:
                    _roomsPageCubit.getTimeLabel(roomWithLastMessage.lastMessage.time.toLocal()),
                lastMessage: roomWithLastMessage.lastMessage.text,
                lastMessageSenderLabel: roomWithLastMessage.lastMessage.sender.username,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.room,
                    arguments: {
                      AppRouteGenerator.roomArgument: roomWithLastMessage.room,
                    },
                  );
                },
              );

              if (index == state.outdatableRoomsWithLastMessages.roomsWithLastMessages.length - 1) {
                item = SafeArea(
                  child: item,
                );
              }
              return item;
            },
            separatorBuilder: (context, index) {
              return PlatformDivider();
            },
          ),
        );
      },
    );
  }
}

class _RoomTile extends StatefulWidget {
  const _RoomTile({
    required this.name,
    required this.lastMessage,
    required this.lastMessageSenderLabel,
    required this.timeLabel,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String name;
  final String lastMessage;
  final String lastMessageSenderLabel;
  final String timeLabel;
  final VoidCallback onPressed;

  @override
  _RoomTileState createState() => _RoomTileState();
}

class _RoomTileState extends State<_RoomTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (tapDownDetails) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTap: () {
        widget.onPressed();
        Future.delayed(Duration(milliseconds: 150), () {
          _pressed = false;
          if (mounted) {
            setState(() {});
          }
        });
      },
      child: Container(
        color: _pressed ? AppTheme.of(context).pressedTileColor : AppTheme.of(context).tileColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      style: AppTheme.of(context).textTheme.defaultBoldText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    widget.timeLabel,
                    style: AppTheme.of(context).textTheme.defaultText.copyWith(
                          fontSize: 15.5,
                          color: Colors.grey[500],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.lastMessageSenderLabel}: ',
                      style: AppTheme.of(context).textTheme.defaultText.copyWith(
                            fontSize: 14.5,
                            color: Colors.grey[500],
                          ),
                    ),
                    TextSpan(
                      text: widget.lastMessage,
                      style: AppTheme.of(context).textTheme.defaultText.copyWith(
                            fontSize: 14.5,
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
