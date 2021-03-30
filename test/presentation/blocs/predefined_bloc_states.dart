import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/outdatable_rooms_with_last_messages.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';
import 'package:tada_messenger/domain/entities/rooms_outdatable_message_history.dart';
import 'package:tada_messenger/domain/entities/rooms_sent_messages_container.dart';
import 'package:tada_messenger/domain/entities/sent_message_info.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';

import '../../domain/predefined_entities.dart';

final defaultRoomsWithLastMessages = [
  RoomWithLastMessage(
    room: testRoom1,
    lastMessage: Message(
      text: 'test text',
      sender: testUser,
      deliveryStatus: MessageDeliveryStatus.delivered,
      room: testRoom1,
      time: DateTime.now(),
    ),
  ),
  RoomWithLastMessage(
    room: testRoom2,
    lastMessage: Message(
      text: 'test text',
      sender: testUser,
      deliveryStatus: MessageDeliveryStatus.delivered,
      room: testRoom2,
      time: DateTime.now(),
    ),
  ),
];

final defaultInitialMessagesState = MessagesState(
  outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
    roomsWithLastMessages: [
      RoomWithLastMessage(
        room: testRoom1,
        lastMessage: Message(
          text: 'test text',
          sender: testUser,
          deliveryStatus: MessageDeliveryStatus.delivered,
          room: testRoom1,
          time: DateTime.now(),
        ),
      ),
    ],
    dataStatus: OutdatableDataStatus.outdated,
    lastUpdateRequestTime: null,
  ),
  roomsOutdatableMessageHistory: RoomsOutdatableMessageHistory.fromMap(
    roomsOutdatableMessageHistoryMap: {},
  ),
  probablyDeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
    messagesMap: {
      testRoom2: [
        SentMessageInfo(
          message: Message(
            text: 'test text',
            sender: testUser,
            deliveryStatus: MessageDeliveryStatus.probablyDelivered,
            room: testRoom2,
            time: DateTime.now(),
          ),
          lastSendingTime: DateTime.now(),
        ),
      ],
    },
  ),
  undeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
    messagesMap: {
      testRoom3: [
        SentMessageInfo(
          message: Message(
            text: 'test text',
            sender: testUser,
            deliveryStatus: MessageDeliveryStatus.undelivered,
            room: testRoom3,
            time: DateTime.now(),
          ),
          lastSendingTime: DateTime.now(),
        ),
      ],
    },
  ),
  notFoundRooms: {},
  beingFoundRooms: {},
);

final defaultInitialAuthenticationState = AuthenticationState.authenticated(user: testUser);
const defaultInitialServerConnectionStatus = ServerConnectionStatus.connected;
