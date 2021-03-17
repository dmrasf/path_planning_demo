import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/my_textfield.dart';
import 'package:path_planning/components/show_map_a.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/toggle_button.dart';

class ControllAndShowMapForAnt extends StatefulWidget {
  final String _fileName;
  ControllAndShowMapForAnt(this._fileName);
  @override
  _ControllAndShowMapForAntState createState() =>
      _ControllAndShowMapForAntState();
}

class _ControllAndShowMapForAntState extends State<ControllAndShowMapForAnt> {
  bool _isShow = true;
  TextEditingController _controllerAntsNum = TextEditingController();
  TextEditingController _controllerA = TextEditingController();
  TextEditingController _controllerB = TextEditingController();
  TextEditingController _controllerP = TextEditingController();
  TextEditingController _controllerAntPheromone = TextEditingController();
  TextEditingController _controllerInitPathPheromone = TextEditingController();
  TextEditingController _controllerIteration = TextEditingController();
  FocusNode _focusNodeAntsNum = FocusNode();
  FocusNode _focusNodeA = FocusNode();
  FocusNode _focusNodeB = FocusNode();
  FocusNode _focusNodeP = FocusNode();
  FocusNode _focusNodeAntPheromone = FocusNode();
  FocusNode _focusNodeInitPathPheromone = FocusNode();
  FocusNode _focusNodeIteration = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Offstage(
          offstage: !_isShow,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x2f000000), blurRadius: 1.0)],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Text(
                  'Setting params',
                  style: GoogleFonts.exo(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                MyTextField(_controllerAntsNum, _focusNodeAntsNum, '蚂蚁数量'),
                MyTextField(_controllerA, _focusNodeA, '信息素权重'),
                MyTextField(_controllerB, _focusNodeB, '路径权重'),
                MyTextField(_controllerP, _focusNodeP, '挥发率'),
                MyTextField(
                  _controllerAntPheromone,
                  _focusNodeAntPheromone,
                  '蚂蚁信息素量',
                ),
                MyTextField(
                  _controllerInitPathPheromone,
                  _focusNodeInitPathPheromone,
                  '路径初始信息素',
                ),
                MyTextField(_controllerIteration, _focusNodeIteration, '迭代次数'),
                Spacer(),
                ShowPathDistance(key: showPathDiatance),
                Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    'START',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(
                      width: 2,
                      color: Color(0x6f000000),
                    )),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    )),
                    foregroundColor: MaterialStateProperty.all(
                      Color(0xaf000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ToggleButton(
          () => setState(() {
            _isShow = !_isShow;
          }),
          _isShow,
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(15),
            //child: ShowMapForA(key: showMapKey, fileName: widget._fileName),
          ),
        ),
      ],
    );
  }
}
