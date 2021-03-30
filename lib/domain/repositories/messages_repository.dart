import 'package:dartz/dartz.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';
import 'package:tada_messenger/error/failures.dart';

abstract class MessagesRepository {
  Future<Either<Failure, List<RoomWithLastMessage>>> getRoomsWithLastMessages();
  Future<Either<Failure, List<Message>>> getRoomMessageHistory(Room room);
  void sendMessage(Message message);
  Stream<Message> get messages;
}