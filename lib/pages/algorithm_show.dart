import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text(
          widget.algorithmName,
          style: GoogleFonts.jua(
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
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
                    fadeChangePage(
                      context,
                      MapShow(widget.algorithmName, fileName),
                    );
                },
              ),
              'Pick map file',
            ),
            SizedBox(height: 30),
            MyShowMapButton(
              () => fadeChangePage(context, CreateMap()),
              'Create map file',
            ),
          ],
        ),
      ),
      //body: showMap(),
    );
  }
}

class CreateMap extends StatefulWidget {
  @override
  _CreateMapState createState() => _CreateMapState();
}

class _CreateMapState extends State<CreateMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Map'),
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
