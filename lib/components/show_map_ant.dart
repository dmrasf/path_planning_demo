import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/components/line.dart';
import 'package:path_planning/utils.dart';

class ShowMapForAnt extends StatefulWidget {
  final Map<String, dynamic> myMap;
  final List<dynamic> visualPoints;
  final List<dynamic> visualGraph;
  ShowMapForAnt({
    Key key,
    @required this.myMap,
    @required this.visualGraph,
    @required this.visualPoints,
  }) : super(key: key);
  @override
  ShowMapForAntState createState() => ShowMapForAntState();
}

class ShowMapForAntState extends State<ShowMapForAnt>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<List<double>> _pathPhermonone = [];
  int _speed = 300;
  double _initPathPhermononeValue = 1;
  int _iterationNum = 200;
  double _a = 1;
  double _b = 0.1;
  double _p = 0.8;
  double _antPheromone = 50;
  int _antsNum = 100;
  List<List<int>> _antsPos = [];
  List<int> _pathRoute = [];
  List<int> _pathRouteOp = [];
  bool _isShowFliter = false;
  int _currentIter = 0;
  int _i = 0;
  bool _isShowAnts = false;
  String _state = '';
  int _animationForShowAntsi = 0;
  bool _isShowAxis = false;
  List<double> _iterationNumValue = [];
  bool _isShowIter = false;
  List<int> _preBest = [];
  double _preBestDistance = double.infinity;
  bool _isOp = false;
  bool _isReset = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 100),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isShowIter
        ? LinePathForAnt(_iterationNumValue)
        : AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: PainteAnt(
                  widget.myMap,
                  widget.visualPoints,
                  this._pathPhermonone,
                  this._currentIter,
                  this._i,
                  this._pathRoute,
                  this._pathRouteOp,
                  this._isShowFliter,
                  this._antsPos,
                  this._isShowAnts,
                  this._isShowAxis,
                  this._state,
                  this._animationForShowAntsi,
                ),
              );
            },
          );
  }

  void changeAnimationi(int newValue) {
    _animationForShowAntsi = newValue;
  }

  void reset() {
    _isReset = true;
  }

  void toggleShowOp(bool isOp) {
    _isOp = isOp;
  }

  void toggleShowFliter(bool isShow) {
    _isShowFliter = isShow;
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      calculatePathDistance(
              widget.visualGraph, _isShowFliter ? _pathRouteOp : _pathRoute)
          .toStringAsFixed(2),
    );
  }

  void toggleShowAnts(bool isShow) {
    _isShowAnts = isShow;
  }

  void toggleShowIter(bool isShow) {
    setState(() {
      _isShowIter = isShow;
    });
  }

  void toggleShowAxis(bool isShow) {
    _isShowAxis = isShow;
  }

  void changeSpeed(int newSpeed) {
    _speed = newSpeed;
  }

  Future<bool> save(String path) async {
    if (_pathRouteOp.isEmpty) return false;
    return await saveRoute(
        path, _pathRouteOp, widget.myMap, widget.visualPoints);
  }

  double _initPathPher() {
    int eage = 0;
    double sum = 0;
    for (int i = 0; i < widget.visualPoints.length - 1; i++) {
      for (int j = i; j < widget.visualPoints.length; j++) {
        if (widget.visualGraph[i][j] > 0) {
          eage++;
          sum += widget.visualGraph[i][j];
        }
      }
    }
    sum /= eage;
    return sum;
  }

  void initPara() {
    _controller.reset();
    _controller.forward();
    _pathRoute.clear();
    _pathRouteOp.clear();
    _preBest.clear();
    _preBestDistance = double.infinity;
    _antsPos.clear();
    _iterationNumValue.clear();
    _currentIter = 0;
    _i = 0;
    _state = 'Running . . .';
    _initPathPhermonone();
    _isReset = false;
  }

  Future<void> run(
    int antsNum,
    double a,
    double b,
    double p,
    double antPheromone,
    int iteration,
  ) async {
    _antsNum = antsNum < 1 ? 1 : antsNum;
    _a = a;
    _b = b;
    _p = p;
    _antPheromone = antPheromone;
    _initPathPhermononeValue = _initPathPher();
    _iterationNum = iteration;
    initPara();
    for (int i = 0; i < _iterationNum; i++) {
      _currentIter = i + 1;
      _setAntsPosition();
      while (true) {
        if (await _selectNextPosForAnts()) break;
        if (_isReset) {
          initPara();
          await Future.delayed(Duration(milliseconds: 1));
          return;
        }
      }
      _updatePathPhermonone();
      // 给折线图积累数据
      _iterationNumValue.add(calculatePathDistance(
        widget.visualGraph,
        _parseFinalRoute(),
      ));
      await Future.delayed(Duration(milliseconds: _speed));
    }
    _pathRoute = _parseFinalRoute();
    if (_pathRoute.isEmpty)
      _state = 'No path !';
    else
      _state = 'Success !';
    _optimisingPath();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      calculatePathDistance(
              widget.visualGraph, _isShowFliter ? _pathRouteOp : _pathRoute)
          .toStringAsFixed(2),
    );
    // 路径生成动画
    _i = _pathRoute.length - 1;
    for (int i = 0; i < _pathRoute.length; i++) {
      _i = i;
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  /// 从信息素解析路径
  List<int> _parseFinalRoute() {
    List<int> pathRoute = [0];
    while (true) {
      Map<int, double> path = {};
      for (int i = 0; i < widget.visualPoints.length; i++)
        if (_pathPhermonone[pathRoute[pathRoute.length - 1]][i] > 0)
          path[i] = _pathPhermonone[pathRoute[pathRoute.length - 1]][i];
      for (int p in pathRoute) path.remove(p);
      double pher = -1;
      int nextP = -1;
      path.forEach((key, value) {
        if (value > pher) {
          nextP = key;
          pher = value;
        }
      });
      if (nextP == -1) {
        pathRoute = [];
        break;
      }
      pathRoute.add(nextP);
      if (pathRoute[pathRoute.length - 1] == widget.visualPoints.length - 1)
        break;
    }
    return pathRoute;
  }

  /// 初始化信息素
  void _initPathPhermonone() {
    _pathPhermonone.clear();
    for (int i = 0; i < widget.visualPoints.length; i++) {
      List<double> tmp = [];
      for (int j = 0; j < widget.visualPoints.length; j++) {
        if (widget.visualGraph[i][j] <= 0)
          tmp.add(0.0);
        else
          tmp.add(_initPathPhermononeValue);
      }
      _pathPhermonone.add(tmp);
    }
  }

  /// 设置蚂蚁初始位置
  void _setAntsPosition() {
    _antsPos.clear();
    for (int i = 0; i < _antsNum; i++) _antsPos.add([0]);
    //_antsPos.add([Random().nextInt(_visualPoints.length - 2)]);
  }

  double _calculateProbability(int p1, int p2) {
    if (widget.visualGraph[p1][p2] <= 0) return 0;
    double pathDistance = widget.visualGraph[p1][p2];
    return pow(_pathPhermonone[p1][p2], _a) * pow(1 / pathDistance, _b);
  }

  /// 每只蚂蚁移动到终点或者绝路
  Future<bool> _selectNextPosForAnts() async {
    bool isAllArrived = true;
    _animationForShowAntsi = 0;
    for (List<int> antPath in _antsPos) {
      if (antPath[antPath.length - 1] == widget.visualPoints.length - 1)
        antPath.add(-2);
      if (antPath[antPath.length - 1] == -2 ||
          antPath[antPath.length - 1] == -1) continue;
      isAllArrived = false;
      List<int> pointToSelected =
          List.generate(widget.visualPoints.length, (i) => i);
      pointToSelected.remove(0);
      for (int pos in antPath) pointToSelected.remove(pos);
      List<double> probabilities = [];
      List<int> points = [];
      for (int i = 0; i < pointToSelected.length; i++) {
        double tmp = _calculateProbability(
          antPath[antPath.length - 1],
          pointToSelected[i],
        );
        if (tmp == 0) continue;
        probabilities.add(tmp);
        points.add(pointToSelected[i]);
      }
      double sum = 0;
      probabilities.forEach((e) => sum += e);
      if (sum == 0) {
        antPath.add(-1);
        continue;
      }
      for (int i = 0; i < probabilities.length; i++) probabilities[i] /= sum;
      try {
        antPath.add(randomChoice(points, probabilities));
      } catch (e) {
        antPath.add(-1);
      }
    }
    // 显示蚂蚁
    while (_animationForShowAntsi < 20 && _isShowAnts)
      await Future.delayed(Duration(milliseconds: 0));
    return isAllArrived;
  }

  /// 更新信息素
  void _updatePathPhermonone() {
    for (int i = 0; i < widget.visualPoints.length - 1; i++)
      for (int j = i; j < widget.visualPoints.length; j++) {
        if (widget.visualGraph[i][j] <= 0) continue;
        if (_pathPhermonone[i][j] > 0.1 || !_isOp)
          _pathPhermonone[i][j] *= (1 - _p);
        _pathPhermonone[j][i] = _pathPhermonone[i][j];
      }

    if (_isOp) {
      // 优化部分
      for (List<int> antPath in _antsPos) {
        if (antPath[antPath.length - 1] != -1) {
          double tmp = calculatePathDistance(
              widget.visualGraph, antPath.sublist(0, antPath.length - 1));
          if (tmp < _preBestDistance) {
            _preBestDistance = tmp;
            _preBest = antPath;
          }
        }
      }
      if (_preBest.isEmpty) return;
      double deltaP = _antPheromone / _preBestDistance;
      for (int i = 0; i < _preBest.length - 2; i++) {
        _pathPhermonone[_preBest[i]][_preBest[i + 1]] += deltaP;
        _pathPhermonone[_preBest[i + 1]][_preBest[i]] =
            _pathPhermonone[_preBest[i]][_preBest[i + 1]];
      }
    } else {
      for (List<int> antPath in _antsPos) {
        if (antPath[antPath.length - 1] != -1) {
          double distance = calculatePathDistance(
              widget.visualGraph, antPath.sublist(0, antPath.length - 1));
          double deltaP = _antPheromone / distance;
          for (int i = 0; i < antPath.length - 2; i++) {
            _pathPhermonone[antPath[i]][antPath[i + 1]] += deltaP;
            _pathPhermonone[antPath[i + 1]][antPath[i]] =
                _pathPhermonone[antPath[i]][antPath[i + 1]];
          }
        }
      }
    }
  }

  /// 过滤掉多余的点
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
        if (widget.visualGraph[currentPoint][_pathRoute[j]] != -1) {
          tmpPoint = _pathRoute[j];
          tmpi = j;
        }
      i = tmpi;
      currentPoint = tmpPoint;
      necessaryPath.add(currentPoint);
      if (necessaryPath[necessaryPath.length - 1] ==
          widget.visualPoints.length - 1) break;
    }
    _pathRouteOp = necessaryPath;
  }
}

class PainteAnt extends MapPainter {
  final List<dynamic> _visualPoints;
  final List<List<double>> _pathPhermonone;
  final int _currentIter;
  final int _i;
  final List<int> _pathRoute;
  final List<int> _pathRouteOp;
  final bool _isShowFliter;
  final List<List<int>> _antsPos;
  final bool _isShowAnts;
  final bool _isShowAxis;
  final String _state;
  final int _animationForShowAntsi;
  PainteAnt(
    _myMap,
    this._visualPoints,
    this._pathPhermonone,
    this._currentIter,
    this._i,
    this._pathRoute,
    this._pathRouteOp,
    this._isShowFliter,
    this._antsPos,
    this._isShowAnts,
    this._isShowAxis,
    this._state,
    this._animationForShowAntsi,
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
    if (_isShowAxis) drawAxis(canvas, size, myPaint, k);
    drawPhermone(canvas, size, myPaint, k);
    if (_isShowFliter)
      super.drawPathRoute(canvas, size, myPaint, k, _pathRouteOp, Colors.green,
          Colors.green.shade900, _pathRouteOp.length);
    else
      super.drawPathRoute(canvas, size, myPaint, k, _pathRoute, Colors.orange,
          Colors.orange.shade900, _i + 1);
    drawRobot(canvas, size, myPaint, k);
    String state = '迭代次数：' + _currentIter.toString() + '  ' + _state;
    drawState(canvas, size, myPaint, k, state);
    if (_isShowAnts) drawAnts(canvas, size, myPaint, k);
  }

  void drawAnts(Canvas canvas, Size size, Paint myPaint, double k) {
    myPaint..color = Colors.black;
    final TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    Map<Offset, int> antPosNum = {};
    _antsPos.asMap().forEach((i, antPath) {
      bool isAlive = false;
      Offset p;
      if (antPath[antPath.length - 1] == -1 ||
          antPath[antPath.length - 1] == -2) {
        p = Offset(
            _visualPoints[antPath[antPath.length - 2]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 2]][0].toDouble() * k +
                (size.height - k * (super.heigth / super.grid)) / 2);
      } else if (antPath.length == 1) {
        p = Offset(
            _visualPoints[antPath[antPath.length - 1]][1].toDouble() * k +
                (size.width - k * (super.width / super.grid)) / 2,
            _visualPoints[antPath[antPath.length - 1]][0].toDouble() * k +
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
        p = p1 + (p2 - p1) * _animationForShowAntsi.toDouble() / 20;
        isAlive = true;
      }
      if (antPosNum.containsKey(p))
        antPosNum[p] += 1;
      else
        antPosNum[p] = 0;
      Offset life = !isAlive
          ? Offset.zero
          : Offset(Random().nextDouble() - 0.5, Random().nextDouble() - 0.5) *
              5;
      canvas.drawCircle(p + life, k * 2, myPaint);
    });
    antPosNum.forEach((p, i) {
      TextSpan span = TextSpan(
        text: (i + 1).toString(),
        style: GoogleFonts.jua(
          textStyle: TextStyle(
            color: Colors.pink.shade300,
            fontSize: k * 6,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      tp..text = span;
      tp.layout();
      tp.paint(canvas, p);
    });
    if (_animationForShowAntsi < 20)
      (showMapKeyForAnt.currentState as ShowMapForAntState)
          .changeAnimationi(_animationForShowAntsi + 1);
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
        double width = (_pathPhermonone[i][j] - miP) /
            (mxP - miP) *
            k *
            (mxP > 10 ? 10 : mxP);
        myPaint
          ..strokeWidth = width < 0.1 * k ? 0.1 * k : width
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, myPaint);
      }
    }
  }
}
