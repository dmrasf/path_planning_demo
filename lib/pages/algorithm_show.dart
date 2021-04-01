import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/algorithm_card.dart';

class AlgorithmShow extends StatefulWidget {
  final String mapData;
  AlgorithmShow(this.mapData);
  @override
  _AlgorithmShowState createState() => _AlgorithmShowState();
}

class _AlgorithmShowState extends State<AlgorithmShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Path Planning',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontSize: MediaQuery.of(context).size.height * 0.06,
                ),
              ),
            ),
            Spacer(),
            Container(
              height: MediaQuery.of(context).size.height * 0.37,
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.transparent,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(width: 30),
                  AlgorithmCard('A*', widget.mapData),
                  SizedBox(width: 30),
                  AlgorithmCard('Ant Colony', widget.mapData),
                  SizedBox(width: 30),
                  AlgorithmCard('RRT*', widget.mapData),
                  SizedBox(width: 30),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      //body: showMap(),
    );
  }
}
