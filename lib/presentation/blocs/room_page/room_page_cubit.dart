import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/room_outdatable_message_history.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/models/message_input.dart';
import 'package:tada_messenger/util/uuid.dart';

part 'room_page_state.dart';

class RoomPageCubit extends Cubit<RoomPageState> {
  RoomPageCubit({
    required this.room,
    required MessagesCubit messagesCubit,
    required ServerConnectionCubit serverConnectionCubit,
    required AuthenticationCubit authenticationCubit,
  })   : _messagesCubit = messagesCubit,
        _serverConnectionCubit = serverConnectionCubit,
        _authenticationCubit = authenticationCubit,
        super(_getInitialState(
          room: room,
          messagesState: messagesCubit.state,
          serverConnectionStatus: serverConnectionCubit.state,
        )) {
    _messagesCubitSubscription = _messagesCubit.stream.listen(_onMessagesStateChanged);
    _serverConnectionStatusSubscription =
        _serverConnectionCubit.stream.listen(_onServerConnectionStatusChanged);
    messageTextEditingController = TextEditingController();
    messageTextEditingController.addListener(_onMessageTextEditingControllerChanged);
  }

  final Room room;
  final MessagesCubit _messagesCubit;
  final ServerConnectionCubit _serverConnectionCubit;
  final AuthenticationCubit _authenticationCubit;
  late StreamSubscription<MessagesState> _messagesCubitSubscription;
  late StreamSubscription<ServerConnectionStatus> _serverConnectionStatusSubscription;
  late TextEditingController messageTextEditingController;

  static RoomPageState _getInitialState({
    required Room room,
    required MessagesState messagesState,
    required ServerConnectionStatus serverConnectionStatus,
  }) {
    if (messagesState.roomsOutdatableMessageHistory.isRoomMessageHistoryPresent(room)) {
      return _getRoomPageFoundState(
        room: room,
        messagesState: messagesState,
        serverConnectionStatus: serverConnectionStatus,
        messageInputString: '',
      );
    } else {
      return RoomPageUnknownState(
        status: messagesState.beingFoundRooms.contains(room)
            ? RoomPageUnknownStatus.checking
            : RoomPageUnknownStatus.none,
        serverConnectionStatus: serverConnectionStatus,
      );
    }
  }

  static RoomPageFoundState _getRoomPageFoundState({
    required Room room,
    required MessagesState messagesState,
    required ServerConnectionStatus serverConnectionStatus,
    required String messageInputString,
  }) {
    final outdatableRoomMessageHistory =
        messagesState.roomsOutdatableMessageHistory.getRoomOutdatableMessageHistory(room);
    final messages = [
      ...outdatableRoomMessageHistory.messages,
      ...messagesState.probablyDeliveredMessagesContainer
          .getRoomSentMessageInfos(room)
          .map((sentMessageInfo) {
        return sentMessageInfo.message;
      }),
      ...messagesState.undeliveredMessagesContainer
          .getRoomSentMessageInfos(room)
          .map((sentMessageInfo) {
        return sentMessageInfo.message;
      }),
    ];
    // could be more efficient
    messages.sort((first, second) => first.time.compareTo(second.time));
    final reversedMessages = messages.reversed.toList();
    return RoomPageFoundState(
      outdatableReversedMessageHistory: outdatableRoomMessageHistory.copyWith(
        messages: reversedMessages,
      ),
      serverConnectionStatus: serverConnectionStatus,
      messageInput: MessageInput(messageInputString),
    );
  }

  void _onMessageTextEditingControllerChanged() {
    if (state is RoomPageFoundState) {
      emit((state as RoomPageFoundState).copyWith(
        messageInput: MessageInput(messageTextEditingController.text),
      ));
    }
  }

  void _onMessagesStateChanged(MessagesState messagesState) {
    if (messagesState.roomsOutdatableMessageHistory.isRoomMessageHistoryPresent(room)) {
      emit(_getRoomPageFoundState(
        room: room,
        messagesState: messagesState,
        serverConnectionStatus: _serverConnectionCubit.state,
        messageInputString: messageTextEditingController.text,
      ));
    } else if (messagesState.notFoundRooms.contains(room)) {
      emit(RoomPageNotFoundState());
    } else {
      emit(RoomPageUnknownState(
        status: messagesState.beingFoundRooms.contains(room)
            ? RoomPageUnknownStatus.checking
            : RoomPageUnknownStatus.none,
        serverConnectionStatus: _serverConnectionCubit.state,
      ));
    }
  }

  void _onServerConnectionStatusChanged(ServerConnectionStatus serverConnectionStatus) {
    if (serverConnectionStatus == ServerConnectionStatus.connected) {
      _messagesCubit.updateRoomMessageHistoryIfPossible(room);
    }
    if (state is RoomPageFoundState) {
      emit((state as RoomPageFoundState).copyWith(
        serverConnectionStatus: serverConnectionStatus,
      ));
    }
  }

  void updateMessageHistoryIfPossible() async {
    _messagesCubit.updateRoomMessageHistoryIfPossible(room);
  }

  void sendMessage() async {
    if (state is RoomPageFoundState) {
      final messageInput = (state as RoomPageFoundState).messageInput;
      final messageValidationError = messageInput.validator();
      if (messageValidationError == null) {
        final message = Message(
          text: messageInput.value,
          room: room,
          sender: _authenticationCubit.state.user!,
          deliveryStatus: _serverConnectionCubit.state == ServerConnectionStatus.connected
              ? MessageDeliveryStatus.probablyDelivered
              : MessageDeliveryStatus.undelivered,
          time: DateTime.now().toUtc(),
          id: UUID.generate(),
        );
        _messagesCubit.sendMessage(
          message: message,
        );
        messageTextEditingController.clear();
      }
    }
  }

  @override
  Future<void> close() {
    _messagesCubitSubscription.cancel();
    _serverConnectionStatusSubscription.cancel();
    messageTextEditingController.dispose();
    return super.close();
  }
}
