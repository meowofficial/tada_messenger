import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/room_outdatable_message_history.dart';

class RoomsOutdatableMessageHistory extends Equatable {
  RoomsOutdatableMessageHistory.fromMap({
    required Map<Room, RoomOutdatableMessageHistory> roomsOutdatableMessageHistoryMap,
  }) : _roomsOutdatableMessageHistoryMap = roomsOutdatableMessageHistoryMap;

  final Map<Room, RoomOutdatableMessageHistory> _roomsOutdatableMessageHistoryMap;

  @override
  List<Object?> get props {
    return [
      _roomsOutdatableMessageHistoryMap,
    ];
  }

  bool isRoomMessageHistoryPresent(Room room) {
    return _roomsOutdatableMessageHistoryMap.containsKey(room);
  }

  RoomOutdatableMessageHistory getRoomOutdatableMessageHistory(Room room) {
    if (_roomsOutdatableMessageHistoryMap.containsKey(room)) {
      return _roomsOutdatableMessageHistoryMap[room]!;
    }
    return RoomOutdatableMessageHistory(
      messages: [],
      dataStatus: OutdatableDataStatus.outdated,
      lastUpdateRequestTime: null,
    );
  }

  RoomsOutdatableMessageHistory copyWithRoomOutdatableMessageHistory({
    required Room room,
    required RoomOutdatableMessageHistory roomOutdatableMessageHistory,
  }) {
    final roomsOutdatableMessageHistoryMap = {..._roomsOutdatableMessageHistoryMap};
    roomsOutdatableMessageHistoryMap[room] = roomOutdatableMessageHistory;
    return RoomsOutdatableMessageHistory.fromMap(
      roomsOutdatableMessageHistoryMap: roomsOutdatableMessageHistoryMap,
    );
  }

  RoomsOutdatableMessageHistory copyWithOutdatedRoomsMessageHistory() {
    final roomsOutdatableMessageHistoryMap =
        _roomsOutdatableMessageHistoryMap.map((room, outdatableRoomMessageHistory) {
      return MapEntry(
        room,
        outdatableRoomMessageHistory.copyWith(
          dataStatus: OutdatableDataStatus.outdated,
        ),
      );
    });
    return RoomsOutdatableMessageHistory.fromMap(
      roomsOutdatableMessageHistoryMap: roomsOutdatableMessageHistoryMap,
    );
  }
}
