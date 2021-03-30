import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tada_messenger/data/models/message_models.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';

abstract class MainSocketClientEvent {}

class MainSocketClientMessageReceived extends MainSocketClientEvent {
  MainSocketClientMessageReceived({
    required this.serverMessageModel,
  });

  final ServerMessageModel serverMessageModel;
}

abstract class MainSocketClient {
  Stream<MainSocketClientEvent> get events;

  Stream<ServerConnectionStatus> get onConnectionStatusChanged;

  ServerConnectionStatus get connectionStatus;

  void sendMessage(ClientMessageModel clientMessageModel);

  void dispose();
}

class MainSocketClientImpl implements MainSocketClient {
  final StreamController<MainSocketClientEvent> _eventStreamController =
      StreamController.broadcast();
  final StreamController<ServerConnectionStatus> _connectionStatusStreamController =
      StreamController.broadcast();

  final String _username;

  late WebSocket _socket;

  @override
  ServerConnectionStatus connectionStatus;

  MainSocketClientImpl({
    required String username,
  })   : _username = username,
        connectionStatus = ServerConnectionStatus.disconnected {
    _initWebSocketConnection();
  }

  @override
  Stream<MainSocketClientEvent> get events => _eventStreamController.stream;

  @override
  Stream<ServerConnectionStatus> get onConnectionStatusChanged =>
      _connectionStatusStreamController.stream;

  void _initWebSocketConnection() async {
    _changeConnectionStatus(ServerConnectionStatus.connecting);
    _socket = await _connectToWebSocket();
    _socket.pingInterval = Duration(milliseconds: 1000);
    _changeConnectionStatus(ServerConnectionStatus.connected);
    _socket.done.then((_) {
      _onDisconnected();
    });
    _socket.listen(
      _onSocketDataReceived,
      onDone: () {
        _onDisconnected();
      },
      onError: (e) {
        _onDisconnected();
      },
    );
  }

  Future<WebSocket> _connectToWebSocket() async {
    try {
      return await WebSocket.connect('wss://nane.tada.team/ws?username=$_username');
    } on Exception {
      await Future.delayed(Duration(milliseconds: 1000));
      return await _connectToWebSocket();
    }
  }

  void _onSocketDataReceived(socketData) {
    final serverMessageJson = json.decode(socketData);
    final serverMessageModel = ServerMessageModel.fromJson(serverMessageJson);
    _eventStreamController.add(MainSocketClientMessageReceived(
      serverMessageModel: serverMessageModel,
    ));
  }

  @override
  void sendMessage(ClientMessageModel clientMessageModel) async {
    _socket.add(json.encode(clientMessageModel.toJson()));
  }

  void _onDisconnected() {
    _changeConnectionStatus(ServerConnectionStatus.disconnected);
    _initWebSocketConnection();
  }

  void _changeConnectionStatus(ServerConnectionStatus connectionStatus) {
    this.connectionStatus = connectionStatus;
    _connectionStatusStreamController.sink.add(connectionStatus);
  }

  @override
  void dispose() {
    _eventStreamController.close();
    _connectionStatusStreamController.close();
  }
}
