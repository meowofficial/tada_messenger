import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/rooms_sent_messages_container.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/room_creation_page/room_creation_page_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/models/message_input.dart';
import 'package:tada_messenger/presentation/models/room_name_input.dart';

import '../../../domain/predefined_entities.dart';
import '../predefined_bloc_states.dart';

class MockMessagesCubit extends MockCubit<MessagesState> implements MessagesCubit {}

class MockAuthenticationCubit extends MockCubit<AuthenticationState>
    implements AuthenticationCubit {}

class MockServerConnectionCubit extends MockCubit<ServerConnectionStatus>
    implements ServerConnectionCubit {}

void main() {
  late MessagesCubit messagesCubit;
  late AuthenticationCubit authenticationCubit;
  late ServerConnectionCubit serverConnectionCubit;

  const invalidRoomNameString = '';
  const validRoomNameString = 'test room';
  const invalidMessageString = '';
  const validMessageString = 'test message';

  setUp(() {
    registerFallbackValue<MessagesState>(defaultInitialMessagesState);
    registerFallbackValue<AuthenticationState>(defaultInitialAuthenticationState);
    registerFallbackValue<ServerConnectionStatus>(defaultInitialServerConnectionStatus);
    registerFallbackValue<Message>(Message(
      text: 'test text',
      sender: testUser,
      deliveryStatus: MessageDeliveryStatus.probablyDelivered,
      room: testRoom1,
      time: DateTime.now(),
    ));

    authenticationCubit = MockAuthenticationCubit();
    serverConnectionCubit = MockServerConnectionCubit();
    messagesCubit = MockMessagesCubit();

    whenListen(
      authenticationCubit,
      Stream<AuthenticationState>.empty(),
      initialState: defaultInitialAuthenticationState,
    );
    whenListen(
      serverConnectionCubit,
      Stream<ServerConnectionStatus>.empty(),
      initialState: defaultInitialServerConnectionStatus,
    );
    whenListen(
      messagesCubit,
      Stream<MessagesState>.empty(),
      initialState: defaultInitialMessagesState,
    );
  });

  group(
    'RoomCreationPageCubit',
    () {
      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits new state when messagesState changed',
        build: () {
          whenListen(
            messagesCubit,
            Stream.fromIterable([
              defaultInitialMessagesState.copyWith(
                probablyDeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
                  messagesMap: {},
                ),
              ),
            ]),
            initialState: defaultInitialMessagesState,
          );

          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        expect: () {
          return [
            RoomCreationPageState(
              createdRooms: {
                testRoom1,
                testRoom3,
              },
              messageInput: MessageInput(),
              roomNameInput: RoomNameInput(),
              submissionStatus: NewRoomNotSubmitted(),
            ),
          ];
        },
      );

      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits new state when roomNameTextEditingController changed',
        build: () {
          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        act: (roomCreationPageCubit) {
          roomCreationPageCubit.roomNameTextEditingController.text = 'a';
        },
        expect: () {
          return [
            RoomCreationPageState(
              createdRooms: {
                testRoom1,
                testRoom2,
                testRoom3,
              },
              messageInput: MessageInput(),
              roomNameInput: RoomNameInput('a'),
              submissionStatus: NewRoomNotSubmitted(),
            ),
          ];
        },
      );

      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits new state when messageTextEditingController changed',
        build: () {
          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        act: (roomCreationPageCubit) {
          roomCreationPageCubit.messageTextEditingController.text = 'a';
        },
        expect: () {
          return [
            RoomCreationPageState(
              createdRooms: {
                testRoom1,
                testRoom2,
                testRoom3,
              },
              messageInput: MessageInput('a'),
              roomNameInput: RoomNameInput(),
              submissionStatus: NewRoomNotSubmitted(),
            ),
          ];
        },
      );

      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits state with NewRoomSubmissionValidationFailure when room name is invalid',
        build: () {
          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        act: (roomCreationPageCubit) {
          roomCreationPageCubit.roomNameTextEditingController.text = invalidRoomNameString;
          roomCreationPageCubit.messageTextEditingController.text = validMessageString;
          roomCreationPageCubit.submitNewRoom();
        },
        verify: (roomCreationPageCubit) {
          expect(roomCreationPageCubit.state.submissionStatus,
              isA<NewRoomSubmissionValidationFailure>());
        },
      );

      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits state with NewRoomSubmissionValidationFailure when message is invalid',
        build: () {
          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        act: (roomCreationPageCubit) {
          roomCreationPageCubit.roomNameTextEditingController.text = validRoomNameString;
          roomCreationPageCubit.messageTextEditingController.text = invalidMessageString;
          roomCreationPageCubit.submitNewRoom();
        },
        verify: (roomCreationPageCubit) {
          expect(roomCreationPageCubit.state.submissionStatus,
              isA<NewRoomSubmissionValidationFailure>());
        },
      );

      blocTest<RoomCreationPageCubit, RoomCreationPageState>(
        'emits state with NewRoomSubmissionSuccess when room name and message are valid',
        build: () {
          return RoomCreationPageCubit(
            messagesCubit: messagesCubit,
            authenticationCubit: authenticationCubit,
            serverConnectionCubit: serverConnectionCubit,
          );
        },
        act: (roomCreationPageCubit) {
          roomCreationPageCubit.roomNameTextEditingController.text = validRoomNameString;
          roomCreationPageCubit.messageTextEditingController.text = validMessageString;
          roomCreationPageCubit.submitNewRoom();
        },
        verify: (roomCreationPageCubit) {
          verify(() {
            return messagesCubit.sendMessage(
              message: any(named: 'message'),
            );
          }).called(1);
          expect(roomCreationPageCubit.state.submissionStatus, isA<NewRoomSubmissionSuccess>());
        },
      );
    },
  );
}
