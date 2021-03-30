import 'package:equatable/equatable.dart';
import 'package:tada_messenger/domain/entities/message.dart';

class SentMessageInfo extends Equatable {
  const SentMessageInfo({
    required this.message,
    required this.lastSendingTime,
  });

  final Message message;
  final DateTime lastSendingTime;

  @override
  List<Object?> get props {
    return [
      message,
      lastSendingTime,
    ];
  }

  SentMessageInfo copyWith({
    Message? message,
    DateTime? lastSendingTime,
  }) {
    return SentMessageInfo(
      message: message ?? this.message,
      lastSendingTime: lastSendingTime ?? this.lastSendingTime,
    );
  }
}
