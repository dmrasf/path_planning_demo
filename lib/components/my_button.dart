import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final Function _press;
  MyButton(this._press);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _press,
      child: Text(
        'START',
        style: GoogleFonts.fredokaOne(
          textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w100),
        ),
      ),
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(
          width: 2,
          color: Color(0x2f000000),
        )),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 35,
        )),
        foregroundColor: MaterialStateProperty.all(
          Color(0xaf000000),
        ),
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
        minimumSize: MaterialStateProperty.all(Size(170, 50)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        side: MaterialStateProperty.all(BorderSide(
          color: Colors.black.withOpacity(0.4),
          width: 2,
        )),
        shape: MaterialStateProperty.all(StadiumBorder()),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.buda(
            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
