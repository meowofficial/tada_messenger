part of 'messages_cubit.dart';

class MessagesState extends Equatable {
  MessagesState({
    required this.outdatableRoomsWithLastMessages,
    required this.roomsOutdatableMessageHistory,
    required this.probablyDeliveredMessagesContainer,
    required this.undeliveredMessagesContainer,
    required this.notFoundRooms,
    required this.beingFoundRooms,
  });

  final OutdatableRoomsWithLastMessages outdatableRoomsWithLastMessages;
  final RoomsOutdatableMessageHistory roomsOutdatableMessageHistory;
  final RoomsSentMessagesContainer probablyDeliveredMessagesContainer;
  final RoomsSentMessagesContainer undeliveredMessagesContainer;
  final Set<Room> notFoundRooms;
  final Set<Room> beingFoundRooms;

  @override
  List<Object?> get props {
    return [
      outdatableRoomsWithLastMessages,
      roomsOutdatableMessageHistory,
      probablyDeliveredMessagesContainer,
      undeliveredMessagesContainer,
      notFoundRooms,
      beingFoundRooms,
    ];
  }

  MessagesState copyWith({
    OutdatableRoomsWithLastMessages? outdatableRoomsWithLastMessages,
    RoomsOutdatableMessageHistory? roomsOutdatableMessageHistory,
    RoomsSentMessagesContainer? probablyDeliveredMessagesContainer,
    RoomsSentMessagesContainer? undeliveredMessagesContainer,
    Set<Room>? notFoundRooms,
    Set<Room>? beingFoundRooms,
  }) {
    return MessagesState(
      outdatableRoomsWithLastMessages:
          outdatableRoomsWithLastMessages ?? this.outdatableRoomsWithLastMessages,
      roomsOutdatableMessageHistory:
          roomsOutdatableMessageHistory ?? this.roomsOutdatableMessageHistory,
      probablyDeliveredMessagesContainer:
          probablyDeliveredMessagesContainer ?? this.probablyDeliveredMessagesContainer,
      undeliveredMessagesContainer:
          undeliveredMessagesContainer ?? this.undeliveredMessagesContainer,
      notFoundRooms: notFoundRooms ?? this.notFoundRooms,
      beingFoundRooms: beingFoundRooms ?? this.beingFoundRooms,
    );
  }
}
