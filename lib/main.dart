import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/generated/assets.dart';
import 'package:minesweeper/generated/event.dart';

import 'generated/bloc.dart';
import 'generated/state.dart';

// main 函数
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: MineSweeperGame(),
  ));
}

class MineCell {
  bool isMine;
  bool isRevealed;
  int neighborMines;
  bool isFlagged;
  bool isQuestion;
  bool isExploded;

  MineCell({
    this.isMine = false,
    this.isRevealed = false,
    this.neighborMines = 0,
    this.isQuestion = false,
    this.isFlagged = false,
    this.isExploded = false,
  });
}

class Minefield {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<MineCell>> grid;

  Minefield(this.rows, this.cols, this.mineCount) {
    grid = List.generate(rows, (r) => List.generate(cols, (c) => MineCell()));
    _placeMines();
    _calculateNumbers();
  }

  void _placeMines() {
    int placedMines = 0;
    Random random = Random();

    while (placedMines < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);

      if (!grid[row][col].isMine) {
        grid[row][col].isMine = true;
        placedMines++;
      }
    }
  }

  void _calculateNumbers() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!grid[r][c].isMine) {
          int count = _countMinesAround(r, c);
          grid[r][c].neighborMines = count;
        }
      }
    }
  }

  int _countMinesAround(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int newRow = row + dr;
        int newCol = col + dc;
        if (isValid(newRow, newCol) && grid[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  bool isValid(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}

// 你的 MineSweeperGame 类
class MineSweeperGame extends StatelessWidget {
  const MineSweeperGame({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MinefieldBloc(),
      child: const MineSweeperView(),
    );
  }
}

class MineSweeperView extends StatelessWidget {
  const MineSweeperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: BlocBuilder<MinefieldBloc, MinefieldState>(
                builder: (context, state) => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      context.read<MinefieldBloc>().add(InitializeGame());
                    },
                    child: Center(
                        child: Image.asset(
                      state.win
                          ? Assets.assetsWin
                          : state.lose
                              ? Assets.assetsDead
                              : Assets.assetsSmile,
                      width: 40,
                      height: 40,
                      fit: BoxFit.fill,
                    ))))),
        body: BlocBuilder<MinefieldBloc, MinefieldState>(builder: (context, state) {
          final minefield = state.minefield;
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: minefield.cols),
              itemCount: minefield.rows * minefield.cols,
              itemBuilder: (context, index) {
                int row = index ~/ minefield.cols;
                int col = index % minefield.cols;
                MineCell cell = minefield.grid[row][col];
                return GestureDetector(
                    onTap: () => context.read<MinefieldBloc>().add(RevealCell(row, col)),
                    onDoubleTap: () {
                      print("double tap");
                      context.read<MinefieldBloc>().add(ToggleFlag(row, col));
                    },
                    child: Stack(
                      children: [
                        Container(color: const Color.fromRGBO(192, 192, 192, 1)),
                        Positioned.fill(child: buildCellContent(cell)),
                        Positioned.fill(child: backGround(cell.isRevealed, cell.isExploded)),
                      ],
                    ));
              });
        }));
  }

  // 根据单元格状态选择显示的组件
  Widget buildCellContent(MineCell cell) {
    if (cell.isRevealed) {
      if (cell.isMine) {
        return Container(
            color: const Color.fromRGBO(255, 0, 0, 1), child: Image.asset(Assets.assetsMineCeil, fit: BoxFit.fill));
      } else if (cell.neighborMines > 0) {
        // 根据邻近地雷数显示对应的图片
        return Image.asset(
          'assets/open${cell.neighborMines}.png',
          fit: BoxFit.fill,
        );
      } else {
        return Container(); // 空白
      }
    } else {
      print("isFlagged: ${cell.isFlagged}");
      if (cell.isFlagged) {
        return Image.asset(Assets.assetsFlag, fit: BoxFit.fill);
      } else if (cell.isQuestion) {
        return Image.asset(Assets.assetsQuestion, fit: BoxFit.fill);
      } else {
        return Container(); // 未揭开的方块
      }
    }
  }

  Widget backGround(bool isMine, bool isExploded) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(children: [
        Positioned.fill(
            child: CustomPaint(
          painter: RightAngledTrapezoidPainter(isRevealed: isMine, isExploded: isExploded),
        )),
      ]),
    );
  }
}

class RightAngledTrapezoidPainter extends CustomPainter {
  final bool isRevealed;
  final bool isExploded;

  RightAngledTrapezoidPainter({required this.isRevealed, required this.isExploded});

  @override
  void paint(Canvas canvas, Size size) {
    // cell.isRevealed ? Colors.grey : Colors.blue;

    Paint paint = Paint()
      ..style = PaintingStyle.fill;

    if (!isRevealed) {
      paint.color = const Color.fromRGBO(245, 245, 245, 1);
      drawHideMask(canvas, size, paint);
    } else {
      drawBackground(canvas, size, paint);
    }
  }

  void drawBackground(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color.fromRGBO(128, 128, 128, 1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 2), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, 2, size.height), paint);
  }

  void drawHideMask(Canvas canvas, Size size, Paint paint) {
    final Path path = Path();
    var padding = size.height * 0.1;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - padding, padding);
    path.lineTo(0, padding);
    path.close();
    canvas.drawPath(path, paint);
    path.reset();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(padding, size.height - padding);
    path.lineTo(padding, 0);
    path.close();
    canvas.drawPath(path, paint);
    path.reset();

    paint.color = const Color.fromRGBO(128, 128, 128, 1);
    path.moveTo(padding, size.height - padding);
    path.lineTo(size.width, size.height - padding);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
    path.reset();
    path.moveTo(size.width - padding, padding);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - padding, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 如果不需要频繁重绘，可以保持为false
  }
}
