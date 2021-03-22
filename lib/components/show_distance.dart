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
      child: Text(
        _text + ' m ' + _icon,
        style: GoogleFonts.syncopate(
          textStyle: TextStyle(
            fontSize: 23,
            color: _color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void update(String newString) {
    setState(() {
      if (num.parse(_text) > num.parse(newString)) {
        _color = Colors.green;
        _icon = '';
      } else if (num.parse(_text) < num.parse(newString)) {
        _color = Colors.red;
        _icon = '';
      } else {
        _color = Colors.black;
        _icon = '';
      }
      _text = newString;
    });
  }
}
