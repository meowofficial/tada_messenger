import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';
import 'package:tada_messenger/error/failures.dart';
import 'package:tada_messenger/presentation/blocs/login_page/login_page_cubit.dart';
import 'package:tada_messenger/presentation/models/username_input.dart';

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {}

void main() {
  late AuthenticationRepository authenticationRepository;
  late LoginPageCubit loginPageCubit;

  const validUsernameString = 'user';
  const validUsernameInput = UsernameInput.dirty(validUsernameString);
  const invalidUsernameString = '';
  const invalidUsernameInput = UsernameInput.dirty(invalidUsernameString);

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    loginPageCubit = LoginPageCubit(
      authenticationRepository: authenticationRepository,
    );
  });

  tearDown(() {
    loginPageCubit.close();
  });

  group('LoginPageCubit', () {
    test('initial state is LoginPageState.initial()', () {
      expect(loginPageCubit.state, LoginPageState.initial());
    });

    blocTest<LoginPageCubit, LoginPageState>(
      'emits state with new username when it changed',
      build: () {
        return loginPageCubit;
      },
      act: (loginPageCubit) {
        loginPageCubit.usernameChanged(validUsernameString);
      },
      expect: () {
        return [
          LoginPageState(
            usernameInput: validUsernameInput,
            submissionStatus: LoginFormNotSubmitted(),
          ),
        ];
      },
    );

    blocTest<LoginPageCubit, LoginPageState>(
      'emits state with LoginFormSubmissionValidationFailure when username is invalid',
      build: () {
        return loginPageCubit;
      },
      seed: () {
        return LoginPageState(
          usernameInput: invalidUsernameInput,
          submissionStatus: LoginFormNotSubmitted(),
        );
      },
      act: (loginPageCubit) {
        loginPageCubit.logIn();
      },
      verify: (loginPageCubit) {
        expect(loginPageCubit.state.submissionStatus, isA<LoginFormSubmissionValidationFailure>());
      },
    );

    blocTest<LoginPageCubit, LoginPageState>(
      'emits state with LoginFormSubmissionNetworkFailure when form is valid and authenticationRepository returns ServerFailure',
      build: () {
        when(() {
          return authenticationRepository.logIn(
            username: any(named: 'username'),
          );
        }).thenAnswer((_) => Future.value(Left(ServerFailure())));
        return loginPageCubit;
      },
      seed: () {
        return LoginPageState(
          usernameInput: validUsernameInput,
          submissionStatus: LoginFormNotSubmitted(),
        );
      },
      act: (loginPageCubit) {
        loginPageCubit.logIn();
      },
      verify: (loginPageCubit) {
        expect(loginPageCubit.state.submissionStatus, isA<LoginFormSubmissionNetworkFailure>());
      },
    );

    blocTest<LoginPageCubit, LoginPageState>(
      'emits state with LoginFormSubmissionSuccess when form is valid and authenticationRepository returns success',
      build: () {
        when(() {
          return authenticationRepository.logIn(
            username: any(named: 'username'),
          );
        }).thenAnswer((_) => Future.value(Right(null)));
        return loginPageCubit;
      },
      seed: () {
        return LoginPageState(
          usernameInput: validUsernameInput,
          submissionStatus: LoginFormNotSubmitted(),
        );
      },
      act: (loginPageCubit) {
        loginPageCubit.logIn();
      },
      verify: (loginPageCubit) {
        expect(loginPageCubit.state.submissionStatus, isA<LoginFormSubmissionSuccess>());
      },
    );
  });
}
