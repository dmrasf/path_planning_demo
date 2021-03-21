import 'package:flutter/material.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/pages/map_show.dart';
import 'package:path_planning/components/my_button.dart';

class AlgorithmShow extends StatefulWidget {
  final String algorithmName;
  AlgorithmShow(this.algorithmName);
  @override
  _AlgorithmShowState createState() => _AlgorithmShowState();
}

class _AlgorithmShowState extends State<AlgorithmShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.algorithmName),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyShowMapButton(
              () => pickFile('json').then(
                (fileName) {
                  if (fileName != null && fileName != '')
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MapShow(widget.algorithmName, fileName),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                FadeTransition(
                          opacity: animation.drive(
                            Tween(begin: 0.0, end: 1.0).chain(
                              CurveTween(curve: Curves.ease),
                            ),
                          ),
                          child: child,
                        ),
                      ),
                    );
                },
              ),
              'Pick map file',
            ),
            SizedBox(height: 30),
            MyShowMapButton(() {}, 'Create map file'),
          ],
        ),
      ),
      //body: showMap(),
    );
  }
}
