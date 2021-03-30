import 'package:equatable/equatable.dart';

class User extends Equatable {
  User({
    required this.username,
  }) : assert(username.isNotEmpty);

  final String username;

  @override
  List<Object?> get props {
    return [
      username,
    ];
  }
}
