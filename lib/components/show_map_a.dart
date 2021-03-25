import 'package:flutter/material.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/my_painter.dart';
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
  Set _openPoints = Set();
  Set _closePoints = Set();
  Map<int, int> _tree = Map<int, int>();
  Map<int, double> _pointToStartDis = Map<int, double>();
  Map<int, double> _openPointsValue = Map<int, double>();
  bool _isOp = true;
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowOp = false;
  String _remindStr = '正在读取地图';
  bool _r = true;
  int _speed = 300;
  int _i = 0;
  String _state = '';
  bool _isShowAxis = false;

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
                painter: PainteA(
                  _myMap,
                  this._visualPoints,
                  this._openPoints,
                  this._openPointsValue,
                  this._tree,
                  this._closePoints,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowOp,
                  this._isShowAxis,
                  this._state,
                  this._i,
                ),
              );
            },
          )
        : WaitShow(_remindStr, _r);
  }

  Future<void> getMapAnimation() async {
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
      _remindStr = '解析失败，请重新选择！';
      _r = false;
    }
    setState(() {});
  }

  void changeSpeed(int newSpeed) {
    _speed = newSpeed;
  }

  void toggleShowAxis(bool isShow) {
    _isShowAxis = isShow;
  }

  void toggleShowOp(bool isShow) {
    _isShowOp = isShow;
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      _calculatePathDistance().toStringAsFixed(2),
    );
  }

  Future<bool> save(String path) async {
    if (_pathRouteOp.isEmpty) return false;
    double grid = _myMap['grid'].toDouble();
    List<dynamic> start = _myMap['start'];
    List<dynamic> end = _myMap['end'];
    List<List<dynamic>> realPath = [start];
    for (int i = 1; i < _pathRouteOp.length - 1; i++)
      realPath.add([
        (num.parse(
          (_visualPoints[_pathRouteOp[i]][0] * grid).toStringAsFixed(2),
        )),
        (num.parse(
          (_visualPoints[_pathRouteOp[i]][1] * grid).toStringAsFixed(2),
        ))
      ]);
    realPath.add(end);
    String pathStr = jsonEncode(realPath);
    File f = File(path);
    await f.create();
    await f.writeAsString(pathStr);
    return true;
  }

  void run(double hWeight, double gWeight) async {
    if (!_isDone) return;
    if (hWeight + gWeight == 0) {
      showSnakBar(context, '参数不能同时为0');
      return;
    }
    _controller.reset();
    _controller.forward();
    _closePoints.clear();
    _openPoints.clear();
    _openPointsValue.clear();
    _tree.clear();
    _pathRoute.clear();
    _pathRouteOp.clear();
    _i = 0;
    int start = 0;
    int end = _visualPoints.length - 1;
    int currentPoint = start;
    _closePoints.add(currentPoint);

    while (true) {
      _updateOpenPoints(currentPoint);
      currentPoint = _findNextPoint(currentPoint, hWeight, gWeight);
      _state = 'Update close set';
      await Future.delayed(Duration(milliseconds: _speed));
      if (!_openPoints.remove(currentPoint)) {
        _state = 'Failure, No path !';
        return;
      }
      _closePoints.add(currentPoint);
      _state = 'Update open set & Find next positon';
      await Future.delayed(Duration(milliseconds: _speed));
      if (currentPoint == end) break;
    }
    _state = 'Success !';
    _parsePathRoute();
    _optimisingPath();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      _calculatePathDistance().toStringAsFixed(2),
    );
    for (int i = 0; i < _pathRoute.length; i++) {
      _i = i;
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  void _optimisingPath() {
    List<int> tmpRoute = _pathRoute.reversed.toList();
    int currentPoint = tmpRoute[0];
    List<int> necessaryPath = [currentPoint];
    int i = 0;
    int tmpi = 0;
    int tmpPoint = 0;
    while (true) {
      tmpi = 0;
      tmpPoint = 0;
      for (int j = i + 1; j < tmpRoute.length; j++)
        if (_visualGraph[currentPoint][tmpRoute[j]] != -1) {
          tmpPoint = tmpRoute[j];
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
    List<int> tmp;
    if (_isShowOp)
      tmp = List.from(_pathRouteOp);
    else
      tmp = List.from(_pathRoute);
    for (int i = 0; i < tmp.length - 1; i++) {
      pathDistance += _visualGraph[tmp[i]][tmp[i + 1]];
    }
    return pathDistance;
  }

  int _findNextPoint(
    int currentPoint,
    double hWeight,
    double gWeight,
  ) {
    _openPointsValue.clear();
    double minDistance = double.infinity;
    int bestPoint;
    int end = _visualPoints.length - 1;
    double grid = _myMap['grid'];
    for (int p in _openPoints) {
      double h = pow(
        pow((_visualPoints[end][0] - _visualPoints[p][0]) * grid, 2) +
            pow((_visualPoints[end][1] - _visualPoints[p][1]) * grid, 2),
        0.5,
      );
      double g = _visualGraph[currentPoint][p];
      double f =
          h * (hWeight == 0 ? 1 : hWeight) + g * (gWeight == 0 ? 1 : gWeight);
      _openPointsValue[p] = f;
      if (f < minDistance) {
        minDistance = f;
        bestPoint = p;
      }
    }
    return bestPoint;
  }

  void _updateOpenPoints(int currentPoint) {
    List<int> newPoint = [];
    for (int i = 0; i < _visualPoints.length; i++) {
      if (_visualGraph[currentPoint][i] > 0 &&
          !_openPoints.contains(i) &&
          !_closePoints.contains(i)) {
        _tree[i] = currentPoint;
        _openPoints.add(i);
        newPoint.add(i);
      }
    }
    _openPoints.forEach((e) => _changeParent(e));
  }

  void _changeParent(int opPoint) {
    double distance = double.infinity;
    for (int parent in _closePoints.union(_openPoints)) {
      double tmp = _visualGraph[parent][opPoint];
      if (tmp <= 0) continue;
      if (tmp + _calculatePathDis(parent) < distance) {
        distance = tmp + _calculatePathDis(parent);
        _tree[opPoint] = parent;
      }
    }
  }

  double _calculatePathDis(int p) {
    if (!_pointToStartDis.containsKey(p)) {
      double dis = 0;
      List<int> path = [p];
      while (path[path.length - 1] != 0) {
        path.add(_tree[path[path.length - 1]]);
        dis = dis + _visualGraph[path[path.length - 1]][path[path.length - 2]];
      }
      _pointToStartDis[p] = dis;
    }
    return _pointToStartDis[p];
    //double dis = 0;
    //List<int> path = [p];
    //while (path[path.length - 1] != 0) {
    //path.add(_tree[path[path.length - 1]]);
    //dis = dis + _visualGraph[path[path.length - 1]][path[path.length - 2]];
    //}
    //_pointToStartDis[p] = dis;
    //return _pointToStartDis[p];
  }

  void _parsePathRoute() {
    _pathRoute = [_visualPoints.length - 1];
    _pathRoute = [_visualPoints.length - 1];
    while (_pathRoute[_pathRoute.length - 1] != 0)
      _pathRoute.add(_tree[_pathRoute[_pathRoute.length - 1]]);
  }
}

class PainteA extends MapPainter {
  final List<dynamic> _visualPoints;
  final Set _closePoints;
  final Set _openPoints;
  final Map<int, double> _openPointsValue;
  final Map<int, int> _tree;
  final List<int> _pathRoute;
  final String _state;
  final List<int> _pathRouteOp;
  final bool _isShowOp;
  final bool _isShowAxis;
  final int _i;
  PainteA(
    _myMap,
    this._visualPoints,
    this._openPoints,
    this._openPointsValue,
    this._tree,
    this._closePoints,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowOp,
    this._isShowAxis,
    this._state,
    this._i,
  ) : super(_myMap, _visualPoints);

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
    if (_isShowAxis) super.drawAxis(canvas, size, myPaint, k);
    if (_isShowOp)
      super.drawPathRoute(canvas, size, myPaint, k, _pathRouteOp, Colors.green,
          Colors.green.shade900, _pathRouteOp.length);
    else
      super.drawPathRoute(canvas, size, myPaint, k, _pathRoute, Colors.orange,
          Colors.orange.shade900, _i + 1);
    super.drawRobot(canvas, size, myPaint, k);
    drawSet(canvas, size, myPaint, k);
    drawTree(canvas, size, myPaint, k);
    super.drawState(canvas, size, myPaint, k, _state);
  }

  void drawSet(Canvas canvas, Size size, Paint myPaint, double k) {
    for (int p in _openPoints) {
      myPaint..color = Colors.yellow;
      Offset offset = Offset(
        _visualPoints[p][1].toDouble() * k +
            (size.width - k * (super.width / super.grid)) / 2,
        _visualPoints[p][0].toDouble() * k +
            (size.height - k * (super.heigth / super.grid)) / 2,
      );
      canvas.drawCircle(
          offset, super.robotSize / (super.grid + 0.035) * k, myPaint);
      if (_openPointsValue.isNotEmpty) {
        //double ma = _openPointsValue.;
        //double mi = _openPointsValue.reduce(min);
        double mi = 0;
        double ma = 10;
        double fontSize = k * (7 - 3 * (_openPointsValue[p] - mi) / (ma - mi));
        fontSize = 1;
        TextSpan span = TextSpan(
          text: _openPointsValue[p].toStringAsFixed(1),
          style: GoogleFonts.jua(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, offset + Offset(-fontSize * 0.7, -fontSize * 0.6));
      }
    }
    for (int p in _closePoints) {
      myPaint..color = Colors.blue;
      canvas.drawCircle(
        Offset(
            _visualPoints[p][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[p][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2),
        super.robotSize / (super.grid + 0.035) * k,
        myPaint,
      );
    }
  }

  void drawTree(Canvas canvas, Size size, Paint myPaint, double k) {
    _tree.forEach((c, p) {
      Offset p1 = Offset(
          _visualPoints[c][1].toDouble() * k +
              (size.width - k * (super.width / super.grid)) / 2,
          _visualPoints[c][0].toDouble() * k +
              (size.height - k * (super.heigth / super.grid)) / 2);
      Offset p2 = Offset(
          _visualPoints[p][1].toDouble() * k +
              (size.width - k * (super.width / super.grid)) / 2,
          _visualPoints[p][0].toDouble() * k +
              (size.height - k * (super.heigth / super.grid)) / 2);
      myPaint
        ..strokeWidth = 2
        ..color = Colors.blue
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, myPaint);
    });
  }
}
