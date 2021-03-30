import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';
import 'package:tada_messenger/presentation/models/username_input.dart';
import 'package:tada_messenger/presentation/models/validation_error.dart';

part 'login_page_state.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit({
    required AuthenticationRepository authenticationRepository,
  })   : _authenticationRepository = authenticationRepository,
        super(LoginPageState.initial());

  final AuthenticationRepository _authenticationRepository;

  void usernameChanged(String value) {
    final username = UsernameInput.dirty(value);
    emit(state.copyWith(
      usernameInput: username,
      submissionStatus: LoginFormNotSubmitted(),
      valid: username.valid,
    ));
  }

  void logIn() async {
    if (state.usernameInput.valid) {
      emit(state.copyWith(
        submissionStatus: LoginFormSubmissionInProgress(),
      ));

      final successOrFailure = await _authenticationRepository.logIn(
        username: state.usernameInput.value,
      );

      successOrFailure.fold(
        (failure) {
          emit(state.copyWith(
            submissionStatus: LoginFormSubmissionNetworkFailure(
              submissionTime: DateTime.now(),
            ),
          ));
        },
        (_) {
          emit(state.copyWith(
            submissionStatus: LoginFormSubmissionSuccess(),
          ));
        },
      );
    } else {
      emit(state.copyWith(
        submissionStatus: LoginFormSubmissionValidationFailure(
          submissionTime: DateTime.now(),
          validationError: state.usernameInput.error!,
        ),
      ));
    }
  }
}
