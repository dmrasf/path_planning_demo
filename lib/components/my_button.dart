import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final Function _press;
  final String _buttonText;
  MyButton(this._press, this._buttonText);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _press,
      child: Text(
        _buttonText,
        style: GoogleFonts.fredokaOne(
          textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w100),
        ),
      ),
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(
          width: 2,
          color: Color(0x2f000000),
        )),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        minimumSize: MaterialStateProperty.all(Size(110, 50)),
        foregroundColor: MaterialStateProperty.all(Color(0xaf000000)),
      ),
    );
  }
}

class MyShowMapButton extends StatelessWidget {
  final Function _press;
  final String _buttonText;
  MyShowMapButton(this._press, this._buttonText);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _press,
      child: Text(_buttonText),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
        minimumSize: MaterialStateProperty.all(Size(200, 60)),
        foregroundColor:
            MaterialStateProperty.all(Colors.black.withOpacity(0.6)),
        side: MaterialStateProperty.all(BorderSide(
          color: Theme.of(context).textTheme.headline1.color.withOpacity(0.8),
          width: 2,
        )),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.jua(
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
