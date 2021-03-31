import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/components/my_painter.dart';
import 'package:path_planning/components/my_button.dart';
import 'package:path_planning/components/my_textfield.dart';
import 'package:path_planning/utils.dart';
import 'dart:convert';
import 'package:path_planning/pages/map_show.dart';

class RandomMapShow extends StatefulWidget {
  final String _algorithmName;
  RandomMapShow(this._algorithmName);
  @override
  _RandomMapShowState createState() => _RandomMapShowState();
}

class _RandomMapShowState extends State<RandomMapShow> {
  Map<String, dynamic> _walls;
  TextEditingController _controllerWB = TextEditingController();
  TextEditingController _controllerHB = TextEditingController();
  TextEditingController _controllerBS = TextEditingController();
  TextEditingController _controllerWT = TextEditingController();
  TextEditingController _controllerB = TextEditingController();
  TextEditingController _controllerRE = TextEditingController();
  FocusNode _focusNodeWB = FocusNode();
  FocusNode _focusNodeHB = FocusNode();
  FocusNode _focusNodeBS = FocusNode();
  FocusNode _focusNodeWT = FocusNode();
  FocusNode _focusNodeB = FocusNode();
  FocusNode _focusNodeRE = FocusNode();

  @override
  void initState() {
    super.initState();
    _getNewMap();
  }

  void _getNewMap() {
    _focusNodeRE.unfocus();
    _focusNodeWT.unfocus();
    _focusNodeBS.unfocus();
    _focusNodeHB.unfocus();
    _focusNodeB.unfocus();
    _focusNodeWB.unfocus();
    _walls = RandomMapGeneration(
      widthBlock:
          _controllerWB.text.isEmpty ? 20 : int.parse(_controllerWB.text),
      heigthBlock:
          _controllerHB.text.isEmpty ? 20 : int.parse(_controllerHB.text),
      blankSize:
          _controllerBS.text.isEmpty ? 1.2 : double.parse(_controllerBS.text),
      wallThickness:
          _controllerWT.text.isEmpty ? 0.1 : double.parse(_controllerWT.text),
      border: _controllerB.text.isEmpty ? 0.4 : double.parse(_controllerB.text),
      isRemove: _controllerRE.text.isEmpty
          ? true
          : int.parse(_controllerRE.text) == 0
              ? false
              : true,
    ).randomMapGeneration();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random map'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              boxShadow: [BoxShadow(color: Color(0x2f000000), blurRadius: 1.0)],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Setting parameters',
                  style: GoogleFonts.asar(
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                Column(
                  children: [
                    MyTextField(
                      _controllerWB,
                      _focusNodeWB,
                      '宽',
                      '[2-30]',
                      r'^\d+',
                    ),
                    MyTextField(
                      _controllerHB,
                      _focusNodeHB,
                      '高',
                      '[2-30]',
                      r'^\d+',
                    ),
                    MyTextField(
                      _controllerBS,
                      _focusNodeBS,
                      '空白大小',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                    MyTextField(
                      _controllerWT,
                      _focusNodeWT,
                      '墙宽',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                    MyTextField(
                      _controllerRE,
                      _focusNodeRE,
                      'remove',
                      'bool',
                      r'[0-1]',
                    ),
                  ],
                ),
                MyButton(_getNewMap, 'REFRESH'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.1,
                horizontal: MediaQuery.of(context).size.width * 0.1,
              ),
              child: _walls.isEmpty
                  ? Container()
                  : CustomPaint(
                      painter: PainteRandomMap(_walls),
                      size: MediaQuery.of(context).size,
                    ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _walls.isEmpty
            ? null
            : fadeChangePage(
                context,
                MapShow(widget._algorithmName, jsonEncode(_walls)),
              ),
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

class PainteRandomMap extends MapPainter {
  PainteRandomMap(
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
