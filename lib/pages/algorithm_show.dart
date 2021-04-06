import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/algorithm_card.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/utils.dart';
import 'dart:convert';

class AlgorithmShow extends StatefulWidget {
  final String mapData;
  AlgorithmShow(this.mapData);
  @override
  _AlgorithmShowState createState() => _AlgorithmShowState();
}

class _AlgorithmShowState extends State<AlgorithmShow> {
  bool _isDone = false;
  String _remindStr = '正在计算可视点';
  bool _r = true;
  Map<String, dynamic> _myMap;
  List<dynamic> _visualPoints = [];
  List<dynamic> _visualGraph;

  @override
  void initState() {
    super.initState();
    _getMapAnimation();
  }

  Future<void> _getMapAnimation() async {
    try {
      _myMap = jsonDecode(widget.mapData);
      String visualPointStr = await buildMap(widget.mapData);
      Map<String, dynamic> tmpPoints = jsonDecode(visualPointStr);
      _visualPoints = tmpPoints['visual_points'];
      _visualGraph = tmpPoints['visual_graph'];
      _isDone = true;
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      _remindStr = '解析失败，请重新选择！';
      _r = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: _isDone
          ? Center(
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
                        AlgorithmCard(
                            'A*', _myMap, _visualGraph, _visualPoints),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.07),
                        AlgorithmCard(
                            'Ant Colony', _myMap, _visualGraph, _visualPoints),
                        SizedBox(width: 30),
                        //AlgorithmCard(
                        //'RRT*', _myMap, _visualGraph, _visualPoints),
                        //SizedBox(width: 30),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
            )
          : WaitShow(_remindStr, _r),
      //body: showMap(),
    );
  }
}
