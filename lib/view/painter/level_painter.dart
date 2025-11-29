import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_word_game/pages/game.dart';
import 'dart:ui' as ui;
import 'package:touchable/touchable.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// Map1Painter: vẽ đường chính cho map1 và gọi CirclesPainter để vẽ các điểm tương tác.
/// LƯU Ý: `context` được truyền từ CanvasTouchDetector.builder (context của touch canvas).
class Map1Painter extends CustomPainter {
  final BuildContext context;
  final List<Offset> circlePosition;
  final List<List<String>> words;
  final int unlockedNumbers;
  final int begin;

  Map1Painter({
    required this.context,
    required this.circlePosition,
    required this.words,
    this.unlockedNumbers = 0,
    this.begin = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // draw path/background stroke
    final Paint shadowPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.2)
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3)
      ..strokeWidth = 20.0;

    final Paint mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.colorBurn
      ..strokeWidth = 33.0;

    mainPaint.shader = ui.Gradient.linear(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      [const Color(0xffd2a500), const Color(0xFFFFFFFF)],
    );

    final Path path = Path();
    path.moveTo(0, size.height * 0.91);

    path.quadraticBezierTo(
      size.width * 0.43,
      size.height * 0.89,
      size.width * 0.61,
      size.height * 0.83,
    );

    path.cubicTo(
      size.width * 0.76,
      size.height * 0.77,
      size.width * 0.86,
      size.height * 0.71,
      size.width * 0.75,
      size.height * 0.66,
    );

    path.cubicTo(
      size.width * 0.55,
      size.height * 0.58,
      size.width * 0.30,
      size.height * 0.74,
      size.width * 0.25,
      size.height * 0.61,
    );

    path.cubicTo(
      size.width * 0.21,
      size.height * 0.48,
      size.width * 0.81,
      size.height * 0.54,
      size.width * 0.81,
      size.height * 0.44,
    );
    path.cubicTo(
      size.width * 0.80,
      size.height * 0.31,
      size.width * 0.29,
      size.height * 0.40,
      size.width * 0.28,
      size.height * 0.31,
    );

    path.quadraticBezierTo(
      size.width * 0.29,
      size.height * 0.19,
      size.width,
      size.height * 0.16,
    );

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, mainPaint);

    // vẽ các vòng tròn bằng CirclesPainter (sử dụng cùng canvas)
    final circlesPainter = CirclesPainter(
      context: context,
      values: circlePosition,
      words: words,
      unlockedNumbers: unlockedNumbers,
      begin: begin,
    );

    circlesPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant Map1Painter oldDelegate) {
    return oldDelegate.unlockedNumbers != unlockedNumbers ||
        !listEquals(oldDelegate.circlePosition, circlePosition) ||
        !listEquals(oldDelegate.words, words) ||
        oldDelegate.begin != begin;
  }
}

/// CirclesPainter: vẽ các điểm (vòng tròn), xử lý tap via TouchyCanvas.
/// Không làm mutate các Paint dùng chung.
class CirclesPainter extends CustomPainter {
  final BuildContext
  context; // context cung cấp bởi CanvasTouchDetector.builder
  final int unlockedNumbers;
  final List<Offset> values;
  final List<List<String>> words;
  final int begin;

  CirclesPainter({
    required this.context,
    required this.values,
    required this.words,
    this.unlockedNumbers = 5,
    this.begin = 0,
  });

  void _paintNumber(Canvas canvas, int number, Offset position) {
    final textSpan = TextSpan(
      text: number.toString(),
      style: TextStyle(
        fontFamily: "Reem Kuffi",
        color: Colors.amber.shade800,
        fontSize: 30,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.darken
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    final Paint basePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white54;

    for (int idx = 0; idx < values.length; idx++) {
      final Offset e = values[idx];
      final bool isUnlocked = unlockedNumbers > idx;
      final double localRadius = isUnlocked ? 28.0 : 12.0;
      final Offset center = Offset(e.dx * size.width, e.dy * size.height);

      // bóng đổ
      canvas.drawCircle(
        Offset(center.dx, center.dy + size.height * 0.01),
        localRadius,
        shadowPaint,
      );

      // vòng chính
      canvas.drawCircle(center, localRadius, basePaint);

      if (isUnlocked) {
        // dùng TouchyCanvas để detect tap. LƯU Ý: tạo Paint tạm để tránh mutate basePaint.
        final myCanvas = TouchyCanvas(context, canvas);

        final Paint tappablePaint = Paint()
          ..color = Colors.white70
          ..style = PaintingStyle.fill;

        myCanvas.drawCircle(
          center,
          localRadius - 5,
          tappablePaint,
          onTapDown: (details) {
            // Điều hướng khi chạm: dùng context (được truyền từ CanvasTouchDetector.builder)
            // Level index = idx + 1 + begin
            final int level = idx + 1 + begin;
            // Bảo đảm index hợp lệ khi truy cập words
            final int wordListIndex = idx;
            if (wordListIndex >= 0 && wordListIndex < words.length) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Level1(words[wordListIndex], level),
                ),
              );
            }
          },
        );

        // overlay vòng và số
        for (int i = 1; i < 3; i++) {
          canvas.drawCircle(
            center,
            localRadius - i * localRadius / 3,
            basePaint,
          );
        }

        _paintNumber(
          canvas,
          idx + 1 + begin,
          Offset(center.dx - localRadius / 3, center.dy - localRadius / 1.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) {
    return oldDelegate.unlockedNumbers != unlockedNumbers ||
        !listEquals(oldDelegate.values, values) ||
        !listEquals(oldDelegate.words, words) ||
        oldDelegate.begin != begin;
  }

  @override
  bool shouldRebuildSemantics(CirclesPainter oldDelegate) => false;
}

/// Map2Painter: vẽ đường map 2 và gọi CirclesPainter
class Map2Painter extends CustomPainter {
  final BuildContext context;
  final List<Offset> circlePosition;
  final List<List<String>> words;
  final int unlockedNumbers;
  final int begin;

  Map2Painter({
    required this.context,
    required this.circlePosition,
    required this.words,
    this.unlockedNumbers = 0,
    this.begin = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.2)
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3)
      ..strokeWidth = 20.0;

    final Paint mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.colorBurn
      ..strokeWidth = 33.0;

    mainPaint.shader = ui.Gradient.linear(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      [const Color(0xFFFFFFFF), const Color(0xffd2a500)],
    );

    final Path path = Path();

    path.moveTo(0, size.height * 0.16);

    path.quadraticBezierTo(
      size.width * 0.31,
      size.height * 0.12,
      size.width * 0.36,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.24,
      size.width * -0.07,
      size.height * 0.40,
      size.width * 0.19,
      size.height * 0.47,
    );
    path.cubicTo(
      size.width * 0.59,
      size.height * 0.55,
      size.width * -0.02,
      size.height * 0.78,
      size.width * 0.17,
      size.height * 0.78,
    );
    path.cubicTo(
      size.width * 0.27,
      size.height * 0.78,
      size.width * 0.62,
      size.height * 0.80,
      size.width * 0.75,
      size.height * 0.77,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.71,
      size.width * 0.40,
      size.height * 0.65,
      size.width * 0.53,
      size.height * 0.58,
    );
    path.cubicTo(
      size.width * 0.65,
      size.height * 0.52,
      size.width * 0.76,
      size.height * 0.45,
      size.width * 0.83,
      size.height * 0.41,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.35,
      size.width * 0.44,
      size.height * 0.30,
      size.width * 0.56,
      size.height * 0.27,
    );
    path.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.15,
      size.width,
      size.height * 0.14,
    );

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, mainPaint);

    // vẽ điểm
    final circlesPainter = CirclesPainter(
      context: context,
      values: circlePosition,
      words: words,
      unlockedNumbers: unlockedNumbers,
      begin: begin,
    );

    circlesPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant Map2Painter oldDelegate) {
    return oldDelegate.unlockedNumbers != unlockedNumbers ||
        !listEquals(oldDelegate.circlePosition, circlePosition) ||
        !listEquals(oldDelegate.words, words) ||
        oldDelegate.begin != begin;
  }
}
