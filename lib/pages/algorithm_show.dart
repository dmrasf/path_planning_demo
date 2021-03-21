import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/pages/map_show.dart';

class AlgorithmShow extends StatefulWidget {
  final String algorithmName;
  AlgorithmShow(this.algorithmName);
  @override
  _AlgorithmShowState createState() => _AlgorithmShowState();
}

class _AlgorithmShowState extends State<AlgorithmShow> {
  String _fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.algorithmName),
        centerTitle: true,
      ),
      body: pickFileButton(),
      //body: showMap(),
    );
  }

  Widget pickFileButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          _fileName = await pickFile('json');
          if (_fileName != null && _fileName != '') {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MapShow(widget.algorithmName, _fileName),
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
          }
        },
        child: Text('Pick Map File'),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
          minimumSize: MaterialStateProperty.all(Size(170, 50)),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          side: MaterialStateProperty.all(
              BorderSide(color: Colors.black, width: 2)),
          shape: MaterialStateProperty.all(StadiumBorder()),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.buda(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
