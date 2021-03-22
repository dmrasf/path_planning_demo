import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowPathDistance extends StatefulWidget {
  ShowPathDistance({Key key}) : super(key: key);

  @override
  ShowPathDistanceState createState() => ShowPathDistanceState();
}

class ShowPathDistanceState extends State<ShowPathDistance> {
  String _text = '0.00 m';
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _text,
        style: GoogleFonts.syncopate(
          textStyle: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void update(String newString) {
    setState(() {
      _text = newString + ' m';
    });
  }
}
