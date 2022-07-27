import 'dart:math';

import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  const TextPage({Key? key}) : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  var bgColors = [
    Colors.teal,
    Colors.blue,
    Colors.amberAccent,
    Colors.redAccent
  ];
  var currentColor;
  var rnd;

  randomBg() {
    rnd = Random().nextInt(bgColors.length);
    setState(() {
      currentColor = bgColors[rnd];
    });
  }

  @override
  void initState() {
    randomBg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: currentColor,
      ),
    );
  }
}
