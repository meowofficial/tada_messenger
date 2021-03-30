import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tada_messenger/data/clients/main_socket_client.dart';
import 'package:tada_messenger/data/data_sources/authentication_data_source.dart';
import 'package:tada_messenger/data/repositories/authentication_repository.dart';
import 'package:tada_messenger/data/repositories/messages_repository.dart';
import 'package:tada_messenger/domain/entities/authentication_status.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';
import 'package:tada_messenger/domain/repositories/messages_repository.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/helpers/date_time_helper.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() {
    return AuthenticationCubit(
      authenticationRepository: sl(),
    );
  });

  sl.registerLazySingleton<AuthenticationRepository>(() {
    return AuthenticationRepositoryImpl(
      authenticationDataSource: sl(),
    );
  });

  sl.registerLazySingleton<AuthenticationDataSource>(() {
    return AuthenticationDataSourceImpl(
      sharedPreferences: sl(),
    );
  });

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() {
    return sharedPreferences;
  });

  sl.registerLazySingleton(() {
    return http.Client();
  });

  sl.registerLazySingleton<DateTimeHelper>(() {
    return DateTimeHelperImpl();
  });
}

void onAuthenticationChanged() {
  if (sl.isRegistered<MessagesCubit>()) {
    sl.unregister<MessagesCubit>(
      disposingFunction: (messagesCubit) {
        messagesCubit.close();
      },
    );
  }
  if (sl.isRegistered<MessagesRepository>()) {
    sl.unregister<MessagesRepository>();
  }
  if (sl.isRegistered<MainSocketClient>()) {
    sl.unregister<MainSocketClient>(
      disposingFunction: (mainSocketClient) {
        mainSocketClient.dispose();
      },
    );
  }
  if (sl.isRegistered<ServerConnectionCubit>()) {
    sl.unregister<ServerConnectionCubit>(
      disposingFunction: (serverConnectionCubit) {
        serverConnectionCubit.close();
      },
    );
  }

  if (sl<AuthenticationCubit>().state.authenticationStatus == AuthenticationStatus.authenticated) {
    sl.registerLazySingleton<MainSocketClient>(() {
      return MainSocketClientImpl(
        username: sl<AuthenticationCubit>().state.user!.username,
      );
    });

    sl.registerLazySingleton(() {
      return ServerConnectionCubit(
        mainSocketClient: sl(),
      );
    });

    sl.registerLazySingleton<MessagesRepository>(() {
      return MessagesRepositoryImpl(
        httpClient: sl(),
        mainSocketClient: sl(),
      );
    });

    sl.registerLazySingleton(() {
      return MessagesCubit(
        messagesRepository: sl(),
        serverConnectionCubit: sl(),
        dateTimeHelper: sl(),
      );
    });
  }
}
