import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/pages/map_show.dart';
import 'package:path_planning/utils.dart';

class AlgorithmCard extends StatefulWidget {
  final String algorithmName;
  final String mapData;
  AlgorithmCard(this.algorithmName, this.mapData);

  @override
  _AlgorithmCardState createState() => _AlgorithmCardState();
}

class _AlgorithmCardState extends State<AlgorithmCard> {
  double _height;
  double _width;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(this.context).size.height * 0.30;
    _width = _height / 0.618;
    return TextButton(
      onPressed: () => fadeChangePage(
        context,
        MapShow(widget.algorithmName, widget.mapData),
      ),
      child: Text(widget.algorithmName),
      style: ButtonStyle(
        animationDuration: Duration(milliseconds: 200),
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        minimumSize: MaterialStateProperty.all(Size(_width, _height)),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.buda(
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(Color(0x3f000000)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        side: MaterialStateProperty.all(BorderSide.none),
      ),
    );
  }
}
