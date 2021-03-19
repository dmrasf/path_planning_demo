import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/utils.dart';

class ShowMapForAnt extends StatefulWidget {
  final String fileName;
  ShowMapForAnt({Key key, this.fileName}) : super(key: key);
  @override
  ShowMapForAntState createState() => ShowMapForAntState();
}

class ShowMapForAntState extends State<ShowMapForAnt>
    with SingleTickerProviderStateMixin {
  bool _isDone = false;
  Map<String, dynamic> _myMap;
  AnimationController _controller;
  String _remindStr = '正在读取地图';
  bool _r = true;
  int _speed = 830;
  List<dynamic> _visualPoints = [];
  List<dynamic> _visualGraph;
  List<List<double>> _pathPhermonone = [];
  double _initPathPhermononeValue = 1;
  int _iterationNum = 20;
  double _a = 1;
  double _b = 0.2;
  double _p = 0.8;
  double _antPheromone = 50;
  int _antsNum = 40;
  List<List<int>> _antsPos = [];
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowOp = false;
  int _currentIter = 0;

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
                painter: MapPainterAnt(
                  _myMap,
                  this._visualPoints,
                  this._pathPhermonone,
                  this._currentIter,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowOp,
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

  void toggleShowOp(bool isShow) {
    _isShowOp = isShow;
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      'Path distance: ' + _calculatePathDistance().toStringAsFixed(2) + 'm',
    );
  }

  Future<void> run(
    int antsNum,
    double a,
    double b,
    double p,
    double antPheromone,
    double initAntPathPheromone,
    int iteration,
  ) async {
    _a = a;
    _b = b;
    _p = p;
    _antPheromone = antPheromone;
    _initPathPhermononeValue = initAntPathPheromone;
    _iterationNum = iteration;
    if (!_isDone) return;
    _controller.reset();
    _controller.forward();
    _pathPhermonone = [];
    _antsPos = [];
    _pathRoute = [];
    _pathRouteOp = [];
    _currentIter = 0;
    _initPathPhermonone();
    await Future.delayed(Duration(milliseconds: _speed * 2));
    for (int i = 0; i < _iterationNum; i++) {
      _currentIter++;
      _setAntsPosition();
      while (true) {
        if (_selectNextPosForAnts()) break;
      }
      await _updatePathPhermonone();
    }
    _parseFinalRoute();
    _optimisingPath();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      'Path distance: ' + _calculatePathDistance().toStringAsFixed(2) + 'm',
    );
  }

  double _calculatePathDistance() {
    double pathDistance = 0;
    List<int> tmp;
    if (_isShowOp)
      tmp = List.from(_pathRouteOp);
    else
      tmp = List.from(_pathRoute);
    for (int i = 0; i < tmp.length - 1; i++) {
      pathDistance += pow(
          pow(
                  (_visualPoints[tmp[i]][0] - _visualPoints[tmp[i + 1]][0]) *
                      _myMap['grid'],
                  2) +
              pow(
                  (_visualPoints[tmp[i]][1] - _visualPoints[tmp[i + 1]][1]) *
                      _myMap['grid'],
                  2),
          0.5);
    }
    return pathDistance;
  }

  void _parseFinalRoute() {
    _pathRoute = [0];
    while (true) {
      List<double> sortPath = List.from(
        _pathPhermonone[_pathRoute[_pathRoute.length - 1]],
      );
      sortPath.sort((l, r) => r.compareTo(l));
      bool isDone = false;
      for (double p in sortPath) {
        int i = _pathPhermonone[_pathRoute[_pathRoute.length - 1]].indexWhere(
          (e) => e == p,
        );
        if (!_pathRoute.contains(i) &&
            _pathPhermonone[_pathRoute[_pathRoute.length - 1]][i] != 0) {
          _pathRoute.add(i);
          isDone = true;
          break;
        }
      }
      if (!isDone) {
        _pathRoute = [];
        break;
      }
      if (_pathRoute[_pathRoute.length - 1] == _visualPoints.length - 1) break;
    }
  }

  void _initPathPhermonone() {
    for (int i = 0; i < _visualPoints.length; i++) {
      List<double> tmp = [];
      for (int j = 0; j < _visualPoints.length; j++) {
        if (_visualGraph[i][j] == 0 || _visualGraph[i][j] == -1)
          tmp.add(0.0);
        else
          tmp.add(_initPathPhermononeValue);
      }
      _pathPhermonone.add(tmp);
    }
  }

  void _setAntsPosition() {
    for (int i = 0; i < _antsNum; i++) _antsPos.add([0]);
  }

  double _calculateProbability(int p1, int p2) {
    if (_visualGraph[p1][p2] == 0 || _visualGraph[p1][p2] == -1) return 0;
    return pow(_pathPhermonone[p1][p2], _a) * pow(1 / _visualGraph[p1][p2], _b);
  }

  bool _selectNextPosForAnts() {
    bool isAllArrived = true;
    for (List<int> antPath in _antsPos) {
      if (antPath[antPath.length - 1] == _visualPoints.length - 1 ||
          antPath[antPath.length - 1] == -1) continue;
      isAllArrived = false;
      List<int> pointToSelected = List.generate(
        _visualPoints.length,
        (index) => index,
      );
      for (int pos in antPath) pointToSelected.remove(pos);
      List<double> probabilities =
          pointToSelected.map((i) => i.toDouble()).toList();
      for (int i = 0; i < probabilities.length; i++)
        probabilities[i] = _calculateProbability(
          antPath[antPath.length - 1],
          pointToSelected[i],
        );
      double sum = 0;
      probabilities.forEach((element) => sum += element);
      if (sum == 0) {
        antPath.add(-1);
        break;
      }
      for (int i = 0; i < probabilities.length; i++) probabilities[i] /= sum;
      try {
        antPath.add(randomChoice(pointToSelected, probabilities));
      } catch (e) {
        antPath.add(-1);
      }
    }
    return isAllArrived;
  }

  Future<void> _updatePathPhermonone() async {
    for (int i = 0; i < _visualPoints.length; i++)
      for (int j = 0; j < _visualPoints.length; j++)
        _pathPhermonone[i][j] *= (1 - _p);
    for (List<int> antPath in _antsPos) {
      if (antPath[antPath.length - 1] != -1) {
        double path = 0;
        for (int i = 0; i < antPath.length - 1; i++)
          path += _visualGraph[antPath[i]][antPath[i + 1]];
        double deltaP = _antPheromone / path;
        for (int i = 0; i < antPath.length - 1; i++) {
          _pathPhermonone[antPath[i]][antPath[i + 1]] += deltaP;
          _pathPhermonone[antPath[i + 1]][antPath[i]] =
              _pathPhermonone[antPath[i]][antPath[i + 1]];
        }
      }
    }
    await Future.delayed(Duration(milliseconds: _speed * 2));
  }

  void _optimisingPath() {
    if (_pathRoute.isEmpty) return;
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
}

class MapPainterAnt extends CustomPainter {
  final Map<String, dynamic> _myMap;
  final List<dynamic> _visualPoints;
  final List<List<double>> _pathPhermonone;
  final int _currentIter;
  final List<int> _pathRoute;
  final List<int> _pathRouteOp;
  final bool _isShowOp;
  MapPainterAnt(
    this._myMap,
    this._visualPoints,
    this._pathPhermonone,
    this._currentIter,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowOp,
  );
  double _width;
  double _heigth;
  double _grid;
  double _robotSize;
  List<dynamic> _barriers;

  @override
  void paint(Canvas canvas, Size size) {
    if (!parseData()) return;
    if (!parseData()) return;
    double gridWidth = _width / _grid;
    double gridHeigth = _heigth / _grid;
    double k = size.width / gridWidth < size.height / gridHeigth
        ? size.width / gridWidth
        : size.height / gridHeigth;

    Paint myPaint = Paint()..color = Colors.black;
    drawBarriers(canvas, size, myPaint, k);
    drawPath(canvas, size, myPaint, k);
    if (_isShowOp)
      drawPathRouteOp(canvas, size, myPaint, k);
    else
      drawPathRoute(canvas, size, myPaint, k);
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
  }

  void drawPath(Canvas canvas, Size size, Paint myPaint, double k) {
    myPaint..color = Colors.blue[300];
    double mxP = -double.infinity;
    double miP = double.infinity;
    for (int i = 0; i < _pathPhermonone.length - 1; i++) {
      for (int j = i + 1; j < _visualPoints.length; j++) {
        double tmp = _pathPhermonone[i][j];
        if (tmp == 0) continue;
        if (tmp > mxP) mxP = tmp;
        if (tmp < miP) miP = tmp;
      }
    }
    for (int i = 0; i < _pathPhermonone.length - 1; i++) {
      for (int j = i + 1; j < _visualPoints.length; j++) {
        if (_pathPhermonone[i][j] == 0) continue;
        Offset p1 = Offset(
            _visualPoints[i][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[i][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2);
        Offset p2 = Offset(
            _visualPoints[j][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[j][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2);
        double width =
            (_pathPhermonone[i][j] - miP) / (mxP - miP) * 5.5 * k * mxP / 900;
        myPaint
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, myPaint);
      }
    }
  }

  void drawPathRoute(Canvas canvas, Size size, Paint myPaint, double k) {
    if (_pathRoute.isEmpty ||
        _pathRoute[_pathRoute.length - 1] != _visualPoints.length - 1) return;
    Color color = myPaint.color;
    myPaint
      ..color = Colors.orange
      ..strokeWidth = k;
    for (int i = 0; i < _pathRoute.length; i++) {
      Offset p1 = Offset(
          _visualPoints[_pathRoute[i]][1].toDouble() * k +
              (size.width - k * (_width / _grid)) / 2,
          _visualPoints[_pathRoute[i]][0].toDouble() * k +
              (size.height - k * (_heigth / _grid)) / 2);
      if (i < _pathRoute.length - 1) {
        Offset p2 = Offset(
            _visualPoints[_pathRoute[i + 1]][1].toDouble() * k +
                (size.width - k * (_width / _grid)) / 2,
            _visualPoints[_pathRoute[i + 1]][0].toDouble() * k +
                (size.height - k * (_heigth / _grid)) / 2);
        canvas.drawLine(p1 + Offset(0, 0), p2 + Offset(0, 0), myPaint);
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
    myPaint..color = color;
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
      text: 'i: ' +
          _currentIter.toString() +
          (_pathRoute.isEmpty ? '' : '   Success!'),
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
