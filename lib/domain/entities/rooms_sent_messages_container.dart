import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/sent_message_info.dart';

class RoomsSentMessagesContainer extends Equatable {
  RoomsSentMessagesContainer.fromMap({
    required Map<Room, List<SentMessageInfo>> messagesMap,
  }) : _messagesMap = _convertMessagesMapToUnmodifiable(messagesMap);

  RoomsSentMessagesContainer._fromUnmodifiableMapView({
    required UnmodifiableMapView<Room, UnmodifiableListView<SentMessageInfo>> messagesMap,
  }) : _messagesMap = messagesMap;

  final UnmodifiableMapView<Room, UnmodifiableListView<SentMessageInfo>> _messagesMap;

  @override
  List<Object?> get props {
    return [
      _messagesMap,
    ];
  }

  static UnmodifiableMapView<Room, UnmodifiableListView<SentMessageInfo>>
      _convertMessagesMapToUnmodifiable(Map<Room, List<SentMessageInfo>> messagesMap) {
    return UnmodifiableMapView(messagesMap.map((room, sentMessageInfos) {
      return MapEntry(room, UnmodifiableListView(sentMessageInfos));
    }));
  }

  UnmodifiableListView<Room> get rooms {
    return UnmodifiableListView(_messagesMap.keys);
  }

  UnmodifiableListView<SentMessageInfo> getRoomSentMessageInfos(Room room) {
    return _messagesMap[room] ?? UnmodifiableListView([]);
  }

  UnmodifiableMapView<Room, UnmodifiableListView<SentMessageInfo>> getAllSentMessageInfosAsMap() {
    return _messagesMap;
  }

  RoomsSentMessagesContainer copyWithRoomSentMessageInfos({
    required Room room,
    required List<SentMessageInfo> sentMessageInfos,
  }) {
    final messagesMap = {..._messagesMap};
    messagesMap[room] = UnmodifiableListView(sentMessageInfos);
    return RoomsSentMessagesContainer._fromUnmodifiableMapView(
      messagesMap: UnmodifiableMapView(messagesMap),
    );
  }
}
