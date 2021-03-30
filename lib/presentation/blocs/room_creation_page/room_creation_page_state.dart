part of 'room_creation_page_cubit.dart';

abstract class NewRoomSubmissionStatus extends Equatable {
  const NewRoomSubmissionStatus();

  @override
  List<Object?> get props => [];
}

class NewRoomNotSubmitted extends NewRoomSubmissionStatus {
  const NewRoomNotSubmitted();
}

class NewRoomSubmissionSuccess extends NewRoomSubmissionStatus {
  const NewRoomSubmissionSuccess();
}

abstract class NewRoomSubmissionFailure extends NewRoomSubmissionStatus {
  const NewRoomSubmissionFailure({
    required this.submissionTime,
  });

  final DateTime submissionTime;

  @override
  List<Object?> get props {
    return [
      submissionTime,
    ];
  }
}

class NewRoomSubmissionExistenceFailure extends NewRoomSubmissionFailure {
  const NewRoomSubmissionExistenceFailure({
    required DateTime submissionTime,
  }) : super(submissionTime: submissionTime);
}

class NewRoomSubmissionValidationFailure extends NewRoomSubmissionFailure {
  const NewRoomSubmissionValidationFailure({
    required this.validationError,
    required DateTime submissionTime,
  }) : super(submissionTime: submissionTime);

  final ValidationError validationError;

  @override
  List<Object?> get props {
    return [
      ...super.props,
      validationError,
    ];
  }
}

class RoomCreationPageState extends Equatable {
  const RoomCreationPageState({
    required this.createdRooms,
    required this.roomNameInput,
    required this.messageInput,
    required this.submissionStatus,
  });

  final Set<Room> createdRooms;
  final RoomNameInput roomNameInput;
  final MessageInput messageInput;
  final NewRoomSubmissionStatus submissionStatus;

  @override
  List<Object?> get props {
    return [
      createdRooms,
      roomNameInput,
      messageInput,
      submissionStatus,
    ];
  }

  RoomCreationPageState copyWith({
    Set<Room>? createdRooms,
    RoomNameInput? roomNameInput,
    MessageInput? messageInput,
    NewRoomSubmissionStatus? submissionStatus,
  }) {
    return RoomCreationPageState(
      createdRooms: createdRooms ?? this.createdRooms,
      roomNameInput: roomNameInput ?? this.roomNameInput,
      messageInput: messageInput ?? this.messageInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}
