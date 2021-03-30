part of 'login_page_cubit.dart';

abstract class LoginFormSubmissionStatus extends Equatable {
  const LoginFormSubmissionStatus();

  @override
  List<Object?> get props => [];
}

abstract class LoginFormSubmissionFailure extends LoginFormSubmissionStatus {
  const LoginFormSubmissionFailure({
    required this.submissionTime,
  });

  final DateTime submissionTime;

  @override
  List<Object?> get props {
    return [
      submissionTime,
    ];
  }
}

class LoginFormSubmissionValidationFailure extends LoginFormSubmissionFailure {
  LoginFormSubmissionValidationFailure({
    required this.validationError,
    required DateTime submissionTime,
  }) : super(submissionTime: submissionTime);

  final ValidationError validationError;

  @override
  List<Object?> get props {
    return [
      ...super.props,
      validationError,
    ];
  }
}

class LoginFormSubmissionNetworkFailure extends LoginFormSubmissionFailure {
  const LoginFormSubmissionNetworkFailure({
    required DateTime submissionTime,
  }) : super(submissionTime: submissionTime);
}

class LoginFormSubmissionInProgress extends LoginFormSubmissionStatus {
  const LoginFormSubmissionInProgress();
}

class LoginFormNotSubmitted extends LoginFormSubmissionStatus {
  const LoginFormNotSubmitted();
}

class LoginFormSubmissionSuccess extends LoginFormSubmissionStatus {
  const LoginFormSubmissionSuccess();
}

class LoginPageState extends Equatable {
  const LoginPageState({
    required this.usernameInput,
    required this.submissionStatus,
  });

  const LoginPageState.initial()
      : usernameInput = const UsernameInput.pure(),
        submissionStatus = const LoginFormNotSubmitted();

  final UsernameInput usernameInput;
  final LoginFormSubmissionStatus submissionStatus;

  @override
  List<Object?> get props {
    return [
      usernameInput,
      submissionStatus,
    ];
  }

  LoginPageState copyWith({
    UsernameInput? usernameInput,
    LoginFormSubmissionStatus? submissionStatus,
    bool? valid,
  }) {
    return LoginPageState(
      usernameInput: usernameInput ?? this.usernameInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}
