import 'package:flutter/material.dart';

class FloatingText extends StatefulWidget {
  final String text;
  final Offset position;
  final Color color;

  const FloatingText({
    super.key,
    required this.text,
    required this.position,
    required this.color,
  });

  @override
  State<FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: SlideTransition(
        position: _animation,
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
