part of 'rooms_page_cubit.dart';

class RoomsPageState extends Equatable {
  const RoomsPageState({
    required this.outdatableRoomsWithLastMessages,
    required this.serverConnectionStatus,
  });

  final OutdatableRoomsWithLastMessages outdatableRoomsWithLastMessages;
  final ServerConnectionStatus serverConnectionStatus;

  @override
  List<Object?> get props {
    return [
      outdatableRoomsWithLastMessages,
      serverConnectionStatus,
    ];
  }

  RoomsPageState copyWith({
    OutdatableRoomsWithLastMessages? outdatableRoomsWithLastMessages,
    ServerConnectionStatus? serverConnectionStatus,
  }) {
    return RoomsPageState(
      outdatableRoomsWithLastMessages:
          outdatableRoomsWithLastMessages ?? this.outdatableRoomsWithLastMessages,
      serverConnectionStatus: serverConnectionStatus ?? this.serverConnectionStatus,
    );
  }
}
