import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';

/// History state
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

/// Initial state
class HistoryInitial extends HistoryState {}

/// Loading state
class HistoryLoading extends HistoryState {}

/// History loaded state
class HistoryLoaded extends HistoryState {
  final List<MatchHistoryEntity> history;

  const HistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

/// History detail loaded state
class HistoryDetailLoaded extends HistoryState {
  final MatchHistoryEntity matchHistory;

  const HistoryDetailLoaded(this.matchHistory);

  @override
  List<Object> get props => [matchHistory];
}

/// Empty history state
class HistoryEmpty extends HistoryState {}

/// Error state
class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
