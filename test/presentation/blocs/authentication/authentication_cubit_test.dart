import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tada_messenger/domain/entities/user.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';
import 'package:tada_messenger/presentation/blocs/authentication/authentication_cubit.dart';

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {}

void main() {
  final user = User(username: 'test');
  late AuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
  });

  group('Authentication Cubit', () {
    test(
      'initial state is AuthenticationState.unknown()',
      () async {
        when(() => authenticationRepository.user).thenAnswer((_) => const Stream.empty());
        final authenticationCubit = AuthenticationCubit(
          authenticationRepository: authenticationRepository,
        );
        expect(authenticationCubit.state, AuthenticationState.unknown());
        authenticationCubit.close();
      },
    );

    blocTest<AuthenticationCubit, AuthenticationState>(
      'emits [unauthenticated] when user is null',
      build: () {
        when(() => authenticationRepository.user).thenAnswer((_) => Stream.value(null));
        return AuthenticationCubit(
          authenticationRepository: authenticationRepository,
        );
      },
      expect: () {
        return [
          AuthenticationState.unauthenticated(),
        ];
      },
    );

    blocTest<AuthenticationCubit, AuthenticationState>(
      'emits [unauthenticated] when user is not null',
      build: () {
        when(() => authenticationRepository.user).thenAnswer((_) => Stream.value(user));
        return AuthenticationCubit(
          authenticationRepository: authenticationRepository,
        );
      },
      expect: () {
        return [
          AuthenticationState.authenticated(user: user),
        ];
      },
    );

    blocTest<AuthenticationCubit, AuthenticationState>(
      'calls logOut on authenticationRepository when logOut requested',
      build: () {
        when(() => authenticationRepository.user).thenAnswer((_) => Stream.value(user));
        when(() => authenticationRepository.logOut()).thenAnswer((_) => Future.value(null));
        return AuthenticationCubit(
          authenticationRepository: authenticationRepository,
        );
      },
      act: (authenticationCubit) {
        authenticationCubit.requestAuthenticationLogout();
      },
      verify: (authenticationCubit) {
        verify(() => authenticationRepository.logOut()).called(1);
      },
    );
  });
}
