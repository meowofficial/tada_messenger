import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';

class RoomOutdatableMessageHistory extends Equatable {
  RoomOutdatableMessageHistory({
    required this.messages,
    required this.dataStatus,
    required this.lastUpdateRequestTime,
  });

  final List<Message> messages;
  final OutdatableDataStatus dataStatus;
  final DateTime? lastUpdateRequestTime;

  @override
  List<Object?> get props {
    return [
      messages,
      dataStatus,
      lastUpdateRequestTime,
    ];
  }

  RoomOutdatableMessageHistory copyWith({
    List<Message>? messages,
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
    return RoomOutdatableMessageHistory(
      messages: messages ?? this.messages,
      dataStatus: dataStatus ?? this.dataStatus,
      lastUpdateRequestTime: lastUpdateRequestTime,
    );
  }
}
