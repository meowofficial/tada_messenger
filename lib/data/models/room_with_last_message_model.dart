import 'package:equatable/equatable.dart';
import 'package:tada_messenger/data/models/message_models.dart';
import 'package:tada_messenger/data/models/room_model.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';

class RoomWithLastMessageModel extends Equatable {
  const RoomWithLastMessageModel({
    required this.room,
    required this.lastMessage,
  });

  final RoomModel room;
  final ServerMessageModel lastMessage;

  @override
  List<Object?> get props {
    return [
      room,
      lastMessage,
    ];
  }

  factory RoomWithLastMessageModel.fromJson(Map<String, dynamic> json) {
    return RoomWithLastMessageModel(
      room: RoomModel.fromString(json['name']),
      lastMessage: ServerMessageModel.fromJson(json['last_message']),
    );
  }

  RoomWithLastMessage toRoomWithLastMessageEntity() {
    return RoomWithLastMessage(
      room: room.toRoomEntity(),
      lastMessage: lastMessage.toMessageEntity(),
    );
  }
}
