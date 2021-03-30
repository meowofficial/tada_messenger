import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/room.dart';

class RoomModel extends Equatable {
  RoomModel({
    required this.name,
  }) : assert(name.isNotEmpty);

  final String name;

  @override
  List<Object?> get props {
    return [
      name,
    ];
  }

  @override
  String toString() {
    return name;
  }

  factory RoomModel.fromString(String string) {
    return RoomModel(
      name: string,
    );
  }

  Room toRoomEntity() {
    return Room(
      name: name,
    );
  }
}
