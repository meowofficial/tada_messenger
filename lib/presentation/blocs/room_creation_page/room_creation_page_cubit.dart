import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/models/message_input.dart';
import 'package:tada_messenger/presentation/models/room_name_input.dart';
import 'package:tada_messenger/presentation/models/validation_error.dart';
import 'package:tada_messenger/util/uuid.dart';

part 'room_creation_page_state.dart';

class RoomCreationPageCubit extends Cubit<RoomCreationPageState> {
  RoomCreationPageCubit({
    required MessagesCubit messagesCubit,
    required AuthenticationCubit authenticationCubit,
    required ServerConnectionCubit serverConnectionCubit,
  })   : _messagesCubit = messagesCubit,
        _authenticationCubit = authenticationCubit,
        _serverConnectionCubit = serverConnectionCubit,
        super(_getInitialState(
          messagesState: messagesCubit.state,
        )) {
    roomNameTextEditingController = TextEditingController();
    messageTextEditingController = TextEditingController();
    roomNameTextEditingController.addListener(_onRoomNameChanged);
    messageTextEditingController.addListener(_onMessageChanged);
    _messagesCubitSubscription = _messagesCubit.stream.listen(_onMessagesStateChanged);
  }

  final MessagesCubit _messagesCubit;
  final AuthenticationCubit _authenticationCubit;
  final ServerConnectionCubit _serverConnectionCubit;
  late TextEditingController roomNameTextEditingController;
  late TextEditingController messageTextEditingController;
  late StreamSubscription<MessagesState> _messagesCubitSubscription;

  static RoomCreationPageState _getInitialState({
    required MessagesState messagesState,
  }) {
    return RoomCreationPageState(
      createdRooms: _getCreatedRooms(
        messagesState: messagesState,
      ),
      roomNameInput: RoomNameInput(),
      messageInput: MessageInput(),
      submissionStatus: NewRoomNotSubmitted(),
    );
  }

  static Set<Room> _getCreatedRooms({
    required MessagesState messagesState,
  }) {
    final existingRooms = messagesState.outdatableRoomsWithLastMessages.roomsWithLastMessages
        .map((roomWithLastMessage) {
      return roomWithLastMessage.room;
    }).toSet();

    return {
      ...existingRooms,
      ...messagesState.probablyDeliveredMessagesContainer.rooms,
      ...messagesState.undeliveredMessagesContainer.rooms,
    };
  }

  void _onMessagesStateChanged(MessagesState messagesState) {
    emit(state.copyWith(
      createdRooms: _getCreatedRooms(
        messagesState: messagesState,
      ),
      submissionStatus: NewRoomNotSubmitted(),
    ));
  }

  void _onRoomNameChanged() {
    emit(state.copyWith(
      roomNameInput: RoomNameInput(roomNameTextEditingController.text),
      submissionStatus: NewRoomNotSubmitted(),
    ));
  }

  void _onMessageChanged() {
    emit(state.copyWith(
      messageInput: MessageInput(messageTextEditingController.text),
      submissionStatus: NewRoomNotSubmitted(),
    ));
  }

  void submitNewRoom() {
    roomNameTextEditingController.text = roomNameTextEditingController.text.trim();
    messageTextEditingController.text = messageTextEditingController.text.trim();

    final roomNameValidationError = state.roomNameInput.validator();
    if (roomNameValidationError != null) {
      emit(state.copyWith(
        submissionStatus: NewRoomSubmissionValidationFailure(
          validationError: roomNameValidationError,
          submissionTime: DateTime.now().toUtc(),
        ),
      ));
      return;
    }

    final messageValidationError = state.messageInput.validator();
    if (messageValidationError != null) {
      emit(state.copyWith(
        submissionStatus: NewRoomSubmissionValidationFailure(
          validationError: messageValidationError,
          submissionTime: DateTime.now().toUtc(),
        ),
      ));
      return;
    }

    final room = Room(
      name: state.roomNameInput.value,
    );

    if (state.createdRooms.contains(room)) {
      emit(state.copyWith(
        submissionStatus: NewRoomSubmissionExistenceFailure(
          submissionTime: DateTime.now().toUtc(),
        ),
      ));
      return;
    }

    final message = Message(
      id: UUID.generate(),
      text: state.messageInput.value,
      sender: _authenticationCubit.state.user!,
      room: room,
      deliveryStatus: _serverConnectionCubit.state == ServerConnectionStatus.connected
          ? MessageDeliveryStatus.probablyDelivered
          : MessageDeliveryStatus.undelivered,
      time: DateTime.now().toUtc(),
    );

    _messagesCubit.sendMessage(message: message);

    emit(state.copyWith(
      submissionStatus: NewRoomSubmissionSuccess(),
    ));
  }

  @override
  Future<void> close() {
    _messagesCubitSubscription.cancel();
    roomNameTextEditingController.dispose();
    messageTextEditingController.dispose();
    return super.close();
  }
}
