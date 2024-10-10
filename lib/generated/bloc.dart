import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/generated/state.dart';

import '../main.dart';
import 'event.dart';

class MinefieldBloc extends Bloc<MinefieldEvent, MinefieldState> {
  MinefieldBloc() : super(MinefieldState(minefield: Minefield(9, 9, 10))) {
    on<InitializeGame>(_onInitializeGame);
    on<RevealCell>(_onRevealCell);
    on<ToggleFlag>(_onToggleFlag);
  }

  void _onInitializeGame(InitializeGame event, Emitter<MinefieldState> emit) {
    emit(MinefieldState(minefield: Minefield(9, 9, 10)));
  }

  void _onRevealCell(RevealCell event, Emitter<MinefieldState> emit) {
    final currentState = state;
    if (currentState.win || currentState.lose) return;

    final minefield = currentState.minefield;
    final cell = minefield.grid[event.row][event.col];

    if (cell.isFlagged) return;

    if (cell.isMine) {
      cell.isExploded = true;
      _revealAllMines(minefield);
      emit(currentState.copyWith(lose: true));
    } else {
      _revealCell(minefield, event.row, event.col);
      emit(currentState.copyWith(minefield: minefield));

      if (_checkWin(minefield)) {
        emit(currentState.copyWith(win: true));
      }
    }
  }

  void _onToggleFlag(ToggleFlag event, Emitter<MinefieldState> emit) {
    final currentState = state;
    if (currentState.win || currentState.lose) return;

    final minefield = currentState.minefield;
    final cell = minefield.grid[event.row][event.col];

    if (cell.isRevealed) return;

    if (cell.isFlagged) {
      cell.isFlagged = false;
      cell.isQuestion = true;
    } else if (cell.isQuestion) {
      cell.isQuestion = false;
    } else {
      cell.isFlagged = true;
    }

    emit(currentState.copyWith(minefield: minefield));

    if (_checkWin(minefield)) {
      emit(currentState.copyWith(win: true));
    }
  }

  void _revealCell(Minefield minefield, int row, int col) {
    final cell = minefield.grid[row][col];
    if (cell.isRevealed || cell.isFlagged) return;

    cell.isRevealed = true;

    if (cell.neighborMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final newRow = row + dr;
          final newCol = col + dc;
          if (minefield.isValid(newRow, newCol)) {
            _revealCell(minefield, newRow, newCol);
          }
        }
      }
    }
  }

  void _revealAllMines(Minefield minefield) {
    for (var row in minefield.grid) {
      for (var cell in row) {
        if (cell.isMine) {
          cell.isRevealed = true;
        }
      }
    }
  }

  bool _checkWin(Minefield minefield) {
    for (var row in minefield.grid) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          return false;
        }
      }
    }
    return true;
  }
}