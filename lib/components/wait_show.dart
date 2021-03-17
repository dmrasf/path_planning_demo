import 'package:flutter/material.dart';

class WaitShow extends StatefulWidget {
  final String _remindStr;
  WaitShow(this._remindStr);
  @override
  _WaitShowState createState() => _WaitShowState();
}

class _WaitShowState extends State<WaitShow>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _controller,
          alignment: Alignment.center,
          child: Container(
            height: 30,
            width: 30,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 20),
        Text(widget._remindStr),
      ],
    );
  }
}
