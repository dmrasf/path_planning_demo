import 'package:flutter/material.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class ShowMapForA extends StatefulWidget {
  final String fileName;
  ShowMapForA({Key key, this.fileName}) : super(key: key);
  @override
  ShowMapForAState createState() => ShowMapForAState();
}

class ShowMapForAState extends State<ShowMapForA>
    with SingleTickerProviderStateMixin {
  bool _isDone = false;
  Map<String, dynamic> _myMap;
  AnimationController _controller;
  List<dynamic> _visualPoints = [];
  List<dynamic> _visualGraph;
  List<dynamic> _openPoints = [];
  List<double> _openPointsValue = [];
  List<dynamic> _closePoints = [];
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowOp = true;
  String _remindStr = '正在读取地图';
  bool _r = true;
  int _speed = 830;
  int _currentPoint = 0;
  String _state = '';

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 100),
    );
    getMapAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isDone
        ? AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: MapPainterA(
                  _myMap,
                  this._visualPoints,
                  this._openPoints,
                  this._openPointsValue,
                  this._closePoints,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowOp,
                  this._currentPoint,
                  this._state,
                ),
              );
            },
          )
        : WaitShow(_remindStr, _r);
  }

  void getMapAnimation() async {
    try {
      File f = File(widget.fileName);
      String mapStr = await f.readAsString();
      _myMap = jsonDecode(mapStr);
      String visualPointStr = await buildMap(widget.fileName);
      Map<String, dynamic> tmpPoints = jsonDecode(visualPointStr);
      _visualPoints = tmpPoints['visual_points'];
      _visualGraph = tmpPoints['visual_graph'];
      _isDone = true;
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      _remindStr = '读取失败，请重新选择！';
      _r = false;
    }
    setState(() {});
  }

  void changeSpeed(int newSpeed) {
    _speed = newSpeed;
  }

  void run(double hWeight, double gWeight) async {
    if (!_isDone) return;
    _controller.reset();
    _controller.forward();
    _openPoints = [];
    _openPointsValue = [];
    _closePoints = [];
    _pathRoute = [];
    _pathRouteOp = [];
    int start = 0;
    int end = _visualPoints.length - 1;
    List<int> currentPoint = [start, start];
    _closePoints.add(currentPoint);
    while (true) {
      _updateOpenPoints(currentPoint);
      currentPoint = _findNextPoint(currentPoint, hWeight, gWeight);
      _state = 'Update Close Set';
      _currentPoint = currentPoint[0];
      await Future.delayed(Duration(milliseconds: _speed));
      try {
        bool isBreak = false;
        int i = 0;
        for (; i < _openPoints.length; i++)
          if (_openPoints[i][0] == currentPoint[0]) {
            isBreak = true;
            break;
          }
        if (!isBreak) throw UnimplementedError();
        _openPoints.removeAt(i);
      } catch (e) {
        _state = 'Faile, No Path!';
        return;
      }
      if (!_closePoints.contains(currentPoint)) _closePoints.add(currentPoint);
      _state = 'Update Open Set & Find Next Point';
      await Future.delayed(Duration(milliseconds: _speed));
      if (currentPoint[0] == end) break;
    }
    _state = 'Success!';
    _closePoints.remove([start, start]);
    _parsePathRoute();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      'Path distance: ' + _calculatePathDistance().toStringAsFixed(2) + 'm',
    );
    _optimisingPath();
    await Future.delayed(Duration(milliseconds: _speed));
    _controller.stop();
  }

  void _optimisingPath() {
    _pathRoute = _pathRoute.reversed.toList();
    int currentPoint = _pathRoute[0];
    List<int> necessaryPath = [currentPoint];
    int i = 0;
    int tmpi = 0;
    int tmpPoint = 0;
    while (true) {
      tmpi = 0;
      tmpPoint = 0;
      for (int j = i + 1; j < _pathRoute.length; j++)
        if (_visualGraph[currentPoint][_pathRoute[j]] != -1) {
          tmpPoint = _pathRoute[j];
          tmpi = j;
        }
      i = tmpi;
      currentPoint = tmpPoint;
      necessaryPath.add(currentPoint);
      if (necessaryPath[necessaryPath.length - 1] == _visualPoints.length - 1)
        break;
    }
    _pathRouteOp = necessaryPath;
  }

  double _calculatePathDistance() {
    double pathDistance = 0;
    for (int i = 0; i < _pathRoute.length - 1; i++) {
      pathDistance += pow(
          pow(
                  (_visualPoints[_pathRoute[i]][0] -
                          _visualPoints[_pathRoute[i + 1]][0]) *
                      _myMap['grid'],
                  2) +
              pow(
                  (_visualPoints[_pathRoute[i]][1] -
                          _visualPoints[_pathRoute[i + 1]][1]) *
                      _myMap['grid'],
                  2),
          0.5);
    }
    return pathDistance;
  }

  List<int> _findNextPoint(
    List<int> currentPoint,
    double hWeight,
    double gWeight,
  ) {
    _openPointsValue = [];
    double minDistance = double.infinity;
    List<int> bestPoint = [];
    int end = _visualPoints.length - 1;
    double grid = _myMap['grid'];
    for (int i = 0; i < _openPoints.length; i++) {
      List<int> tmpPoints = _openPoints[i];
      double h = pow(
        pow((_visualPoints[end][0] - _visualPoints[tmpPoints[0]][0]) * grid,
                2) +
            pow((_visualPoints[end][1] - _visualPoints[tmpPoints[0]][1]) * grid,
                2),
        0.5,
      );
      double g = pow(
        pow(
              (_visualPoints[currentPoint[0]][0] -
                      _visualPoints[tmpPoints[0]][0]) *
                  grid,
              2,
            ) +
            pow(
              (_visualPoints[currentPoint[0]][1] -
                      _visualPoints[tmpPoints[0]][1]) *
                  grid,
              2,
            ),
        0.5,
      );
      double f = h * hWeight + g * gWeight;
      _openPointsValue.add(f);
      if (f < minDistance) {
        minDistance = f;
        bestPoint.clear();
        bestPoint.add(tmpPoints[0]);
        bestPoint.add(tmpPoints[1]);
      }
    }
    return bestPoint;
  }

  void _updateOpenPoints(List<int> currentPoint) {
    for (int i = 0; i < _visualPoints.length; i++) {
      if (_visualGraph[currentPoint[0]][i] == -1.0) continue;
      bool isBreak = false;
      for (int j = 0; j < _closePoints.length; j++)
        if (i == _closePoints[j][0]) {
          isBreak = true;
          break;
        }
      if (!isBreak) {
        isBreak = false;
        for (int k = 0; k < _openPoints.length; k++)
          if (i == _openPoints[k][0]) {
            isBreak = true;
            break;
          }
        if (!isBreak) _openPoints.add([i, currentPoint[0]]);
      }
    }
  }

  void _parsePathRoute() {
    _pathRoute = [_visualPoints.length - 1];
    int tmpPoint = _visualPoints.length - 1;
    while (true) {
      for (var p in _closePoints) {
        if (p[0] == tmpPoint) {
          _pathRoute.add(p[1]);
          tmpPoint = p[1];
        }
      }
      if (tmpPoint == 0) break;
    }
  }
}

class MapPainterA extends CustomPainter {
  final Map<String, dynamic> _myMap;
  final List<dynamic> _visualPoints;
  final List<dynamic> _closePoints;
  final List<dynamic> _openPoints;
  final List<double> _openPointsValue;
  final List<int> _pathRoute;
  final int _currentPoint;
  final String _state;
  final List<int> _pathRouteOp;
  final bool _isShowOp;
  MapPainterA(
    this._myMap,
    this._visualPoints,
    this._openPoints,
    this._openPointsValue,
    this._closePoints,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowOp,
    this._currentPoint,
    this._state,
  );
  double _width;
  double _heigth;
  double _grid;
  double _robotSize;
  List<dynamic> _barriers;

  @override
  void paint(Canvas canvas, Size size) {
    if (!parseData()) return;
    double gridWidth = _width / _grid;
    double gridHeigth = _heigth / _grid;
    double k = size.width / gridWidth < size.height / gridHeigth
        ? size.width / gridWidth
        : size.height / gridHeigth;

    Paint myPaint = Paint()..color = Colors.black;
    drawBarriers(canvas, size, myPaint, k);
    drawPath(canvas, size, myPaint, k);
    if (_isShowOp) drawPathRouteOp(canvas, size, myPaint, k);
    drawRobot(canvas, size, myPaint, k);
    drawState(canvas, size, myPaint, k);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  bool parseData() {
    try {
      _width = _myMap['width'].toDouble();
      _heigth = _myMap['heigth'].toDouble();
      _grid = _myMap['grid'].toDouble();
      _robotSize = _myMap['robotSize'].toDouble();
      _barriers = _myMap['barriers'];
    } catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  void drawBarriers(Canvas canvas, Size size, Paint myPaint, double k) {
    for (int i = 0; i < _barriers.length; i++) {
      Path path = Path();
      for (int j = 0; j < _barriers[i].length; j++) {
        double y = _barriers[i][j]['pointX'] / _grid * k +
            (size.height - k * (_heigth / _grid)) / 2;
        double x = _barriers[i][j]['pointY'] / _grid * k +
            (size.width - k * (_width / _grid)) / 2;
        if (j == 0)
          path..moveTo(x, y);
        else
          path..lineTo(x, y);
      }
      path..close();
      canvas.drawPath(path, myPaint);
    }
  }

  void drawRobot(Canvas canvas, Size size, Paint myPaint, double k) {
    for (int i = 0; i < _visualPoints.length; i++) {
      if (i == 0 || i == _visualPoints.length - 1)
        myPaint..color = Colors.red;
      else
        myPaint..color = Colors.black;
      canvas.drawCircle(
        Offset(
            _visualPoints[i][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[i][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2),
        _robotSize / (_grid + 0.035) * k,
        myPaint,
      );
    }
    for (int i = 0; i < _openPoints.length; i++) {
      myPaint..color = Colors.yellow;
      Offset offset = Offset(
        _visualPoints[_openPoints[i][0]][1].toDouble() * k +
            (size.width - k * (_width / _grid)) / 2,
        _visualPoints[_openPoints[i][0]][0].toDouble() * k +
            (size.height - k * (_heigth / _grid)) / 2,
      );
      canvas.drawCircle(offset, _robotSize / (_grid + 0.035) * k, myPaint);
      if (_openPointsValue.isNotEmpty) {
        double ma = _openPointsValue.reduce(max);
        double mi = _openPointsValue.reduce(min);
        double fontSize = k * (5 - 3 * (_openPointsValue[i] - mi) / (ma - mi));
        TextSpan span = TextSpan(
          text: _openPointsValue[i].toStringAsFixed(2),
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, offset + Offset(-fontSize, -fontSize * 0.6));
      }
    }
    for (int i = 0; i < _closePoints.length; i++) {
      myPaint..color = Colors.blue;
      canvas.drawCircle(
        Offset(
            _visualPoints[_closePoints[i][0]][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[_closePoints[i][0]][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2),
        _robotSize / (_grid + 0.035) * k,
        myPaint,
      );
    }
  }

  void drawPath(Canvas canvas, Size size, Paint myPaint, double k) {
    if (_pathRoute.isEmpty) return;
    myPaint
      ..color = Colors.orange
      ..strokeWidth = k;
    for (int i = 0; i < _pathRoute.length; i++) {
      Offset p1 = Offset(
          _visualPoints[_pathRouteOp[i]][1].toDouble() * k +
              (size.width - k * (_width / _grid)) / 2,
          _visualPoints[_pathRouteOp[i]][0].toDouble() * k +
              (size.height - k * (_heigth / _grid)) / 2);
      if (i < _pathRouteOp.length - 1) {
        Offset p2 = Offset(
            _visualPoints[_pathRouteOp[i + 1]][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[_pathRouteOp[i + 1]][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2);
        canvas.drawLine(p1, p2, myPaint);
      }
      TextSpan span = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: Colors.orange,
          fontSize: k * 10,
          fontWeight: FontWeight.bold,
        ),
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, p1);
    }
  }

  void drawPathRouteOp(Canvas canvas, Size size, Paint myPaint, double k) {
    if (_pathRouteOp.isEmpty ||
        _pathRouteOp[_pathRouteOp.length - 1] != _visualPoints.length - 1)
      return;
    Color color = myPaint.color;
    myPaint
      ..color = Colors.green
      ..strokeWidth = k;
    for (int i = 0; i < _pathRouteOp.length; i++) {
      Offset p1 = Offset(
              _visualPoints[_pathRouteOp[i]][1].toDouble() * k +
                  (size.width - k * (_width / _grid)) / 2,
              _visualPoints[_pathRouteOp[i]][0].toDouble() * k +
                  (size.height - k * (_heigth / _grid)) / 2) +
          Offset(2 * k, 2 * k);
      if (i < _pathRouteOp.length - 1) {
        Offset p2 = Offset(
                _visualPoints[_pathRouteOp[i + 1]][1].toDouble() * k +
                    (size.width - k * (_width / _grid)) / 2,
                _visualPoints[_pathRouteOp[i + 1]][0].toDouble() * k +
                    (size.height - k * (_heigth / _grid)) / 2) +
            Offset(2 * k, 2 * k);
        canvas.drawLine(p1, p2, myPaint);
      }
      TextSpan span = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: Colors.green,
          fontSize: k * 10,
          fontWeight: FontWeight.bold,
        ),
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, p1);
    }
    myPaint..color = color;
  }

  void drawState(Canvas canvas, Size size, Paint myPaint, double k) {
    TextSpan span = TextSpan(
      text: _state,
      style: TextStyle(
        color: Colors.black,
        fontSize: k * 10,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset.zero);
  }
}
