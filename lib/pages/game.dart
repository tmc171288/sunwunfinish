import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_word_game/utils/game/constants.dart';
import 'package:my_word_game/utils/game/game_layout.dart';
import 'package:my_word_game/utils/game/widgets/word_grid.dart';
import 'package:my_word_game/utils/game/widgets/word_panel.dart';
import 'package:my_word_game/utils/game/widgets/floating_text.dart';

class Level1 extends StatefulWidget {
  final List<String> words;
  final int chosenLevel;

  const Level1(this.words, this.chosenLevel, {super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> {
  final List<String> all = [
    "APPLE",
    "BANANA",
    "ORANGE",
    "GRAPE",
    "PEACH",
    "MANGO",
    "LEMON",
    "PEAR",
    "BLUE",
    "RED",
    "GREEN",
    "WHITE",
    "BLACK",
    "PINK",
    "PURPLE",
    "YELLOW",
  ];

  late List<List<String>> grid;
  late List<String> flatGrid;
  late List<String> remainingWords;

  List<String> essentialWords = [];
  List<String> bonusWords = [];
  int score = 0;

  @override
  void initState() {
    super.initState();
    remainingWords = List<String>.from(
      widget.words,
    ); // tránh sửa trực tiếp final
    grid = _generateGrid(remainingWords, sizeGrid);
    flatGrid = grid.expand((row) => row).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameLayout(
            chosenLevel: widget.chosenLevel,
            win: remainingWords.isEmpty,
            wordsNotFound: remainingWords,
            score: score,
            wordsFound: [...essentialWords, ...bonusWords],
            wordGrid: WordGrid(
              wordsgrid: flatGrid,
              onPanEnd: (indexes, position) =>
                  _handleWordFound(indexes, position),
              onPanStart: (_) {},
            ),
          ),
          WordPanel(essentialWords, bonusWords),
        ],
      ),
    );
  }

  void _handleWordFound(List<int> indexes, Offset position) {
    if (indexes.isEmpty) return;

    // kiểm tra index hợp lệ tránh RangeError
    if (indexes.any((i) => i < 0 || i >= flatGrid.length)) {
      return;
    }

    final wordModel = _indexesToWord(indexes);
    final word = wordModel.word;
    final wordScore = wordModel.score;

    if (essentialWords.contains(word) || bonusWords.contains(word)) {
      _showFloatingText("ALREADY\nFOUND", position, Colors.amber.shade400);
    } else if (remainingWords.contains(word)) {
      setState(() {
        essentialWords.add(word);
        score += wordScore;
        remainingWords.remove(word);
      });
      _showFloatingText("WORD\nREVEALED", position, Colors.blue.shade400);
    } else if (all.contains(word)) {
      setState(() {
        bonusWords.add(word);
        score += wordScore;
      });
      _showFloatingText("BONUS\nWORD", position, Colors.red.shade400);
    } else {
      _showFloatingText("NOT A WORD", position, Colors.grey.shade400);
    }
  }

  void _showFloatingText(String text, Offset position, Color color) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) =>
          FloatingText(text: text, position: position, color: color),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  ScoreAndWordModel _indexesToWord(List<int> indexes) {
    String word = "";
    int totalScore = 0;

    for (int i in indexes) {
      // tránh index lỗi
      if (i >= 0 && i < flatGrid.length) {
        final letter = flatGrid[i];
        word += letter;
        totalScore += letterScore[letter] ?? 0;
      }
    }
    return ScoreAndWordModel(totalScore, word);
  }

  List<List<String>> _generateGrid(List<String> words, int size) {
    final grid = List.generate(size, (_) => List.generate(size, (_) => ""));
    final rand = Random();

    for (var word in words) {
      bool placed = false;
      while (!placed) {
        final row = rand.nextInt(size);
        final col = rand.nextInt(size);
        final horizontal = rand.nextBool();

        if (horizontal && col + word.length <= size) {
          if (_canPlaceWord(grid, word, row, col, horizontal)) {
            for (int i = 0; i < word.length; i++) {
              grid[row][col + i] = word[i];
            }
            placed = true;
          }
        } else if (!horizontal && row + word.length <= size) {
          if (_canPlaceWord(grid, word, row, col, horizontal)) {
            for (int i = 0; i < word.length; i++) {
              grid[row + i][col] = word[i];
            }
            placed = true;
          }
        }
      }
    }

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = String.fromCharCode(65 + rand.nextInt(26));
        }
      }
    }

    return grid;
  }

  bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int row,
    int col,
    bool horizontal,
  ) {
    for (int i = 0; i < word.length; i++) {
      final cell = horizontal ? grid[row][col + i] : grid[row + i][col];
      if (cell.isNotEmpty && cell != word[i]) return false;
    }
    return true;
  }
}

class ScoreAndWordModel {
  final int score;
  final String word;
  ScoreAndWordModel(this.score, this.word);
}
