import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class CirclesPainter extends CustomPainter {
  final BuildContext context;
  final List<Offset> circlePositions;
  final List<List<String>> words;
  final int unlockedNumbers;
  final int begin;

  CirclesPainter(
    this.context,
    this.circlePositions,
    this.words, {
    required this.unlockedNumbers,
    this.begin = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final touchyCanvas = TouchyCanvas(context, canvas);

    final Paint unlockedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint lockedPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < circlePositions.length; i++) {
      final Offset pos = Offset(
        circlePositions[i].dx * size.width,
        circlePositions[i].dy * size.height,
      );

      final bool isUnlocked = (i + begin) < unlockedNumbers;
      final Paint paint = isUnlocked ? unlockedPaint : lockedPaint;

      touchyCanvas.drawCircle(
        pos,
        30,
        paint,
        onTapDown: isUnlocked
            ? (_) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Level ${i + begin + 1}"),
                    content: Text("Từ khóa: ${words[i].join(', ')}"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Đóng"),
                      ),
                    ],
                  ),
                );
              }
            : null,
      );

      final textSpan = TextSpan(text: "${i + begin + 1}", style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
