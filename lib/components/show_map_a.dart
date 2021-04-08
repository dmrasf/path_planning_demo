import 'package:flutter/material.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ShowMapForA extends StatefulWidget {
  final Map<String, dynamic> myMap;
  final List<dynamic> visualPoints;
  final List<dynamic> visualGraph;
  ShowMapForA({
    Key key,
    @required this.myMap,
    @required this.visualGraph,
    @required this.visualPoints,
  }) : super(key: key);
  @override
  ShowMapForAState createState() => ShowMapForAState();
}

class ShowMapForAState extends State<ShowMapForA>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Set _openPoints = Set();
  Set _closePoints = Set();
  Map<int, int> _tree = Map<int, int>();
  Map<int, double> _pointToStartDis = Map<int, double>();
  Map<int, double> _openPointsValue = Map<int, double>();
  bool _isOp = false;
  List<int> _pathRoute = [];
  int _speed = 300;
  int _i = 0;
  String _state = '';
  bool _isShowAxis = false;
  bool _isShowTree = false;
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
    _isReset = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: PainteA(
            widget.myMap,
            widget.visualPoints,
            this._openPoints,
            this._openPointsValue,
            this._tree,
            this._closePoints,
            this._pathRoute,
            this._isShowAxis,
            this._isShowTree,
            this._state,
            this._i,
          ),
        );
      },
    );
  }

  /// 改变动画速度
  void changeSpeed(int newSpeed) {
    _speed = newSpeed;
  }

  void reset() {
    _isReset = true;
  }

  /// 是否显示坐标轴
  void toggleShowAxis(bool isShow) {
    _isShowAxis = isShow;
  }

  /// 是否显示构造的树
  void toggleShowTree(bool isShow) {
    _isShowTree = isShow;
  }

  /// 是否优化
  void toggleShowOp(bool isShow) {
    _isOp = isShow;
  }

  /// 保存计算出的点
  Future<bool> save(String path) async {
    if (_pathRoute.isEmpty) return false;
    return await saveRoute(path, _pathRoute, widget.myMap, widget.visualPoints);
  }

  void initPara() {
    _controller.reset();
    _controller.forward();
    _closePoints.clear();
    _openPoints.clear();
    _openPointsValue.clear();
    _tree.clear();
    _pathRoute.clear();
    _isReset = false;
    _i = 0;
  }

  void run(double hWeight, double gWeight) async {
    if (hWeight + gWeight == 0) {
      showSnakBar(context, '参数不能同时为0');
      return;
    }
    initPara();
    int start = 0;
    int end = widget.visualPoints.length - 1;
    int currentPoint = start;
    _closePoints.add(currentPoint);
    List<int> newPoint = [];
    while (true) {
      if (_isReset) {
        initPara();
        await Future.delayed(Duration(milliseconds: 1));
        return;
      }
      newPoint = _updateOpenPoints(currentPoint);
      // 优化部分
      if (_isOp) _changeParent(newPoint);
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
      // 两种判断结束的标志
      if (_isOp) {
        if (_tree.containsKey(end)) break;
      } else {
        if (_closePoints.contains(end)) break;
      }
    }
    _state = 'Success !';
    _parsePathRoute();
    (showPathDiatance.currentState as ShowPathDistanceState).update(
      calculatePathDistance(widget.visualGraph, _pathRoute).toStringAsFixed(2),
    );
    for (int i = 0; i < _pathRoute.length; i++) {
      _i = i;
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  /// 从所有可选点中，通过启发函数，得出最优点
  int _findNextPoint(
    int currentPoint,
    double hWeight,
    double gWeight,
  ) {
    _openPointsValue.clear();
    double minDistance = double.infinity;
    int bestPoint;
    int end = widget.visualPoints.length - 1;
    double grid = widget.myMap['grid'];
    for (int p in _openPoints) {
      double h = pow(
        pow((widget.visualPoints[end][0] - widget.visualPoints[p][0]) * grid,
                2) +
            pow(
                (widget.visualPoints[end][1] - widget.visualPoints[p][1]) *
                    grid,
                2),
        0.5,
      );
      double g = _calculatePathDis(p, false);
      double f = h * hWeight + g * gWeight;
      _openPointsValue[p] = f;
      if (f < minDistance) {
        minDistance = f;
        bestPoint = p;
      }
    }
    return bestPoint;
  }

  /// 更新可以访问的点，并返回新加入的点
  List<int> _updateOpenPoints(int currentPoint) {
    List<int> newPoint = [];
    for (int i = 0; i < widget.visualPoints.length; i++) {
      if (widget.visualGraph[currentPoint][i] > 0 &&
          !_openPoints.contains(i) &&
          !_closePoints.contains(i)) {
        _tree[i] = currentPoint;
        _openPoints.add(i);
        newPoint.add(i);
      }
    }
    return newPoint;
  }

  /// 优化函数，修改新加入点的父结点
  void _changeParent(List<int> newPoint) {
    List<int> oldParent =
        List.generate(newPoint.length, (i) => _tree[newPoint[i]]);
    while (true) {
      for (int p in newPoint) {
        double distance = _calculatePathDis(p, true);
        for (int parent in _closePoints.union(_openPoints)) {
          double tmp = widget.visualGraph[parent][p];
          if (tmp <= 0) continue;
          double parentDis = newPoint.contains(parent)
              ? _calculatePathDis(parent, true)
              : _calculatePathDis(parent, false);
          if (tmp + parentDis < distance) {
            distance = tmp + parentDis;
            _tree[p] = parent;
          }
        }
      }
      List<int> newParent =
          List.generate(newPoint.length, (i) => _tree[newPoint[i]]);
      Set diff = newParent.toSet().difference(oldParent.toSet());
      if (diff.length == 0) break;
      oldParent = List.from(newParent);
    }
  }

  double _calculatePathDis(int p, bool isReCal) {
    if (!_pointToStartDis.containsKey(p) || isReCal) {
      double dis = 0;
      List<int> path = [p];
      while (path[path.length - 1] != 0) {
        path.add(_tree[path[path.length - 1]]);
        dis = dis +
            widget.visualGraph[path[path.length - 1]][path[path.length - 2]];
      }
      _pointToStartDis[p] = dis;
    }
    return _pointToStartDis[p];
  }

  /// 从树中解析路径
  void _parsePathRoute() {
    _pathRoute = [widget.visualPoints.length - 1];
    _pathRoute = [widget.visualPoints.length - 1];
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
  final bool _isShowAxis;
  final bool _isShowTree;
  final int _i;
  PainteA(
    _myMap,
    this._visualPoints,
    this._openPoints,
    this._openPointsValue,
    this._tree,
    this._closePoints,
    this._pathRoute,
    this._isShowAxis,
    this._isShowTree,
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
    super.drawPathRoute(canvas, size, myPaint, k, _pathRoute, Colors.orange,
        Colors.orange.shade900, _i + 1);
    super.drawRobot(canvas, size, myPaint, k);
    if (_isShowTree) drawTree(canvas, size, myPaint, k);
    drawSet(canvas, size, myPaint, k);
    super.drawState(canvas, size, myPaint, k, _state);
  }

  void drawSet(Canvas canvas, Size size, Paint myPaint, double k) {
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
        double ma = _openPointsValue.values.reduce(max);
        double mi = _openPointsValue.values.reduce(min);
        double fontSize = k * (7 - 3 * (_openPointsValue[p] - mi) / (ma - mi));
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
        ..strokeWidth = k * 0.5
        ..color = Colors.green.shade600
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, myPaint);
    });
  }
}
