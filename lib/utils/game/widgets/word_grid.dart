import 'package:flutter/material.dart';
import 'package:my_word_game/utils/game/constants.dart';
import 'package:my_word_game/utils/game/widgets/animated_word.dart';

import 'multi_select_grid.dart';

class WordGrid extends StatelessWidget {
  final List<String> wordsgrid;
  final PanEnd onPanEnd;
  final PanStart onPanStart;
  const WordGrid({
    super.key,
    required this.wordsgrid,
    required this.onPanEnd,
    required this.onPanStart,
  });
  @override
  Widget build(BuildContext context) {
    return MultiSelectGridView(
      itemCount: sizeGrid * sizeGrid,
      itemBuilder: (context, index, selected) {
        return AnimatedWord(
          letterScore: letterScore[wordsgrid[index]] ?? 0,
          fontSize: 33 - 33 * sizeGrid / 20,
          index: index,
          selected: selected,
          mText: wordsgrid[index],
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1,
        crossAxisCount: sizeGrid,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      onPanEnd: onPanEnd,
      onPanStart: onPanStart,
      onPanUpdate: (DragUpdateDetails details) {},
    );
  }
}
