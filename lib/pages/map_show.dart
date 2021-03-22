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
                    width: 200,
                    child: Text(
                      _algorithmName == 'A*'
                          ? 'H: 待选点到终点距离权重\nG: 当前点到待选点距离权重\nf = h + g'
                          : 'a: 信息素权重\nb: 路径长度权重\np: 信息素挥发率(0, 1)',
                      style: GoogleFonts.k2d(
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
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
              await Future.delayed(Duration(milliseconds: 1000)).then(
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
