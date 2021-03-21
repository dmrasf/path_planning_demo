import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/wait_show.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/my_painter.dart';
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
  List<dynamic> _visualPoints = [];
  List<dynamic> _visualGraph;
  List<List<double>> _pathPhermonone = [];
  int _speed = 300;
  double _initPathPhermononeValue = 1;
  int _iterationNum = 20;
  double _a = 1;
  double _b = 0.2;
  double _p = 0.8;
  double _antPheromone = 50;
  int _antsNum = 1;
  List<List<int>> _antsPos = [];
  List<bool> _antsPosChange = [];
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowOp = false;
  int _currentIter = 0;
  int _i = 0;
  int _anti = 1;
  bool _isShowAnts = false;
  bool _isDisPose = false;
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
    _isDisPose = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isDone
        ? AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: PainteAnt(
                  _myMap,
                  this._visualPoints,
                  this._pathPhermonone,
                  this._currentIter,
                  this._i,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowOp,
                  this._antsPos,
                  this._anti,
                  this._isShowAnts,
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
      _remindStr = '解析失败，请重新选择！';
      _r = false;
    }
    setState(() {});
  }

  void toggleShowOp(bool isShow) {
    _isShowOp = isShow;
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      _calculatePathDistance().toStringAsFixed(2),
    );
  }

  void toggleShowAnts(bool isShow) {
    _isShowAnts = isShow;
  }

  void changeSpeed(int newSpeed) {
    _speed = newSpeed;
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
    if (!_isDone) return;
    _antsNum = antsNum;
    _a = a;
    _b = b;
    _p = p;
    _antPheromone = antPheromone;
    _initPathPhermononeValue = initAntPathPheromone;
    _iterationNum = iteration;
    _currentIter = 0;
    _controller.reset();
    _controller.forward();
    _pathPhermonone = [];
    _antsPos = [];
    _pathRoute = [];
    _pathRouteOp = [];
    _currentIter = 0;
    _i = 0;
    _state = 'Running';
    _initPathPhermonone();
    for (int i = 0; i < _iterationNum; i++) {
      if (_isDisPose) {
        return;
      }
      _currentIter = i + 1;
      _setAntsPosition();
      while (true) if (await _selectNextPosForAnts()) break;
      _updatePathPhermonone();
      await Future.delayed(Duration(milliseconds: _speed));
    }
    _parseFinalRoute();
    if (_pathRoute.isEmpty)
      _state = 'No Path';
    else
      _state = 'Success';
    _optimisingPath();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      _calculatePathDistance().toStringAsFixed(2),
    );
    for (int i = 0; i < _pathRoute.length; i++) {
      _i = i;
      await Future.delayed(Duration(milliseconds: 200));
    }
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
    _antsPos = [];
    for (int i = 0; i < _antsNum; i++) {
      _antsPos.add([0]);
      _antsPosChange.add(false);
    }
  }

  double _calculateProbability(int p1, int p2) {
    if (_visualGraph[p1][p2] == 0 || _visualGraph[p1][p2] == -1) return 0;
    return pow(_pathPhermonone[p1][p2], _a) * pow(1 / _visualGraph[p1][p2], _b);
  }

  Future<bool> _selectNextPosForAnts() async {
    bool isAllArrived = true;
    ai = 0;
    _anti = 1;
    for (List<int> antPath in _antsPos) {
      if (antPath[antPath.length - 1] == _visualPoints.length - 1)
        antPath.add(-2);
      if (antPath[antPath.length - 1] == -2 ||
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
      if (antPath.length > _anti) _anti = antPath.length;
    }
    while (ai < 20 && _isShowAnts)
      await Future.delayed(Duration(milliseconds: 0));
    return isAllArrived;
  }

  void _updatePathPhermonone() {
    for (int i = 0; i < _visualPoints.length; i++)
      for (int j = 0; j < _visualPoints.length; j++)
        _pathPhermonone[i][j] *= (1 - _p);
    for (List<int> antPath in _antsPos) {
      if (antPath[antPath.length - 1] != -1) {
        double path = 0;
        for (int i = 0; i < antPath.length - 2; i++)
          path += _visualGraph[antPath[i]][antPath[i + 1]];
        double deltaP = _antPheromone / path;
        for (int i = 0; i < antPath.length - 2; i++) {
          _pathPhermonone[antPath[i]][antPath[i + 1]] += deltaP;
          _pathPhermonone[antPath[i + 1]][antPath[i]] =
              _pathPhermonone[antPath[i]][antPath[i + 1]];
        }
      }
    }
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

int ai = 0;

class PainteAnt extends MapPainter {
  final Map<String, dynamic> _myMap;
  final List<dynamic> _visualPoints;
  final List<List<double>> _pathPhermonone;
  final int _currentIter;
  final int _i;
  final List<int> _pathRoute;
  final List<int> _pathRouteOp;
  final bool _isShowOp;
  final List<List<int>> _antsPos;
  final int _anti;
  final bool _isShowAnts;
  final String _state;
  PainteAnt(
    this._myMap,
    this._visualPoints,
    this._pathPhermonone,
    this._currentIter,
    this._i,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowOp,
    this._antsPos,
    this._anti,
    this._isShowAnts,
    this._state,
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
    drawBarriers(canvas, size, myPaint, k);
    //drawAxis(canvas, size, myPaint, k);
    drawPhermone(canvas, size, myPaint, k);
    if (_isShowOp)
      super.drawPathRoute(canvas, size, myPaint, k, _pathRouteOp, Colors.green,
          Colors.green.shade900, _pathRouteOp.length);
    else
      super.drawPathRoute(canvas, size, myPaint, k, _pathRoute, Colors.orange,
          Colors.orange.shade900, _i + 1);
    drawRobot(canvas, size, myPaint, k);
    String state = 'iteration: ' + _currentIter.toString() + '  ' + _state;
    drawState(canvas, size, myPaint, k, state);
    if (_isShowAnts) drawAnts(canvas, size, myPaint, k);
  }

  void drawAnts(Canvas canvas, Size size, Paint myPaint, double k) {
    if (_anti < 2) {
      ai = 20;
      return;
    }
    myPaint..color = Colors.black;
    final TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    _antsPos.asMap().forEach((i, antPath) {
      Offset p;
      if (antPath[antPath.length - 1] == -1) {
        p = Offset(
            _visualPoints[antPath[antPath.length - 2]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 2]][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
      } else if (antPath[antPath.length - 1] == -2) {
        p = Offset(
            _visualPoints[antPath[antPath.length - 2]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 2]][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
      } else {
        Offset p1 = Offset(
            _visualPoints[antPath[antPath.length - 2]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 2]][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
        Offset p2 = Offset(
            _visualPoints[antPath[antPath.length - 1]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 1]][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
        p = p1 + (p2 - p1) * ai.toDouble() / 20;
      }
      canvas.drawCircle(
        p +
            Offset(Random().nextDouble() - 0.5, Random().nextDouble() - 0.5) *
                8,
        k * 2,
        myPaint,
      );
      TextSpan span = TextSpan(
        text: (i + 1).toString(),
        style: GoogleFonts.jua(
          textStyle: TextStyle(
            color: Colors.pink.shade900,
            fontSize: k * 6,
          ),
        ),
      );
      tp..text = span;
      tp.layout();
      tp.paint(canvas, p);
    });
    if (ai < 20) ai++;
  }

  void drawPhermone(Canvas canvas, Size size, Paint myPaint, double k) {
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
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[i][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
        Offset p2 = Offset(
            _visualPoints[j][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[j][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
        double width =
            (_pathPhermonone[i][j] - miP) / (mxP - miP) * 5.5 * k * mxP / 20;
        myPaint
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, myPaint);
      }
    }
  }
}
