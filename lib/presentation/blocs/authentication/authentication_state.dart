part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState.authenticated({
    required this.user,
  }) : authenticationStatus = AuthenticationStatus.authenticated;

  const AuthenticationState.unauthenticated()
      : user = null,
        authenticationStatus = AuthenticationStatus.unauthenticated;

  const AuthenticationState.unknown()
      : user = null,
        authenticationStatus = AuthenticationStatus.unknown;

  final User? user;
  final AuthenticationStatus authenticationStatus;

  @override
  List<Object?> get props {
    return [
      authenticationStatus,
      user,
    ];
  }
}
