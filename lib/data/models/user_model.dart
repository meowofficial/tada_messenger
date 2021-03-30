import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/user.dart';

class UserModel extends Equatable {
  UserModel({
    required this.username,
  }) : assert(username.isNotEmpty);

  final String username;

  @override
  List<Object?> get props {
    return [
      username,
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
    );
  }

  User toUserEntity() {
    return User(
      username: username,
    );
  }
}
