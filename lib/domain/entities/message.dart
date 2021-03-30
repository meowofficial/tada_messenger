import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/user.dart';

enum MessageDeliveryStatus {
  delivered,
  probablyDelivered,
  undelivered,
}

class Message extends Equatable {
  Message({
    required this.text,
    required this.sender,
    required this.room,
    required this.deliveryStatus,
    required this.time,
    this.id,
  }) : assert(text.isNotEmpty);

  final String? id;
  final String text;
  final DateTime time;
  final User sender;
  final Room room;
  final MessageDeliveryStatus deliveryStatus;

  @override
  List<Object?> get props {
    return [
      id,
      text,
      time,
      sender,
      room,
      deliveryStatus,
    ];
  }

  Message copyWith({
    String? id,
    String? text,
    DateTime? time,
    User? sender,
    Room? room,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      sender: sender ?? this.sender,
      room: room ?? this.room,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
