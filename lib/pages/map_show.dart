import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/controll_and_show_map_a.dart';
import 'package:path_planning/components/controll_and_show_map_ant.dart';

class MapShow extends StatelessWidget {
  final String _algorithmName;
  final String _fileName;
  MapShow(this._algorithmName, this._fileName);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_algorithmName),
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
                      _algorithmName == 'A*'
                          ? 'H: to end\nG: to point'
                          : 'a: \nb: \np: ',
                      style: GoogleFonts.lato(
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
      body: _algorithmName == 'A*'
          ? ControllAndShowMapForA(_fileName)
          : ControllAndShowMapForAnt(_fileName),
    );
  }
}
