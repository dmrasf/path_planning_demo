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
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      widget.algorithmName == 'A*'
                          ? 'H: to end\nG: to point'
                          : 'a: \nb: \np: ',
                      style: GoogleFonts.jua(
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    ),
                  ),
                );
              });
              Overlay.of(context).insert(entry);
              await Future.delayed(Duration(milliseconds: 300)).then(
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
