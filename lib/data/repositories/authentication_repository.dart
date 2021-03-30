import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:tada_messenger/data/data_sources/authentication_data_source.dart';
import 'package:tada_messenger/domain/entities/user.dart';
import 'package:tada_messenger/domain/repositories/authentication_repository.dart';
import 'package:tada_messenger/error/failures.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final _controller = StreamController<User?>();

  AuthenticationRepositoryImpl({
    required AuthenticationDataSource authenticationDataSource,
  }) : _authenticationDataSource = authenticationDataSource;

  final AuthenticationDataSource _authenticationDataSource;

  @override
  Stream<User?> get user async* {
    final username = await _authenticationDataSource.getStoredUsername();
    if (username == null) {
      yield null;
    } else {
      yield User(username: username);
    }

    yield* _controller.stream;
  }

  @override
  Future<Either<Failure, void>> logIn({
    required String username,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    _controller.add(User(
      username: username,
    ));
    _authenticationDataSource.storeUsername(username);
    return Right(null);
  }

  @override
  Future<void> logOut() async {
    await Future.delayed(Duration(milliseconds: 300));
    _controller.add(null);
    _authenticationDataSource.removeStoredUsername();
  }

  void dispose() {
    _controller.close();
  }
}
