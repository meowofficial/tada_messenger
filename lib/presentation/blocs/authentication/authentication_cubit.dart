import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/authentication_status.dart';
import 'package:tada_messenger/domain/entities/user.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required AuthenticationRepository authenticationRepository,
  })   : _authenticationRepository = authenticationRepository,
        super(AuthenticationState.unknown()) {
    _userSubscription = authenticationRepository.user.listen((user) {
      _changeAuthenticationUser(user);
    });
  }

  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<User?> _userSubscription;

  void _changeAuthenticationUser(User? user) {
    if (user == null) {
      emit(AuthenticationState.unauthenticated());
    } else {
      emit(AuthenticationState.authenticated(
        user: user,
      ));
    }
  }

  void requestAuthenticationLogout() {
    _authenticationRepository.logOut();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
