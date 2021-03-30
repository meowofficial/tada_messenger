part of 'room_page_cubit.dart';

abstract class RoomPageState extends Equatable {
  const RoomPageState();

  @override
  List<Object?> get props => [];
}

class RoomPageFoundState extends RoomPageState {
  const RoomPageFoundState({
    required this.outdatableReversedMessageHistory,
    required this.serverConnectionStatus,
    required this.messageInput,
  });

  final RoomOutdatableMessageHistory outdatableReversedMessageHistory;
  final ServerConnectionStatus serverConnectionStatus;
  final MessageInput messageInput;

  @override
  List<Object?> get props {
    return [
      outdatableReversedMessageHistory,
      serverConnectionStatus,
      messageInput,
    ];
  }

  RoomPageFoundState copyWith({
    RoomOutdatableMessageHistory? outdatableReversedMessageHistory,
    ServerConnectionStatus? serverConnectionStatus,
    MessageInput? messageInput,
    bool? submitButtonEnabled,
  }) {
    return RoomPageFoundState(
      outdatableReversedMessageHistory:
          outdatableReversedMessageHistory ?? this.outdatableReversedMessageHistory,
      serverConnectionStatus: serverConnectionStatus ?? this.serverConnectionStatus,
      messageInput: messageInput ?? this.messageInput,
    );
  }
}

class RoomPageNotFoundState extends RoomPageState {
  const RoomPageNotFoundState();
}

enum RoomPageUnknownStatus {
  none,
  checking,
}

class RoomPageUnknownState extends RoomPageState {
  RoomPageUnknownState({
    required this.status,
    required this.serverConnectionStatus,
  });

  final RoomPageUnknownStatus status;
  final ServerConnectionStatus serverConnectionStatus;

  @override
  List<Object?> get props {
    return [
      status,
      serverConnectionStatus,
    ];
  }

  RoomPageUnknownState copyWith({
    RoomPageUnknownStatus? status,
    ServerConnectionStatus? serverConnectionStatus,
  }) {
    return RoomPageUnknownState(
      status: status ?? this.status,
      serverConnectionStatus: serverConnectionStatus ?? this.serverConnectionStatus,
    );
  }
}
