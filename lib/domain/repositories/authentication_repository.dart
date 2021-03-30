import 'package:dartz/dartz.dart';
import 'package:tada_messenger/domain/entities/user.dart';
import 'package:tada_messenger/error/failures.dart';

abstract class AuthenticationRepository {
  Stream<User?> get user;

  Future<Either<Failure, void>> logIn({
    required String username,
  });

  Future<void> logOut();
}
