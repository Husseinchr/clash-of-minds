import 'package:equatable/equatable.dart';

/// History event
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

/// Load match history event
class LoadMatchHistoryEvent extends HistoryEvent {
  final String userId;
  final int limit;

  const LoadMatchHistoryEvent({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object> get props => [userId, limit];
}

/// Load match history detail event
class LoadMatchHistoryDetailEvent extends HistoryEvent {
  final String matchId;
  final String userId;

  const LoadMatchHistoryDetailEvent({
    required this.matchId,
    required this.userId,
  });

  @override
  List<Object> get props => [matchId, userId];
}

/// Refresh history event
class RefreshHistoryEvent extends HistoryEvent {
  final String userId;

  const RefreshHistoryEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
