import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/pages/algorithm_show.dart';

class AlgorithmCard extends StatefulWidget {
  final String algorithmName;
  AlgorithmCard(this.algorithmName);

  @override
  _AlgorithmCardState createState() => _AlgorithmCardState();
}

class _AlgorithmCardState extends State<AlgorithmCard> {
  double _height;
  double _width;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(this.context).size.height * 0.45;
    _width = MediaQuery.of(this.context).size.width * 0.35;
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AlgorithmShow(widget.algorithmName),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation.drive(
                  Tween(begin: 0.0, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Text(widget.algorithmName),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        minimumSize: MaterialStateProperty.all(Size(_width, _height)),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.buda(
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(Color(0x0f000000)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        side: MaterialStateProperty.all(BorderSide(
          width: 3,
          color: Colors.black,
        )),
      ),
    );
  }
}
