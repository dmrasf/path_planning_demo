import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowPathDistance extends StatefulWidget {
  ShowPathDistance({Key key}) : super(key: key);

  @override
  ShowPathDistanceState createState() => ShowPathDistanceState();
}

class ShowPathDistanceState extends State<ShowPathDistance> {
  String _text = '0.00';
  Color _color = Colors.black;
  String _icon = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: RichText(
        text: TextSpan(
          text: _text + ' m ',
          style: GoogleFonts.jua(
            textStyle: TextStyle(
              fontSize: 25,
              color: _color,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: <TextSpan>[
            TextSpan(
              text: _icon,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void update(String newString) {
    setState(() {
      if (num.parse(_text) > num.parse(newString)) {
        _color = Colors.green;
        _icon =
            ' ' + (num.parse(_text) - num.parse(newString)).toStringAsFixed(1);
      } else if (num.parse(_text) < num.parse(newString)) {
        _color = Colors.red;
        _icon =
            ' ' + (num.parse(newString) - num.parse(_text)).toStringAsFixed(1);
      } else {
        _color = Colors.black;
        _icon = '';
      }
      _text = newString;
    });
  }
}
