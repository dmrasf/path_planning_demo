import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_planning/pages/map_show.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/my_painter.dart';
import 'dart:convert';

class ChooseMap extends StatelessWidget {
  final String _algorithmName;
  ChooseMap(this._algorithmName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Map'),
        centerTitle: true,
      ),
      body: Container(
        child: LayoutBuilder(
          builder: (context, constraints) => GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 320 + 1,
            ),
            children: List.generate(
              mapData.length,
              (i) => MapItem(mapData[i], _algorithmName),
            ),
          ),
        ),
      ),
    );
  }
}

class MapItem extends StatefulWidget {
  final String _mapName;
  final String _algorithmName;
  MapItem(this._mapName, this._algorithmName);
  @override
  _MapItemState createState() => _MapItemState();
}

class _MapItemState extends State<MapItem> {
  String mapData = '';
  Map<String, dynamic> myMap;
  String mapName = '';

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget._mapName).then((value) {
      if (value.isNotEmpty)
        setState(() {
          mapData = value;
          myMap = jsonDecode(mapData);
          mapName = myMap['name'];
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => mapData.isEmpty
          ? null
          : fadeChangePage(context, MapShow(widget._algorithmName, mapData)),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.25),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: PainteSimple(myMap),
              size: MediaQuery.of(context).size,
            ),
          ],
        ),
      ),
    );
  }
}

class PainteSimple extends MapPainter {
  PainteSimple(
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
