import 'package:equatable/equatable.dart';
import 'package:tada_messenger/presentation/models/validation_error.dart';

abstract class RoomNameValidationError extends ValidationError {
  const RoomNameValidationError();
}

class EmptyRoomNameValidationError extends RoomNameValidationError {
  const EmptyRoomNameValidationError();
}

class RoomNameInput extends Equatable {
  const RoomNameInput([
    this.value = '',
  ]);

  static const maxLength = 50;
  final String value;

  @override
  List<Object?> get props {
    return [
      value,
    ];
  }

  RoomNameValidationError? validator() {
    if (value.isEmpty) {
      return EmptyRoomNameValidationError();
    }
    return null;
  }
}
