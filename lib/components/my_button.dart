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
