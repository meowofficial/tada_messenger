import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tada_messenger/data/clients/main_socket_client.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';

class MockMainSocketClient extends Mock implements MainSocketClient {}

void main() {
  late MainSocketClient mainSocketClient;

  setUp(() {
    mainSocketClient = MockMainSocketClient();
    when(() => mainSocketClient.connectionStatus)
        .thenAnswer((_) => ServerConnectionStatus.disconnected);
  });

  group('ServerConnectionCubit', () {
    blocTest<ServerConnectionCubit, ServerConnectionStatus>(
      'emits ServerConnectionStatus when it changed',
      build: () {
        when(() => mainSocketClient.onConnectionStatusChanged).thenAnswer((_) {
          return Stream.fromIterable([
            ServerConnectionStatus.connecting,
            ServerConnectionStatus.connected,
            ServerConnectionStatus.disconnected,
          ]);
        });
        return ServerConnectionCubit(
          mainSocketClient: mainSocketClient,
        );
      },
      expect: () {
        return [
          ServerConnectionStatus.connecting,
          ServerConnectionStatus.connected,
          ServerConnectionStatus.disconnected,
        ];
      },
    );
  });
}
