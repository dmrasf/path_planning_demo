import 'package:flutter/material.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/utils.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class ShowMapForRRT extends StatefulWidget {
  final String fileName;
  ShowMapForRRT({Key key, this.fileName}) : super(key: key);
  @override
  ShowMapForRRTState createState() => ShowMapForRRTState();
}

class ShowMapForRRTState extends State<ShowMapForRRT>
    with SingleTickerProviderStateMixin {
  bool _isDone = false;
  Map<String, dynamic> _myMap;
  double _grid;
  AnimationController _controller;
  List<dynamic> _visualPoints = [];
  List<dynamic> _visualGraph;
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowFliter = false;
  bool _isShowAxis = false;
  String _remindStr = '正在读取地图';
  int _speed = 300;
  String _state = '';
  bool _r = true;
  int _iterationNum = 1000;
  Map<int, int> _tree = Map<int, int>();
  Set _closePoints = Set();
  Map<int, double> _pointToStartDis = Map<int, double>();
  int _i = 0;
  double _rate = 0.5;
  double _radius = 3;
  Set _nearPoint = Set();
  Set _openPoints = Set();

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
                painter: PainteRRT(
                  this._myMap,
                  this._visualPoints,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowFliter,
                  this._isShowAxis,
                  this._state,
                  this._tree,
                  this._i,
                  this._radius,
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
      _grid = _myMap['grid'].toDouble();
      _isDone = true;
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 500));
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

  void toggleShowFliter(bool isShow) {
    _isShowFliter = isShow;
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

  void _getNearRadiusPoints() {
    int end = _visualPoints.length - 1;
    for (int i = 0; i < _visualPoints.length - 1; i++) {
      double dis = pow(
        pow((_visualPoints[end][0] - _visualPoints[i][0]) * _grid, 2) +
            pow((_visualPoints[end][1] - _visualPoints[i][1]) * _grid, 2),
        0.5,
      );
      if (dis <= _radius) _nearPoint.add(i);
    }
  }

  void _updateOpenPoints(int newPoint) {
    for (int i = 0; i < _visualPoints.length; i++) {
      if (_visualGraph[newPoint][i] > 0) _openPoints.add(i);
    }
  }

  void run(double radius, int iterationNum) async {
    if (!_isDone) return;
    _controller.reset();
    _controller.forward();
    _radius = radius;
    _pathRoute.clear();
    _pathRouteOp.clear();
    _tree.clear();
    _closePoints = Set.from([0]);
    _openPoints.clear();
    _updateOpenPoints(0);
    _i = 0;
    _pointToStartDis.clear();
    _nearPoint.clear();
    _getNearRadiusPoints();
    int i = 0;
    for (; i < _iterationNum; i++) {
      int xRand = _getRandomPoint();
      if (xRand == -1) break;
      int xNear = _findNearPoint(xRand);
      if (xNear == -1) continue;
      int xNew = xRand;
      _state = 'Add new branch';
      _addNewBranch(xNew, xNear);
      await Future.delayed(Duration(milliseconds: _speed));
      _state = 'Change branch';
      _changeParent(xNew);
      await Future.delayed(Duration(milliseconds: _speed));
      if (_isArrived(xNew)) {
        _state = 'Success !';
        _tree[_visualPoints.length - 1] = xNew;
        _parsePathRoute();
        _optimisingPath();
        (showPathDiatance.currentState as ShowPathDistanceState).update(
          _calculatePathDistance().toStringAsFixed(2),
        );
        for (int i = 0; i < _pathRoute.length; i++) {
          _i = i;
          await Future.delayed(Duration(milliseconds: 100));
        }
        break;
      }
    }
    if (i >= _iterationNum) _state = 'No path !';
  }

  double _calculatePathDistance() {
    double pathDistance = 0;
    List<int> tmp;
    if (_isShowFliter)
      tmp = List.from(_pathRouteOp);
    else
      tmp = List.from(_pathRoute);
    for (int i = 0; i < tmp.length - 1; i++) {
      pathDistance += _visualGraph[tmp[i]][tmp[i + 1]];
    }
    return pathDistance;
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

  void _parsePathRoute() {
    _pathRoute = [_visualPoints.length - 1];
    while (_pathRoute[_pathRoute.length - 1] != 0)
      _pathRoute.add(_tree[_pathRoute[_pathRoute.length - 1]]);
  }

  bool _isArrived(int xNew) {
    double dis = _visualGraph[xNew][_visualPoints.length - 1];
    if (dis > 0) return true;
    return false;
  }

  void _addNewBranch(int xNew, int xNear) {
    _tree[xNew] = xNear;
    _closePoints.add(xNew);
    _updateOpenPoints(xNew);
  }

  void _changeParent(int xNew) {
    double dis = _calculatePathDis(xNew);
    for (int p in _closePoints) {
      if (p == xNew || p == _tree[xNew]) continue;
      if (_visualGraph[xNew][p] <= 0) continue;
      double tmp = _visualGraph[xNew][p];
      if (dis + tmp < _calculatePathDis(p)) {
        _tree[p] = xNew;
        _pointToStartDis[p] = dis + tmp;
      }
    }
  }

  int _getRandomPoint() {
    //Set choiceOther = _openPoints.difference(_nearPoint);
    //Set choiceRadius = _openPoints.intersection(_nearPoint);
    //if (choiceRadius.isNotEmpty) {
    //int i = Random().nextInt(choiceRadius.length);
    //return choiceRadius.toList()[i];
    //} else if (choiceOther.isNotEmpty) {
    //int i = Random().nextInt(choiceOther.length);
    //return choiceOther.toList()[i];
    //} else {
    //return -1;
    //}

    double r = Random().nextDouble();
    if (r > _rate) {
    } else {}
    while (true) {
      int i = Random().nextInt(_visualPoints.length - 1) + 1;
      if (!_closePoints.contains(i)) return i;
    }
  }

  int _findNearPoint(int xRand) {
    double distance = double.infinity;
    int near = -1;
    for (int p in _closePoints) {
      if (_visualGraph[p][xRand] <= 0) continue;
      double tmp = _visualGraph[p][xRand] + _calculatePathDis(p);
      if (tmp < distance) {
        distance = tmp;
        near = p;
      }
    }
    return near;
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
  }
}

class PainteRRT extends MapPainter {
  final List<dynamic> _visualPoints;
  final List<int> _pathRoute;
  final String _state;
  final List<int> _pathRouteOp;
  final bool _isShowFliter;
  final bool _isShowAxis;
  final Map<int, int> _tree;
  final int _i;
  final double _radius;
  PainteRRT(
    _myMap,
    this._visualPoints,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowFliter,
    this._isShowAxis,
    this._state,
    this._tree,
    this._i,
    this._radius,
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
    if (_isShowFliter)
      super.drawPathRoute(canvas, size, myPaint, k, _pathRouteOp, Colors.green,
          Colors.green.shade900, _pathRouteOp.length);
    else
      super.drawPathRoute(canvas, size, myPaint, k, _pathRoute, Colors.orange,
          Colors.orange.shade900, _i + 1);
    drawTree(canvas, size, myPaint, k);
    super.drawRobot(canvas, size, myPaint, k);
    drawRadius(canvas, size, myPaint, k);
    super.drawState(canvas, size, myPaint, k, _state);
  }

  void drawRadius(Canvas canvas, Size size, Paint myPaint, double k) {
    double minY = (size.height - k * (super.heigth / super.grid)) / 2;
    double maxY = super.heigth / super.grid * k + minY;
    double mPp = (maxY - minY) / super.heigth;
    myPaint..color = Colors.red.withOpacity(0.3);
    canvas.drawCircle(
      Offset(
          _visualPoints[_visualPoints.length - 1][1].toDouble() * k +
              (size.width - k * (super.width / super.grid)) / 2,
          _visualPoints[_visualPoints.length - 1][0].toDouble() * k +
              (size.height - k * (super.heigth / super.grid)) / 2),
      _radius * mPp,
      myPaint,
    );
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
