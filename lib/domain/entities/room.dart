import 'package:equatable/equatable.dart';

class Room extends Equatable {
  Room({
    required this.name,
  }) : assert(name.isNotEmpty);

  final String name;

  @override
  List<Object?> get props {
    return [
      name,
    ];
  }
}
