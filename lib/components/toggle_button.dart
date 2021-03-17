import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final Function _press;
  final bool _isShow;
  ToggleButton(this._press, this._isShow);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: _press,
        child: Icon(_isShow ? Icons.arrow_left : Icons.arrow_right, size: 25),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          minimumSize: MaterialStateProperty.all(Size(0, 0)),
        ),
      ),
    );
  }
}
