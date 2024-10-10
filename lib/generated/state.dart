import '../main.dart';

class MinefieldState {
  final Minefield minefield;
  final bool lose;
  final bool win;

  MinefieldState({
    required this.minefield,
    this.lose = false,
    this.win = false,
  });

  MinefieldState copyWith({
    Minefield? minefield,
    bool? lose,
    bool? win,
  }) {
    return MinefieldState(
      minefield: minefield ?? this.minefield,
      lose: lose ?? this.lose,
      win: win ?? this.win,
    );
  }
}