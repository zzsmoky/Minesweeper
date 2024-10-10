abstract class MinefieldEvent {}

class InitializeGame extends MinefieldEvent {}

class RevealCell extends MinefieldEvent {
  final int row;
  final int col;

  RevealCell(this.row, this.col);
}

class ToggleFlag extends MinefieldEvent {
  final int row;
  final int col;

  ToggleFlag(this.row, this.col);
}