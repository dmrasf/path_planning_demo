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
  String _mapName;
  String _type;
  List<dynamic> _barriers;
  double _blankSize;
  double _wallThickness;
  double _border;
  int _widthBlock;
  int _heigthBlock;
  List<dynamic> _horizontalWall;
  List<dynamic> _verticalWall;

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
    Color lineColor,
    Color textColor,
    int len,
  ) {
    if (pathRoute.isEmpty ||
        (pathRoute[pathRoute.length - 1] != _visualPoints.length - 1 &&
            pathRoute[pathRoute.length - 1] != 0)) return;
    myPaint
      ..color = lineColor
      ..strokeCap = StrokeCap.round
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
            color: textColor,
            fontSize: k * 10,
          ),
        ),
      );
      tp..text = span;
      tp.layout();
      tp.paint(canvas, p1 + Offset(4, 4));
    }
  }

  bool parseData() {
    try {
      _type = _myMap['type'];
    } catch (e) {
      print(e.toString());
      return false;
    }
    if (_type == 'custom map') {
      try {
        _width = _myMap['width'].toDouble();
        _heigth = _myMap['heigth'].toDouble();
        _grid = _myMap['grid'].toDouble();
        _robotSize = _myMap['robotSize'].toDouble();
        _barriers = _myMap['barriers'];
        _mapName = _myMap['name'];
      } catch (e) {
        print(e.toString());
        return false;
      }
    } else if (_type == 'random map') {
      try {
        _widthBlock = _myMap['widthBlock'].toInt();
        _heigthBlock = _myMap['heigthBlock'].toInt();
        _blankSize = _myMap['blankSize'].toDouble();
        _border = _myMap['border'].toDouble();
        _wallThickness = _myMap['wallThickness'].toDouble();
        _width = _border * 2 +
            _blankSize * _widthBlock +
            _wallThickness * (_widthBlock - 1);
        _heigth = _border * 2 +
            _blankSize * _heigthBlock +
            _wallThickness * (_heigthBlock - 1);
        _grid = _myMap['grid'].toDouble();
        _robotSize = _myMap['robotSize'].toDouble();
        _mapName = _myMap['name'];
        _horizontalWall = _myMap['horizontal'];
        _verticalWall = _myMap['vertical'];
      } catch (e) {
        print(e.toString());
        return false;
      }
    }
    return true;
  }

  void drawBarriers(Canvas canvas, Size size, Paint myPaint, double k) {
    double addHeight = (size.height - k * (_heigth / _grid)) / 2;
    double addWidth = (size.width - k * (_width / _grid)) / 2;
    if (_type == 'custom map') {
      for (int i = 0; i < _barriers.length; i++) {
        Path path = Path();
        for (int j = 0; j < _barriers[i].length; j++) {
          double y = _barriers[i][j]['pointX'] / _grid * k + addHeight;
          double x = _barriers[i][j]['pointY'] / _grid * k + addWidth;
          if (j == 0)
            path..moveTo(x, y);
          else
            path..lineTo(x, y);
        }
        path..close();
        canvas.drawPath(path, myPaint);
      }
    } else if (_type == 'random map') {
      Size wallH = Size(_wallThickness / _grid * k,
          (_blankSize + _wallThickness * 2) / _grid * k);
      Size wallW = Size((_blankSize + _wallThickness * 2) / _grid * k,
          _wallThickness / _grid * k);
      for (int i = 0; i < _horizontalWall.length; i++) {
        for (int j = 0; j < _horizontalWall[i].length; j++) {
          if (_horizontalWall[i][j] == 0) continue;
          Offset p = Offset(
            (_border + _blankSize * j + _wallThickness * (j - 1)) / _grid * k +
                addWidth,
            (_border + _blankSize * (i + 1) + _wallThickness * i) / _grid * k +
                addHeight,
          );
          canvas.drawRect(p & wallW, myPaint);
        }
      }
      for (int i = 0; i < _verticalWall.length; i++) {
        for (int j = 0; j < _verticalWall[i].length; j++) {
          if (_verticalWall[i][j] == 0) continue;
          Offset p = Offset(
            (_border + _blankSize * (i + 1) + _wallThickness * i) / _grid * k +
                addWidth,
            (_border + _blankSize * j + _wallThickness * (j - 1)) / _grid * k +
                addHeight,
          );
          canvas.drawRect(p & wallH, myPaint);
        }
      }
      Offset leftTop = Offset(
        (_border - _wallThickness) / _grid * k + addWidth,
        (_border - _wallThickness) / _grid * k + addHeight,
      );
      double width = (_width - 2 * _border + 2 * _wallThickness) / _grid * k;
      double heigth = (_heigth - 2 * _border + 2 * _wallThickness) / _grid * k;
      canvas.drawRect(
        leftTop & Size(_wallThickness / _grid * k, heigth),
        myPaint,
      );
      canvas.drawRect(
        leftTop + Offset(width - _wallThickness / _grid * k, 0) &
            Size(_wallThickness / _grid * k, heigth),
        myPaint,
      );
      double inte = (_robotSize / 2 + _wallThickness) / _grid * k;
      canvas.drawRect(
        leftTop + Offset(inte, 0) &
            Size(width - inte, _wallThickness / _grid * k),
        myPaint,
      );
      canvas.drawRect(
        leftTop + Offset(0, heigth - _wallThickness / _grid * k) &
            Size(width, _wallThickness / _grid * k),
        myPaint,
      );
    }
  }

  void drawAxis(Canvas canvas, Size size, Paint myPaint, double k) {
    double minY = (size.height - k * (_heigth / _grid)) / 2;
    double maxY = _heigth / _grid * k + minY;
    double minX = (size.width - k * (_width / _grid)) / 2;
    double maxX = _width / _grid * k + minX;
    double mPp = (maxY - minY) / _heigth;
    myPaint
      ..strokeWidth = 1
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeCap = StrokeCap.round;
    TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    int m = 0;
    TextStyle textStyle = GoogleFonts.jua(
        textStyle: TextStyle(
      color: Colors.grey.withOpacity(0.9),
      fontSize: k * 8,
    ));
    for (double i = minX; i <= maxX; i += mPp) {
      canvas.drawLine(Offset(i, minY), Offset(i, maxY), myPaint);
      canvas.drawCircle(Offset(i, maxY), 2, myPaint);
      tp
        ..text = TextSpan(
          text: m.toString(),
          style: textStyle,
        );
      tp.layout();
      if (i == maxX) continue;
      tp.paint(canvas, Offset(i, maxY));
      m++;
    }
    m = 0;
    for (double i = minY; i <= maxY; i += mPp) {
      canvas.drawLine(Offset(minX, i), Offset(maxX, i), myPaint);
      canvas.drawCircle(Offset(maxX, i), 2, myPaint);
      tp
        ..text = TextSpan(
          text: m.toString(),
          style: textStyle,
        );
      tp.layout();
      if (i == maxY) continue;
      tp.paint(canvas, Offset(maxX, i));
      m++;
    }
  }

  void drawName(Canvas canvas, Size size, Paint myPaint, double k) {
    TextSpan span = TextSpan(
      text: _mapName,
      style: GoogleFonts.jua(
        textStyle: TextStyle(
          color: Colors.black.withOpacity(0.1),
          fontSize: 100,
        ),
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(0, size.height / 2));
  }

  void drawState(
      Canvas canvas, Size size, Paint myPaint, double k, String state) {
    TextSpan span = TextSpan(
      text: state,
      style: GoogleFonts.jua(
        textStyle: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
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
