import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tada_messenger/data/models/message_models.dart';
import 'package:tada_messenger/data/models/room_model.dart';
import 'package:tada_messenger/data/models/user_model.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/user.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  final tServerMessageModelWithId = ServerMessageModel(
    id: '123',
    room: RoomModel(
      name: 'room1',
    ),
    sender: UserModel(
      username: 'user1',
    ),
    creationTime: DateTime(2000),
    text: 'test',
  );

  final tServerMessageModelWithoutId = ServerMessageModel(
    room: RoomModel(
      name: 'room1',
    ),
    sender: UserModel(
      username: 'user1',
    ),
    creationTime: DateTime(2000),
    text: 'test',
  );

  final tServerMessageWithId = Message(
    id: '123',
    text: 'test',
    sender: User(
      username: 'user1',
    ),
    room: Room(
      name: 'room1',
    ),
    time: DateTime(2000),
    deliveryStatus: MessageDeliveryStatus.delivered,
  );

  final tServerMessageWithoutId = Message(
    text: 'test',
    sender: User(
      username: 'user1',
    ),
    room: Room(
      name: 'room1',
    ),
    time: DateTime(2000),
    deliveryStatus: MessageDeliveryStatus.delivered,
  );

  group(
    'ServerMessageModel',
    () {
      test(
        'should return ServerMessageModel from json with id',
        () {
          final serverMessageModelJson = jsonDecode(fixture('server_message_model_with_id.json'));
          final serverMessageModel = ServerMessageModel.fromJson(serverMessageModelJson);
          expect(serverMessageModel, equals(tServerMessageModelWithId));
        },
      );

      test(
        'should return ServerMessageModel from json without id',
        () {
          final serverMessageModelJson =
              jsonDecode(fixture('server_message_model_without_id.json'));
          final serverMessageModel = ServerMessageModel.fromJson(serverMessageModelJson);
          expect(serverMessageModel, equals(tServerMessageModelWithoutId));
        },
      );

      test(
        'should return Message from ServerMessageModel with id',
            () {
          final message = tServerMessageModelWithId.toMessageEntity();
          expect(message, equals(tServerMessageWithId));
        },
      );

      test(
        'should return Message from ServerMessageModel without id',
            () {
          final message = tServerMessageModelWithoutId.toMessageEntity();
          expect(message, equals(tServerMessageWithoutId));
        },
      );
    },
  );
}
