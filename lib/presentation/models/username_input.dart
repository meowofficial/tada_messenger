import 'package:formz/formz.dart';
import 'package:tada_messenger/presentation/models/validation_error.dart';

abstract class UsernameValidationError extends ValidationError {
  const UsernameValidationError();
}

class EmptyUsernameValidationError extends UsernameValidationError {
  const EmptyUsernameValidationError();
}

class WrongSymbolUsernameValidationError extends UsernameValidationError {
  const WrongSymbolUsernameValidationError();
}

class UsernameInput extends FormzInput<String, UsernameValidationError> {
  const UsernameInput.pure() : super.pure('');

  const UsernameInput.dirty([String value = '']) : super.dirty(value);

  static const maxLength = 50;

  @override
  UsernameValidationError? validator(String? value) {
    if (value == null || value.isEmpty) {
      return EmptyUsernameValidationError();
    }
    final usernameRegExp = RegExp(r'^[a-zA-Z]+[0-9a-zA-Z]*');
    if (!usernameRegExp.hasMatch(value)) {
      return WrongSymbolUsernameValidationError();
    }
    return null;
  }
}
