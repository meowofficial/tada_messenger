import 'package:equatable/equatable.dart';
import 'package:tada_messenger/presentation/models/validation_error.dart';

abstract class MessageValidationError extends ValidationError {
  const MessageValidationError();
}

class EmptyMessageValidationError extends MessageValidationError {
  const EmptyMessageValidationError();
}

class MessageInput extends Equatable {
  const MessageInput([
    this.value = '',
  ]);

  static const maxLength = 10500;
  final String value;

  @override
  List<Object?> get props {
    return [
      value,
    ];
  }

  MessageValidationError? validator() {
    if (value.isEmpty) {
      return EmptyMessageValidationError();
    }
    return null;
  }
}
