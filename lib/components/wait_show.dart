import 'package:flutter/material.dart';

class WaitShow extends StatefulWidget {
  final String _remindStr;
  final bool _r;
  WaitShow(this._remindStr, this._r);
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
    if (!widget._r) _controller.stop();
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
