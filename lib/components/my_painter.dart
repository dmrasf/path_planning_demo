import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  final Map<String, dynamic> _myMap;
  final List<dynamic> _visualPoints;
  MapPainter(
    this._myMap,
    this._visualPoints,
  );
  double _width;
  double _heigth;
  double _grid;
  double _robotSize;
  List<dynamic> _barriers;

  double get width => _width;
  double get heigth => _heigth;
  double get grid => _grid;
  double get robotSize => _robotSize;

  Offset getOffset(Size size, double k, int i, List<int> tmpPath) {
    return Offset(
        _visualPoints[tmpPath[i]][1].toDouble() * k +
            (size.width - k * (_width / _grid)) / 2,
        _visualPoints[tmpPath[i]][0].toDouble() * k +
            (size.height - k * (_heigth / _grid)) / 2);
  }

  void drawRobot(Canvas canvas, Size size, Paint myPaint, double k) {
    for (int i = 0; i < _visualPoints.length; i++) {
      if (i == 0 || i == _visualPoints.length - 1)
        myPaint..color = Colors.red;
      else
        myPaint..color = Color(0x5f000000);
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

  void drawPathRoute(
    Canvas canvas,
    Size size,
    Paint myPaint,
    double k,
    List<int> pathRoute,
    Color color,
    int len,
  ) {
    if (pathRoute.isEmpty ||
        (pathRoute[pathRoute.length - 1] != _visualPoints.length - 1 &&
            pathRoute[pathRoute.length - 1] != 0)) return;
    myPaint
      ..color = color
      ..strokeWidth = k * 4;
    final TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    TextSpan span = TextSpan();
    for (int i = 0; i < len; i++) {
      Offset p1 = getOffset(size, k, i, pathRoute);
      if (i < pathRoute.length - 1) {
        Offset p2 = getOffset(size, k, i + 1, pathRoute);
        canvas.drawLine(p1, p2, myPaint);
      }
      span = TextSpan(
        text: i.toString(),
        style: GoogleFonts.jua(
          textStyle: TextStyle(
            color: color,
            fontSize: k * 10,
          ),
        ),
      );
      tp..text = span;
      tp.layout();
      tp.paint(canvas, p1 + Offset(4, 4));
    }
    myPaint..color = color;
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

  void drawAxis(Canvas canvas, Size size, Paint myPaint, double k) {
    double minY = (size.height - k * (_heigth / _grid)) / 2;
    double maxY = _heigth / _grid * k + minY;
    double minX = (size.width - k * (_width / _grid)) / 2;
    double maxX = _width / _grid * k + minX;
    Offset p1 = Offset(minX, maxY);
    Offset p2 = Offset(maxX, maxY);
    myPaint
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p1, p2, myPaint);
    p1 = Offset(maxX, minY);
    p2 = Offset(maxX, maxY);
    canvas.drawLine(p1, p2, myPaint);
    double mPp = (maxY - minY) / _heigth;
    TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    int m = 0;
    for (double i = minX; i <= maxX; i += mPp) {
      canvas.drawCircle(Offset(i, maxY), 2, myPaint);
      tp
        ..text = TextSpan(
          text: m.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        );
      tp.layout();
      tp.paint(canvas, Offset(i, maxY));
      m++;
    }
    m = 0;
    for (double i = minY; i <= maxY; i += mPp) {
      canvas.drawCircle(Offset(maxX, i), 2, myPaint);
      tp
        ..text = TextSpan(
          text: m.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        );
      tp.layout();
      tp.paint(canvas, Offset(maxX, i));
      m++;
    }
  }

  void drawState(
      Canvas canvas, Size size, Paint myPaint, double k, String state) {
    TextSpan span = TextSpan(
      text: state,
      style: TextStyle(
        color: Colors.black,
        fontSize: k * 10,
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

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
