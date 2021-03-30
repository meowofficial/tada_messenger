import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tada_messenger/domain/entities/outdatable_data_status.dart';
import 'package:tada_messenger/domain/entities/outdatable_rooms_with_last_messages.dart';
import 'package:tada_messenger/domain/entities/server_connection_status.dart';
import 'package:tada_messenger/domain/repositories/messages_repository.dart';
import 'package:tada_messenger/error/failures.dart';
import 'package:tada_messenger/presentation/blocs/messages/messages_cubit.dart';
import 'package:tada_messenger/presentation/blocs/server_connection/server_connection_cubit.dart';
import 'package:tada_messenger/presentation/helpers/date_time_helper.dart';

import '../predefined_bloc_states.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

class MockServerConnectionCubit extends MockCubit<ServerConnectionStatus>
    implements ServerConnectionCubit {}

class MockDateTimeHelper extends Mock implements DateTimeHelper {}

void main() {
  late MockMessagesRepository messagesRepository;
  late MockServerConnectionCubit serverConnectionCubit;
  late MockDateTimeHelper dateTimeHelper;

  final testDateTime = DateTime.now().toUtc();

  setUp(() {
    registerFallbackValue<ServerConnectionStatus>(defaultInitialServerConnectionStatus);

    serverConnectionCubit = MockServerConnectionCubit();
    messagesRepository = MockMessagesRepository();
    dateTimeHelper = MockDateTimeHelper();

    whenListen(
      serverConnectionCubit,
      Stream<ServerConnectionStatus>.empty(),
      initialState: defaultInitialServerConnectionStatus,
    );

    when(() => messagesRepository.messages).thenAnswer((_) => Stream.empty());
    when(() => dateTimeHelper.getCurrentUtcDateTime()).thenReturn(testDateTime);
  });

  group(
    'Messages Cubit',
        () {
      group(
        'updateRoomsWithLastMessagesIfPossible()',
            () {
          blocTest<MessagesCubit, MessagesState>(
            'emits nothing when outdatableRoomsWithLastMessages.dataStatus is not outdated',
            build: () {
              when(() => serverConnectionCubit.state)
                  .thenReturn(ServerConnectionStatus.connected);
              return MessagesCubit(
                messagesRepository: messagesRepository,
                serverConnectionCubit: serverConnectionCubit,
                  dateTimeHelper: dateTimeHelper,
              );
            },
            seed: () {
              return defaultInitialMessagesState.copyWith(
                outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                  roomsWithLastMessages: [],
                  dataStatus: OutdatableDataStatus.updating,
                  lastUpdateRequestTime: null,
                ),
              );
            },
            act: (messagesCubit) {
              messagesCubit.updateRoomsWithLastMessagesIfPossible();
            },
            expect: () {
              return [];
            },
          );

          blocTest<MessagesCubit, MessagesState>(
            'emits nothing when serverConnectionStatus is not connected',
            build: () {
              when(() => serverConnectionCubit.state)
                  .thenReturn(ServerConnectionStatus.connecting);
              return MessagesCubit(
                messagesRepository: messagesRepository,
                serverConnectionCubit: serverConnectionCubit,
                dateTimeHelper: dateTimeHelper,
              );
            },
            seed: () {
              return defaultInitialMessagesState.copyWith(
                outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                  roomsWithLastMessages: [],
                  dataStatus: OutdatableDataStatus.outdated,
                  lastUpdateRequestTime: null,
                ),
              );
            },
            act: (messagesCubit) {
              messagesCubit.updateRoomsWithLastMessagesIfPossible();
            },
            expect: () {
              return [];
            },
          );

          blocTest<MessagesCubit, MessagesState>(
            'emits updating and outdated RoomsWithLastMessages status when data loading fails',
            build: () {
              when(() => serverConnectionCubit.state)
                  .thenReturn(ServerConnectionStatus.connected);

              when(() => messagesRepository.getRoomsWithLastMessages()).thenAnswer((_) {
                return Future.value(Left(ServerFailure()));
              });
              return MessagesCubit(
                messagesRepository: messagesRepository,
                serverConnectionCubit: serverConnectionCubit,
                dateTimeHelper: dateTimeHelper,
              );
            },
            seed: () {
              return defaultInitialMessagesState.copyWith(
                outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                  roomsWithLastMessages: [],
                  dataStatus: OutdatableDataStatus.outdated,
                  lastUpdateRequestTime: null,
                ),
              );
            },
            act: (messagesCubit) {
              messagesCubit.updateRoomsWithLastMessagesIfPossible();
            },
            expect: () {
              return [
                defaultInitialMessagesState.copyWith(
                  outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                    roomsWithLastMessages: [],
                    dataStatus: OutdatableDataStatus.updating,
                    lastUpdateRequestTime: null,
                  ),
                ),
                defaultInitialMessagesState.copyWith(
                  outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                    roomsWithLastMessages: [],
                    dataStatus: OutdatableDataStatus.outdated,
                    lastUpdateRequestTime: null,
                  ),
                ),
              ];
            },
          );

          blocTest<MessagesCubit, MessagesState>(
            'emits updating and updated RoomsWithLastMessages status when data loaded',
            build: () {
              when(() => serverConnectionCubit.state)
                  .thenReturn(ServerConnectionStatus.connected);

              when(() => messagesRepository.getRoomsWithLastMessages()).thenAnswer((_) {
                return Future.value(Right(defaultRoomsWithLastMessages));
              });

              return MessagesCubit(
                messagesRepository: messagesRepository,
                serverConnectionCubit: serverConnectionCubit,
                dateTimeHelper: dateTimeHelper,
              );
            },
            seed: () {
              return defaultInitialMessagesState.copyWith(
                outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                  roomsWithLastMessages: [],
                  dataStatus: OutdatableDataStatus.outdated,
                  lastUpdateRequestTime: null,
                ),
              );
            },
            act: (messagesCubit) {
              messagesCubit.updateRoomsWithLastMessagesIfPossible();
            },
            expect: () {
              return [
                defaultInitialMessagesState.copyWith(
                  outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                    roomsWithLastMessages: [],
                    dataStatus: OutdatableDataStatus.updating,
                    lastUpdateRequestTime: null,
                  ),
                ),
                defaultInitialMessagesState.copyWith(
                  outdatableRoomsWithLastMessages: OutdatableRoomsWithLastMessages(
                    roomsWithLastMessages: defaultRoomsWithLastMessages,
                    dataStatus: OutdatableDataStatus.updated,
                    lastUpdateRequestTime: testDateTime,
                  ),
                ),
                isA<MessagesState>(),
              ];
            },
          );
        },
      );
    },
  );
}
