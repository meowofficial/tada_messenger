import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';

class RoomWithLastMessage extends Equatable {
  const RoomWithLastMessage({
    required this.room,
    required this.lastMessage,
  });

  final Room room;
  final Message lastMessage;

  @override
  List<Object?> get props {
    return [
      room,
      lastMessage,
    ];
  }

  RoomWithLastMessage copyWith({
    Room? room,
    Message? lastMessage,
  }) {
    return RoomWithLastMessage(
      room: room ?? this.room,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
