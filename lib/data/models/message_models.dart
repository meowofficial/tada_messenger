import 'package:equatable/equatable.dart';
import 'package:tada_messenger/data/models/room_model.dart';
import 'package:tada_messenger/data/models/user_model.dart';
import 'package:tada_messenger/domain/entities/message.dart';

class ServerMessageModel extends Equatable {
  ServerMessageModel({
    required this.text,
    required this.sender,
    required this.room,
    required this.creationTime,
    this.id,
  })  : assert(text.isNotEmpty);

  final String? id;
  final String text;
  final DateTime creationTime;
  final UserModel sender;
  final RoomModel room;

  @override
  List<Object?> get props {
    return [
      id,
      text,
      creationTime,
      sender,
      room,
    ];
  }

  factory ServerMessageModel.fromJson(Map<String, dynamic> json) {
    return ServerMessageModel(
      id: json['id'],
      text: json['text'],
      creationTime: DateTime.parse(json['created']),
      sender: UserModel.fromJson(json['sender']),
      room: RoomModel.fromString(json['room']),
    );
  }

  Message toMessageEntity() {
    return Message(
      id: id,
      text: text,
      time: creationTime,
      sender: sender.toUserEntity(),
      room: room.toRoomEntity(),
      deliveryStatus: MessageDeliveryStatus.delivered,
    );
  }
}

class ClientMessageModel extends Equatable {
  ClientMessageModel({
    required this.text,
    required this.room,
    this.id,
  })  : assert(text.isNotEmpty);

  final String? id;
  final String text;
  final RoomModel room;

  @override
  List<Object?> get props {
    return [
      id,
      text,
      room,
    ];
  }

  Map<String, dynamic> toJson() {
    final clientMessageJson = {
      'text': text,
      'room': room.toString(),
    };
    if (id != null) {
      clientMessageJson['id'] = id!;
    }
    return clientMessageJson;
  }

  factory ClientMessageModel.fromMessageEntity(Message message) {
    return ClientMessageModel(
      id: message.id,
      text: message.text,
      room: RoomModel.fromString(message.room.name),
    );
  }
}
