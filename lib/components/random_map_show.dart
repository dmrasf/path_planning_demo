import 'package:flutter/material.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/utils.dart';
import 'dart:convert';
import 'package:path_planning/pages/map_show.dart';

class RandomMapShow extends StatefulWidget {
  final String _algorithmName;
  RandomMapShow(this._algorithmName);
  @override
  _RandomMapShowState createState() => _RandomMapShowState();
}

class _RandomMapShowState extends State<RandomMapShow> {
  Map<String, dynamic> _walls;

  @override
  void initState() {
    super.initState();
    _getNewMap();
  }

  void _getNewMap() {
    _walls = RandomMapGeneration(
      widthBlock: 15,
      heigthBlock: 10,
      blankSize: 0.6,
      wallThickness: 0.1,
      border: 0.4,
    ).randomMapGeneration();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random map'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _getNewMap,
            child: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: _walls.isEmpty
            ? Container()
            : CustomPaint(
                painter: PainteRandomMap(_walls),
                size: MediaQuery.of(context).size,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _walls.isEmpty
            ? null
            : fadeChangePage(
                context,
                MapShow(widget._algorithmName, jsonEncode(_walls)),
              ),
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

class PainteRandomMap extends MapPainter {
  PainteRandomMap(
    _myMap,
  ) : super(_myMap, []);

  @override
  void paint(Canvas canvas, Size size) {
    if (!super.parseData()) return;
    double gridWidth = super.width / super.grid;
    double gridHeigth = super.heigth / super.grid;
    double k = size.width / gridWidth < size.height / gridHeigth
        ? size.width / gridWidth
        : size.height / gridHeigth;
    Paint myPaint = Paint()..color = Colors.black;
    super.drawBarriers(canvas, size, myPaint, k);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
