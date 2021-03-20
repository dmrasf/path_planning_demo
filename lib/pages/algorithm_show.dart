import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/controll_and_show_map_a.dart';
import 'package:path_planning/components/controll_and_show_map_ant.dart';

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
        actions: [
          TextButton(
            onPressed: () async {
              OverlayEntry entry = OverlayEntry(builder: (context) {
                return Positioned(
                  top: 60,
                  right: 3,
                  child: Container(
                    width: 200,
                    height: 250,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'cdsc',
                      style: GoogleFonts.jua(
                        textStyle: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    color: Colors.teal[100].withOpacity(0.8),
                  ),
                );
              });
              Overlay.of(context).insert(entry);
              await Future.delayed(Duration(milliseconds: 2000)).then(
                (value) => entry.remove(),
              );
            },
            child: Icon(Icons.help),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
          ),
        ],
      ),
      body: _fileName == null ? pickFileButton() : showMap(),
      //body: showMap(),
    );
  }

  Widget pickFileButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          _fileName = await pickFile('json');
          if (_fileName != null && _fileName != '') {
            setState(() {});
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

  Widget showMap() {
    if (widget.algorithmName == 'A*')
      return ControllAndShowMapForA(_fileName);
    else
      return ControllAndShowMapForAnt(_fileName);
  }
}
