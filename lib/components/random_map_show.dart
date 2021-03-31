import 'package:flutter/material.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/utils.dart';

class RandomMapShow extends StatefulWidget {
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
      widthBlock: 30,
      heigthBlock: 30,
      blankSize: 0.6,
      wallThickness: 0.1,
      border: 1,
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
        onPressed: () {},
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
