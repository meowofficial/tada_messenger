import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tada_messenger/domain/entities/outdatable_rooms_with_last_messages.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';

part 'rooms_page_state.dart';

class RoomsPageCubit extends Cubit<RoomsPageState> {
  RoomsPageCubit({
    required MessagesCubit messagesCubit,
    required ServerConnectionCubit serverConnectionCubit,
  })  : _messagesCubit = messagesCubit,
        _serverConnectionCubit = serverConnectionCubit,
        super(RoomsPageState(
          outdatableRoomsWithLastMessages: messagesCubit.state.outdatableRoomsWithLastMessages,
          serverConnectionStatus: serverConnectionCubit.state,
        )) {
    _messagesCubitSubscription = _messagesCubit.stream.listen(_onMessagesStateChanged);
    _serverConnectionStatusSubscription =
        _serverConnectionCubit.stream.listen(_onServerConnectionStatusChanged);
  }

  final MessagesCubit _messagesCubit;
  final ServerConnectionCubit _serverConnectionCubit;
  late StreamSubscription<MessagesState> _messagesCubitSubscription;
  late StreamSubscription<ServerConnectionStatus> _serverConnectionStatusSubscription;

  String getTimeLabel(DateTime time) {
    return DateFormat('HH:mm dd.MM.yyyy').format(time);
  }

  void _onMessagesStateChanged(MessagesState messagesState) {
    emit(state.copyWith(
      outdatableRoomsWithLastMessages: messagesState.outdatableRoomsWithLastMessages,
    ));
  }

  void _onServerConnectionStatusChanged(ServerConnectionStatus serverConnectionStatus) {
    if (serverConnectionStatus == ServerConnectionStatus.connected) {
      updateRoomsWithLastMessagesIfPossible();
    }
    emit(state.copyWith(
      serverConnectionStatus: serverConnectionStatus,
    ));
  }

  void updateRoomsWithLastMessagesIfPossible() {
    _messagesCubit.updateRoomsWithLastMessagesIfPossible();
  }

  @override
  Future<void> close() {
    _messagesCubitSubscription.cancel();
    _serverConnectionStatusSubscription.cancel();
    return super.close();
  }
}
