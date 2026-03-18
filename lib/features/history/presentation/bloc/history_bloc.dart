import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/history/domain/usecases/get_match_history.dart';
import 'package:clash_of_minds/features/history/domain/usecases/get_match_history_detail.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_event.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_state.dart';

/// History BLoC
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMatchHistory getMatchHistory;
  final GetMatchHistoryDetail getMatchHistoryDetail;

  HistoryBloc({
    required this.getMatchHistory,
    required this.getMatchHistoryDetail,
  }) : super(HistoryInitial()) {
    on<LoadMatchHistoryEvent>(_onLoadHistory);
    on<LoadMatchHistoryDetailEvent>(_onLoadDetail);
    on<RefreshHistoryEvent>(_onRefreshHistory);
  }

  Future<void> _onLoadHistory(
    LoadMatchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final result = await getMatchHistory(
      GetMatchHistoryParams(userId: event.userId, limit: event.limit),
    );

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (history) {
        if (history.isEmpty) {
          emit(HistoryEmpty());
        } else {
          emit(HistoryLoaded(history));
        }
      },
    );
  }

  Future<void> _onLoadDetail(
    LoadMatchHistoryDetailEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final result = await getMatchHistoryDetail(
      GetMatchHistoryDetailParams(
        matchId: event.matchId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (history) => emit(HistoryDetailLoaded(history)),
    );
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await getMatchHistory(
      GetMatchHistoryParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (history) {
        if (history.isEmpty) {
          emit(HistoryEmpty());
        } else {
          emit(HistoryLoaded(history));
        }
      },
    );
  }
}
