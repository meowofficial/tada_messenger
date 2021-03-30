import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';

class OutdatableRoomsWithLastMessages extends Equatable {
  OutdatableRoomsWithLastMessages({
    required this.roomsWithLastMessages,
    required this.dataStatus,
    required this.lastUpdateRequestTime,
  });

  final List<RoomWithLastMessage> roomsWithLastMessages;
  final OutdatableDataStatus dataStatus;
  final DateTime? lastUpdateRequestTime;

  @override
  List<Object?> get props {
    return [
      roomsWithLastMessages,
      dataStatus,
      lastUpdateRequestTime,
    ];
  }

  OutdatableRoomsWithLastMessages copyWith({
    List<RoomWithLastMessage>? roomsWithLastMessages,
    OutdatableDataStatus? dataStatus,
    int? lastUpdateRequestTimeMs = 0,
  }) {
    DateTime? lastUpdateRequestTime;
    if (lastUpdateRequestTimeMs == null) {
      lastUpdateRequestTime = null;
    } else if (lastUpdateRequestTimeMs == 0) {
      lastUpdateRequestTime = this.lastUpdateRequestTime;
    } else {
      lastUpdateRequestTime =
          DateTime.fromMicrosecondsSinceEpoch(lastUpdateRequestTimeMs, isUtc: true);
    }
    return OutdatableRoomsWithLastMessages(
      roomsWithLastMessages: roomsWithLastMessages ?? this.roomsWithLastMessages,
      dataStatus: dataStatus ?? this.dataStatus,
      lastUpdateRequestTime: lastUpdateRequestTime,
    );
  }
}
