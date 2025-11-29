import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rive/rive.dart';
import 'package:my_word_game/utils/game/widgets/word_panel.dart';

class InstructionsScaffold extends StatefulWidget {
  const InstructionsScaffold({super.key});

  @override
  InstructionsScaffoldState createState() => InstructionsScaffoldState();
}

class InstructionsScaffoldState extends State<InstructionsScaffold> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation("Animation 1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CupertinoNavigationBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left, color: Colors.black),
        ),
        middle: Text(
          'Instructions',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Stack(
        fit: StackFit.passthrough,
        children: [
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Hold down the letters to form a pattern:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    color: Colors.grey.shade200,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: RiveAnimation.asset(
                        'assets/play.riv',
                        fit: BoxFit.fitWidth,
                        animations: ['Animation 1'],
                        controllers: [_controller],
                      ),
                    ),
                  ),
                  Text(
                    'The word you form will appear in a box:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          WordPanel(["PLAY"], [""]),
        ],
      ),
    );
  }
}
