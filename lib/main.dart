import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/generated/assets.dart';

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
        if (_isValid(newRow, newCol) && grid[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  bool _isValid(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}

// 你的 MineSweeperGame 类
class MineSweeperGame extends StatefulWidget {
  const MineSweeperGame({super.key});

  @override
  _MineSweeperGameState createState() => _MineSweeperGameState();
}

class _MineSweeperGameState extends State<MineSweeperGame> {
  late Minefield minefield;
  bool lose = false;
  bool win = false;

  @override
  void initState() {
    super.initState();
    minefield = Minefield(9, 9, 10); // 设置为9x9网格，10个地雷
  }

  restartGame() {
    setState(() {
      lose = false;
      win = false;
      minefield = Minefield(9, 9, 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              restartGame();
            },
            child: Center(
              child: Image.asset(
                  lose
                      ? Assets.assetsDead
                      : win
                          ? Assets.assetsWin
                          : Assets.assetsSmile,
                  width: 40,
                  height: 40,
                  fit: BoxFit.fill),
            )),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: minefield.cols,
        ),
        itemCount: minefield.rows * minefield.cols,
        itemBuilder: (context, index) {
          int row = index ~/ minefield.cols;
          int col = index % minefield.cols;
          MineCell cell = minefield.grid[row][col];
          return GestureDetector(
            onTap: () => _onCellTap(row, col),
            onDoubleTap: () => _onDoubleTap(row, col),
            child: Container(
                color: cell.isRevealed ? Colors.grey : Colors.blue,
                child: Stack(
                  children: [
                    Container(
                      color: cell.isExploded ? const Color.fromRGBO(255, 0, 0, 1) : Colors.transparent,
                    ),
                    cell.isMine
                        ? Positioned.fill(child: Image.asset(Assets.assetsMineCeil, fit: BoxFit.fill))
                        : cell.neighborMines == 0
                            ? Container()
                            : cell.neighborMines == 1
                                ? Positioned.fill(child: Image.asset(Assets.assetsOpen1, fit: BoxFit.fill))
                                : cell.neighborMines == 2
                                    ? Positioned.fill(child: Image.asset(Assets.assetsOpen2, fit: BoxFit.fill))
                                    : cell.neighborMines == 3
                                        ? Positioned.fill(child: Image.asset(Assets.assetsOpen3, fit: BoxFit.fill))
                                        : cell.neighborMines == 4
                                            ? Positioned.fill(child: Image.asset(Assets.assetsOpen4, fit: BoxFit.fill))
                                            : cell.neighborMines == 5
                                                ? Positioned.fill(
                                                    child: Image.asset(Assets.assetsOpen5, fit: BoxFit.fill))
                                                : cell.neighborMines == 6
                                                    ? Positioned.fill(
                                                        child: Image.asset(Assets.assetsOpen6, fit: BoxFit.fill))
                                                    : cell.neighborMines == 7
                                                        ? Positioned.fill(
                                                            child: Image.asset(Assets.assetsOpen7, fit: BoxFit.fill))
                                                        : cell.neighborMines == 8
                                                            ? Positioned.fill(
                                                                child:
                                                                    Image.asset(Assets.assetsOpen8, fit: BoxFit.fill))
                                                            : Container(),
                    backGround(cell.isRevealed, cell.isExploded),
                    Positioned.fill(
                        child: cell.isRevealed
                            ? Container()
                            : cell.isFlagged
                                ? Image.asset(Assets.assetsFlag, fit: BoxFit.fill)
                                : cell.isQuestion
                                    ? Image.asset(Assets.assetsQuestion, fit: BoxFit.fill)
                                    : Container()),
                  ],
                )),
          );
        },
      ),
    );
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

  void _onCellTap(int row, int col) {
    if (win) return;
    if (!lose) {
      MineCell cell = minefield.grid[row][col];
      var isFlagged = cell.isFlagged;
      setState(() {
        if (isFlagged) return;
        if (cell.isMine) {
          // 如果点击的是地雷，显示所有地雷
          HapticFeedback.vibrate(); // 轻微震动
          cell.isExploded = true;
          _revealAllMines();
          lose = true;
        } else {
          // 如果点击的是空格，显示数字
          _revealCell(row, col);
        }
      });
    }
  }

  void _onDoubleTap(int row, int col) {
    if (win) return;
    if (!lose) {
      var isFlagged = minefield.grid[row][col].isFlagged;
      var isQuestion = minefield.grid[row][col].isQuestion;
      setState(() {
        if (isFlagged) {
          minefield.grid[row][col].isFlagged = false;
          minefield.grid[row][col].isQuestion = true;
        } else {
          if (isQuestion) {
            minefield.grid[row][col].isFlagged = false;
            minefield.grid[row][col].isQuestion = false;
          } else {
            minefield.grid[row][col].isFlagged = true;
            //check win
            var mines = 0;
            for (int r = 0; r < minefield.rows; r++) {
              for (int c = 0; c < minefield.cols; c++) {
                var mine = minefield.grid[r][c];
                if (mine.isFlagged && mine.isMine) {
                  mines++;
                }
              }
            }
            if (mines == minefield.mineCount) {
              win = true;
            }
          }
        }
      });
    }
  }

  void _revealCell(int row, int col) {
    MineCell cell = minefield.grid[row][col];
    if (cell.isRevealed) return;

    cell.isRevealed = true;

    if (cell.neighborMines == 0) {
      // 如果邻居地雷数为0，递归揭开周围的空格
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int newRow = row + dr;
          int newCol = col + dc;
          if (minefield._isValid(newRow, newCol)) {
            _revealCell(newRow, newCol);
          }
        }
      }
    }
  }

  void _revealAllMines() {
    for (int r = 0; r < minefield.rows; r++) {
      for (int c = 0; c < minefield.cols; c++) {
        if (minefield.grid[r][c].isMine) {
          minefield.grid[r][c].isRevealed = true;
        }
      }
    }
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
      ..color = const Color.fromRGBO(192, 192, 192, 1)
      ..style = PaintingStyle.fill;

    if (!isRevealed) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
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
