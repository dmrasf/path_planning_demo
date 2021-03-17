import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowPathDistance extends StatefulWidget {
  ShowPathDistance({Key key}) : super(key: key);

  @override
  ShowPathDistanceState createState() => ShowPathDistanceState();
}

class ShowPathDistanceState extends State<ShowPathDistance> {
  String _text = 'Path diatance: null';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        _text,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void update(String newString) {
    setState(() {
      _text = newString;
    });
  }
}
