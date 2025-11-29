import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class RotatedText extends StatelessWidget {
  final Alignment _alignment;
  final Color color;
  final String text;

  const RotatedText(
    this._alignment, {
    super.key,
    this.text = "Word\nRevealed",
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: _alignment,
        child: AnimatedTextKit(
          animatedTexts: [
            //should modify size
            RotateAnimatedText(
              text,
              textStyle: TextStyle(
                backgroundColor: Colors.transparent,
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          isRepeatingAnimation: false,
          repeatForever: false,
        ),
      ),
    );
  }
}
