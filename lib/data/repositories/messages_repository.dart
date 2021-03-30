import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:tada_messenger/data/clients/main_socket_client.dart';
import 'package:tada_messenger/data/models/message_models.dart';
import 'package:tada_messenger/data/models/room_with_last_message_model.dart';
import 'package:tada_messenger/domain/entities/message.dart';
import 'package:tada_messenger/domain/entities/room.dart';
import 'package:tada_messenger/domain/entities/room_with_last_message.dart';
import 'package:tada_messenger/domain/repositories/messages_repository.dart';
import 'package:tada_messenger/error/failures.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  static const _apiBaseUrl = 'https://nane.tada.team/api';

  MessagesRepositoryImpl({
    required this.httpClient,
    required this.mainSocketClient,
  });

  final http.Client httpClient;
  final MainSocketClient mainSocketClient;

  @override
  Stream<Message> get messages {
    return mainSocketClient.events.where((event) {
      return event is MainSocketClientMessageReceived;
    }).map((event) {
      final serverMessageModel = (event as MainSocketClientMessageReceived).serverMessageModel;
      return serverMessageModel.toMessageEntity();
    });
  }

  String _encodeRoomName(String roomName) {
    return Uri.encodeComponent(roomName);
  }

  @override
  Future<Either<Failure, List<Message>>> getRoomMessageHistory(Room room) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$_apiBaseUrl/rooms/${_encodeRoomName(room.name)}/history'));
      if (response.statusCode == 200) {
        List<Map> messageMaps = List.castFrom(json.decode(response.body)['result']);
        final messages = messageMaps.map((messageMap) {
          Map<String, dynamic> massageJson = Map.castFrom(messageMap);
          return ServerMessageModel.fromJson(massageJson).toMessageEntity();
        }).toList();
        return Right(messages);
      } else {
        return Left(RoomNotFoundFailure());
      }
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RoomWithLastMessage>>> getRoomsWithLastMessages() async {
    try {
      final response = await httpClient.get(Uri.parse('$_apiBaseUrl/rooms'));
      if (response.statusCode == 200) {
        List<Map> roomWithLastMessageMaps = List.castFrom(json.decode(response.body)['result']);
        final roomsWithLastMessages = roomWithLastMessageMaps.map((roomWithLastMessageMap) {
          Map<String, dynamic> roomWithLastMessageJson = Map.castFrom(roomWithLastMessageMap);
          return RoomWithLastMessageModel.fromJson(roomWithLastMessageJson)
              .toRoomWithLastMessageEntity();
        }).toList();
        return Right(roomsWithLastMessages);
      } else {
        return Left(ServerFailure());
      }
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  void sendMessage(Message message) {
    mainSocketClient.sendMessage(ClientMessageModel.fromMessageEntity(message));
  }
}
