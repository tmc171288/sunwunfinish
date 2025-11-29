import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_word_game/utils/regular/widgets.dart';

class DecounterWidget extends StatefulWidget {
  final bool pause;
  final Function onEnd;
  final bool win;
  const DecounterWidget({
    super.key,
    required this.onEnd,
    required this.pause,
    this.win = false,
  });
  @override
  // ignore: library_private_types_in_public_api
  _DecounterWidgetState createState() => _DecounterWidgetState();
}

class _DecounterWidgetState extends State<DecounterWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int decounter = 60;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      decounter--;

      setState(() {});

      if (decounter == 0 || widget.win) {
        widget.onEnd();
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WordBackground(
      child: Column(
        children: [
          GoldenText("Time", mfontWeight: FontWeight.w100, mfontSize: 24),
          FancyScoreText(
            "$decounter",
            color: decounter < 10 ? Colors.red : Colors.black,
          ),
        ],
      ),
    );
  }
}
