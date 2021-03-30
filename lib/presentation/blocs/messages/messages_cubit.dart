import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/outdatable_rooms_with_last_messages.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/room_outdatable_message_history.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';
import 'package:tada_messenger/domain/entities/rooms_outdatable_message_history.dart';
import 'package:tada_messenger/domain/entities/rooms_sent_messages_container.dart';
import 'package:tada_messenger/domain/entities/sent_message_info.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/domain/repositories/messages_repository.dart';
import 'package:tada_messenger/error/failures.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/helpers/date_time_helper.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required MessagesRepository messagesRepository,
    required ServerConnectionCubit serverConnectionCubit,
    required DateTimeHelper dateTimeHelper,
  })   : _messagesRepository = messagesRepository,
        _serverConnectionCubit = serverConnectionCubit,
        _dateTimeHelper = dateTimeHelper,
        super(MessagesState(
          outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
            roomsWithLastMessages: [],
            dataStatus: OutdatableDataStatus.outdated,
            lastUpdateRequestTime: null,
          ),
          roomsOutdatableMessageHistory: RoomsOutdatableMessageHistory.fromMap(
            roomsOutdatableMessageHistoryMap: {},
          ),
          probablyDeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
            messagesMap: {},
          ),
          undeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
            messagesMap: {},
          ),
          notFoundRooms: {},
          beingFoundRooms: {},
        )) {
    _messagesSubscription = _messagesRepository.messages.listen(_onMessageReceived);
    _serverConnectionStatusSubscription =
        _serverConnectionCubit.stream.listen(_onServerConnectionChanged);
    _stateSubscription = stream.listen((_) => _onStateChanged());
  }

  final MessagesRepository _messagesRepository;
  final ServerConnectionCubit _serverConnectionCubit;
  final DateTimeHelper _dateTimeHelper;

  late StreamSubscription<Message> _messagesSubscription;
  late StreamSubscription<ServerConnectionStatus> _serverConnectionStatusSubscription;
  late StreamSubscription<MessagesState> _stateSubscription;

  void updateRoomsWithLastMessagesIfPossible() async {
    if (state.outdatableRoomsWithLastMessages.dataStatus != OutdatableDataStatus.outdated ||
        _serverConnectionCubit.state != ServerConnectionStatus.connected) {
      return;
    }

    emit(state.copyWith(
      outdatableRoomsWithLastMessages: state.outdatableRoomsWithLastMessages.copyWith(
        dataStatus: OutdatableDataStatus.updating,
      ),
    ));

    final updateRequestTime = _dateTimeHelper.getCurrentUtcDateTime();
    final roomsWithLastMessagesOrFailure = await _messagesRepository.getRoomsWithLastMessages();

    roomsWithLastMessagesOrFailure.fold(
      (failure) {
        emit(state.copyWith(
          outdatableRoomsWithLastMessages: state.outdatableRoomsWithLastMessages.copyWith(
            dataStatus: OutdatableDataStatus.outdated,
          ),
        ));
      },
      (roomsWithLastMessages) {
        roomsWithLastMessages.sort((first, second) {
          return second.lastMessage.time.compareTo(first.lastMessage.time);
        });
        emit(state.copyWith(
          outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
            roomsWithLastMessages: roomsWithLastMessages,
            dataStatus: OutdatableDataStatus.updated,
            lastUpdateRequestTime: updateRequestTime,
          ),
        ));
      },
    );
  }

  void updateRoomMessageHistoryIfPossible(Room room) async {
    if (state.roomsOutdatableMessageHistory.getRoomOutdatableMessageHistory(room).dataStatus !=
            OutdatableDataStatus.outdated ||
        _serverConnectionCubit.state != ServerConnectionStatus.connected) {
      return;
    }

    if (state.roomsOutdatableMessageHistory.isRoomMessageHistoryPresent(room)) {
      emit(state.copyWith(
        roomsOutdatableMessageHistory:
            state.roomsOutdatableMessageHistory.copyWithRoomOutdatableMessageHistory(
          room: room,
          roomOutdatableMessageHistory:
              state.roomsOutdatableMessageHistory.getRoomOutdatableMessageHistory(room).copyWith(
                    dataStatus: OutdatableDataStatus.updating,
                  ),
        ),
      ));
    } else {
      emit(state.copyWith(
        notFoundRooms: {...state.notFoundRooms}..remove(room),
        beingFoundRooms: {...state.beingFoundRooms}..add(room),
      ));
    }

    final updateRequestTime = _dateTimeHelper.getCurrentUtcDateTime();
    final messagesOrFailure = await _messagesRepository.getRoomMessageHistory(room);
    messagesOrFailure.fold(
      (failure) {
        if (failure is RoomNotFoundFailure) {
          emit(state.copyWith(
            notFoundRooms: {...state.notFoundRooms}..add(room),
            beingFoundRooms: {...state.beingFoundRooms}..remove(room),
          ));
        } else if (failure is ServerFailure) {
          emit(state.copyWith(
            beingFoundRooms: {...state.beingFoundRooms}..remove(room),
          ));
        }
      },
      (messages) {
        final outdatableRoomMessageHistory = RoomOutdatableMessageHistory(
          messages: messages,
          dataStatus: OutdatableDataStatus.updated,
          lastUpdateRequestTime: updateRequestTime,
        );

        var probablyDeliveredMessagesContainer = state.probablyDeliveredMessagesContainer;
        final roomProbablyDeliveredMessageInfos = [
          ...probablyDeliveredMessagesContainer.getRoomSentMessageInfos(room)
        ];

        if (roomProbablyDeliveredMessageInfos.isNotEmpty) {
          final messageIds = messages.where((message) {
            return message.id != null;
          }).map((message) {
            return message.id;
          }).toSet();

          roomProbablyDeliveredMessageInfos.removeWhere((sentMessageInfo) {
            return messageIds.contains(sentMessageInfo.message.id);
          });

          probablyDeliveredMessagesContainer =
              probablyDeliveredMessagesContainer.copyWithRoomSentMessageInfos(
            room: room,
            sentMessageInfos: roomProbablyDeliveredMessageInfos,
          );
        }

        emit(state.copyWith(
          roomsOutdatableMessageHistory:
              state.roomsOutdatableMessageHistory.copyWithRoomOutdatableMessageHistory(
            room: room,
            roomOutdatableMessageHistory: outdatableRoomMessageHistory,
          ),
          probablyDeliveredMessagesContainer: probablyDeliveredMessagesContainer,
          notFoundRooms: {...state.notFoundRooms}..remove(room),
          beingFoundRooms: {...state.beingFoundRooms}..remove(room),
        ));
      },
    );
  }

  void _onStateChanged() {
    if (_serverConnectionCubit.state == ServerConnectionStatus.connected) {
      final oldProbablyDeliveredMessagesContainer = state.probablyDeliveredMessagesContainer;
      final oldUndeliveredMessagesContainer = state.undeliveredMessagesContainer;
      final outdatableRoomsWithLastMessages = state.outdatableRoomsWithLastMessages;
      final existingRooms =
          outdatableRoomsWithLastMessages.roomsWithLastMessages.map((roomWithLastMessage) {
        return roomWithLastMessage.room;
      }).toSet();
      Set<Room> rooms = {
        ...oldProbablyDeliveredMessagesContainer.rooms,
        ...oldUndeliveredMessagesContainer.rooms,
      };
      Map<Room, List<SentMessageInfo>> newProbablyDeliveredMessagesMap = {
        ...state.probablyDeliveredMessagesContainer.getAllSentMessageInfosAsMap(),
      };
      Map<Room, List<SentMessageInfo>> newUndeliveredMessagesMap = {
        ...state.undeliveredMessagesContainer.getAllSentMessageInfosAsMap(),
      };
      for (var room in rooms) {
        final roomOutdatableMessageHistory =
            state.roomsOutdatableMessageHistory.getRoomOutdatableMessageHistory(room);
        final roomLastUpdateRequestTime = roomOutdatableMessageHistory.lastUpdateRequestTime;
        final roomsWithLastMessagesLastUpdateRequestTime =
            outdatableRoomsWithLastMessages.lastUpdateRequestTime;
        final roomExists = existingRooms.contains(room);
        if (roomExists && roomOutdatableMessageHistory.dataStatus == OutdatableDataStatus.updated ||
            !roomExists &&
                outdatableRoomsWithLastMessages.dataStatus == OutdatableDataStatus.updated) {
          final roomOldProbablyDeliveredSentMessageInfos =
              oldProbablyDeliveredMessagesContainer.getRoomSentMessageInfos(room);

          var roomUndeliveredSentMessageInfos = [
            ...oldUndeliveredMessagesContainer.getRoomSentMessageInfos(room),
          ];
          for (var sentMessageInfo in roomOldProbablyDeliveredSentMessageInfos) {
            final lastUpdateRequestTime =
                roomExists ? roomLastUpdateRequestTime : roomsWithLastMessagesLastUpdateRequestTime;
            if (sentMessageInfo.lastSendingTime.compareTo(lastUpdateRequestTime!) == -1) {
              roomUndeliveredSentMessageInfos.add(sentMessageInfo);
            }
          }
          final currentTime = _dateTimeHelper.getCurrentUtcDateTime();
          roomUndeliveredSentMessageInfos = roomUndeliveredSentMessageInfos.map((sentMessageInfo) {
            return sentMessageInfo.copyWith(
              lastSendingTime: currentTime,
            );
          }).toList();
          // could be more efficient
          roomUndeliveredSentMessageInfos.sort((first, second) {
            return first.message.time.compareTo(second.message.time);
          });
          for (var sentMessageInfo in roomUndeliveredSentMessageInfos) {
            _messagesRepository.sendMessage(sentMessageInfo.message);
          }
          final roomNewProbablyDeliveredSentMessageInfos = [
            ...roomUndeliveredSentMessageInfos.map((sentMessageInfo) {
              return sentMessageInfo.copyWith(
                message: sentMessageInfo.message.copyWith(
                  deliveryStatus: MessageDeliveryStatus.probablyDelivered,
                ),
              );
            }),
            ...roomOldProbablyDeliveredSentMessageInfos,
          ];
          // could be more efficient
          roomNewProbablyDeliveredSentMessageInfos.sort((first, second) {
            return first.message.time.compareTo(second.message.time);
          });
          newProbablyDeliveredMessagesMap[room] = roomNewProbablyDeliveredSentMessageInfos;
          newUndeliveredMessagesMap[room] = [];
        }
      }
      emit(state.copyWith(
        probablyDeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
          messagesMap: newProbablyDeliveredMessagesMap,
        ),
        undeliveredMessagesContainer: RoomsSentMessagesContainer.fromMap(
          messagesMap: newUndeliveredMessagesMap,
        ),
      ));
    }
  }

  void _onServerConnectionChanged(ServerConnectionStatus serverConnectionStatus) {
    if (serverConnectionStatus == ServerConnectionStatus.disconnected) {
      final outdatableRoomsWithLastMessages = state.outdatableRoomsWithLastMessages.copyWith(
        dataStatus: OutdatableDataStatus.outdated,
      );
      final roomsOutdatableMessageHistory =
          state.roomsOutdatableMessageHistory.copyWithOutdatedRoomsMessageHistory();

      emit(state.copyWith(
        roomsOutdatableMessageHistory: roomsOutdatableMessageHistory,
        outdatableRoomsWithLastMessages: outdatableRoomsWithLastMessages,
      ));
    }
  }

  void _onMessageReceived(Message message) {
    var newState = state;

    var roomOutdatableMessageHistory =
        state.roomsOutdatableMessageHistory.getRoomOutdatableMessageHistory(message.room);

    newState = newState.copyWith(
      probablyDeliveredMessagesContainer:
          newState.probablyDeliveredMessagesContainer.copyWithRoomSentMessageInfos(
        room: message.room,
        sentMessageInfos: [
          ...newState.probablyDeliveredMessagesContainer.getRoomSentMessageInfos(message.room)
        ]..removeWhere((sentMessageInfo) {
            return sentMessageInfo.message.id == message.id;
          }),
      ),
    );

    final existingRooms =
        state.outdatableRoomsWithLastMessages.roomsWithLastMessages.map((roomWithLastMessage) {
      return roomWithLastMessage.room;
    }).toSet();

    final roomExists = existingRooms.contains(message.room);

    if (roomExists && roomOutdatableMessageHistory.dataStatus == OutdatableDataStatus.updated) {
      roomOutdatableMessageHistory = roomOutdatableMessageHistory.copyWith(
        messages: [...roomOutdatableMessageHistory.messages]..add(message),
      );

      newState = newState.copyWith(
        roomsOutdatableMessageHistory:
            newState.roomsOutdatableMessageHistory.copyWithRoomOutdatableMessageHistory(
          room: message.room,
          roomOutdatableMessageHistory: roomOutdatableMessageHistory,
        ),
      );
    }

    final outdatableRoomsWithLastMessages = newState.outdatableRoomsWithLastMessages;
    if (outdatableRoomsWithLastMessages.dataStatus == OutdatableDataStatus.updated) {
      final roomsWithLastMessages = [
        ...outdatableRoomsWithLastMessages.roomsWithLastMessages,
      ];
      final updatedRoomWithLastMessage = RoomWithLastMessage(
        lastMessage: message,
        room: message.room,
      );

      if (roomExists) {
        final index = roomsWithLastMessages.indexWhere((roomWithLastMessage) {
          return roomWithLastMessage.room == message.room;
        });
        roomsWithLastMessages[index] = updatedRoomWithLastMessage;
      } else {
        roomsWithLastMessages.insert(0, updatedRoomWithLastMessage);
      }

      newState = newState.copyWith(
        outdatableRoomsWithLastMessages: outdatableRoomsWithLastMessages.copyWith(
          roomsWithLastMessages: roomsWithLastMessages,
        ),
      );
    }

    emit(newState);
  }

  void sendMessage({
    required Message message,
  }) {
    final sentMessageInfo = SentMessageInfo(
      message: message,
      lastSendingTime: _dateTimeHelper.getCurrentUtcDateTime(),
    );

    if (_serverConnectionCubit.state == ServerConnectionStatus.connected) {
      _messagesRepository.sendMessage(message);
      final roomProbablyDeliveredSentMessageInfos = [
        ...state.probablyDeliveredMessagesContainer.getRoomSentMessageInfos(message.room),
        sentMessageInfo,
      ];
      final probablyDeliveredMessagesContainer =
          state.probablyDeliveredMessagesContainer.copyWithRoomSentMessageInfos(
        room: message.room,
        sentMessageInfos: roomProbablyDeliveredSentMessageInfos,
      );
      emit(state.copyWith(
        probablyDeliveredMessagesContainer: probablyDeliveredMessagesContainer,
      ));
    } else {
      final roomUndeliveredSentMessageInfos = [
        ...state.undeliveredMessagesContainer.getRoomSentMessageInfos(message.room),
        sentMessageInfo,
      ];
      final undeliveredMessagesContainer =
          state.undeliveredMessagesContainer.copyWithRoomSentMessageInfos(
        room: message.room,
        sentMessageInfos: roomUndeliveredSentMessageInfos,
      );
      emit(state.copyWith(
        undeliveredMessagesContainer: undeliveredMessagesContainer,
      ));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription.cancel();
    _serverConnectionStatusSubscription.cancel();
    _stateSubscription.cancel();
    return super.close();
  }
}
