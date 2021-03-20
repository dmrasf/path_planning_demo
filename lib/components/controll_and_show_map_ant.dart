import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/my_textfield.dart';
import 'package:path_planning/components/show_map_ant.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/toggle_button.dart';
import 'package:path_planning/components/my_switch_button.dart';

class ControllAndShowMapForAnt extends StatefulWidget {
  final String _fileName;
  ControllAndShowMapForAnt(this._fileName);
  @override
  _ControllAndShowMapForAntState createState() =>
      _ControllAndShowMapForAntState();
}

class _ControllAndShowMapForAntState extends State<ControllAndShowMapForAnt> {
  bool _isShow = false;
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
    _controllerAntsNum.text = "10";
    _controllerA.text = "1";
    _controllerB.text = "0.2";
    _controllerP.text = "0.8";
    _controllerAntPheromone.text = "50";
    _controllerInitPathPheromone.text = "1";
    _controllerIteration.text = "20";
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView(
                    children: [
                      MyTextField(
                        _controllerAntsNum,
                        _focusNodeAntsNum,
                        '蚂蚁数量',
                        'uint',
                        r'^\d+',
                      ),
                      MyTextField(
                        _controllerA,
                        _focusNodeA,
                        '信息素权重',
                        'double',
                        r'^\d+[\.\d]?\d*$',
                      ),
                      MyTextField(
                        _controllerB,
                        _focusNodeB,
                        '路径权重',
                        'double',
                        r'^\d+[\.\d]?\d*$',
                      ),
                      MyTextField(
                        _controllerP,
                        _focusNodeP,
                        '挥发率',
                        '(0, 1)',
                        r'^\d+[\.\d]?\d*$',
                      ),
                      MyTextField(
                        _controllerAntPheromone,
                        _focusNodeAntPheromone,
                        '蚂蚁信息素量',
                        'double',
                        r'^\d+[\.\d]?\d*$',
                      ),
                      MyTextField(
                        _controllerInitPathPheromone,
                        _focusNodeInitPathPheromone,
                        '路径初始信息素',
                        'double',
                        r'^\d+[\.\d]?\d*$',
                      ),
                      MyTextField(
                        _controllerIteration,
                        _focusNodeIteration,
                        '迭代次数',
                        'uint',
                        r'^\d+',
                      ),
                    ],
                  ),
                ),
                Spacer(),
                ShowPathDistance(key: showPathDiatance),
                SizedBox(height: 10),
                MySwitchButton(false, 'Ants'),
                Spacer(),
                //MySlider('Ants'),
                OutlinedButton(
                  onPressed: () {
                    _focusNodeIteration.unfocus();
                    _focusNodeInitPathPheromone.unfocus();
                    _focusNodeAntPheromone.unfocus();
                    _focusNodeP.unfocus();
                    _focusNodeB.unfocus();
                    _focusNodeA.unfocus();
                    _focusNodeAntsNum.unfocus();
                    (showMapKeyForAnt.currentState as ShowMapForAntState).run(
                      int.parse(
                        _controllerAntsNum.text.isEmpty
                            ? '10'
                            : _controllerAntsNum.text,
                      ),
                      double.parse(
                        _controllerA.text.isEmpty ? '1.0' : _controllerA.text,
                      ),
                      double.parse(
                        _controllerB.text.isEmpty ? '0.2' : _controllerB.text,
                      ),
                      double.parse(
                        _controllerP.text.isEmpty ? '0.8' : _controllerP.text,
                      ),
                      double.parse(
                        _controllerAntPheromone.text.isEmpty
                            ? '50'
                            : _controllerAntPheromone.text,
                      ),
                      double.parse(
                        _controllerInitPathPheromone.text.isEmpty
                            ? '1.0'
                            : _controllerInitPathPheromone.text,
                      ),
                      int.parse(
                        _controllerIteration.text.isEmpty
                            ? '20'
                            : _controllerIteration.text,
                      ),
                    );
                  },
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
            child: ShowMapForAnt(
              key: showMapKeyForAnt,
              fileName: widget._fileName,
            ),
          ),
        ),
      ],
    );
  }
}
