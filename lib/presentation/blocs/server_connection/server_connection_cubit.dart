import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tada_messenger/data/clients/main_socket_client.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';

class ServerConnectionCubit extends Cubit<ServerConnectionStatus> {
  ServerConnectionCubit({
    required MainSocketClient mainSocketClient,
  })   : super(mainSocketClient.connectionStatus) {
    _serverConnectionStatusSubscription =
        mainSocketClient.onConnectionStatusChanged.listen((serverConnectionStatus) {
      emit(serverConnectionStatus);
    });
  }

  late StreamSubscription<ServerConnectionStatus> _serverConnectionStatusSubscription;

  @override
  Future<void> close() {
    _serverConnectionStatusSubscription.cancel();
    return super.close();
  }
}
