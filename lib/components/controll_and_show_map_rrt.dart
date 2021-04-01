import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/my_textfield.dart';
import 'package:path_planning/components/show_map_rrt.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/toggle_button.dart';
import 'package:path_planning/components/my_slider.dart';
import 'package:path_planning/components/my_button.dart';
import 'package:path_planning/components/my_switch_button.dart';

class ControllAndShowMapForRRT extends StatefulWidget {
  final Map<String, dynamic> _myMap;
  final List<dynamic> _visualPoints;
  final List<dynamic> _visualGraph;
  ControllAndShowMapForRRT(this._myMap, this._visualGraph, this._visualPoints);
  @override
  _ControllAndShowMapForRRTState createState() =>
      _ControllAndShowMapForRRTState();
}

class _ControllAndShowMapForRRTState extends State<ControllAndShowMapForRRT> {
  bool _isShow = true;
  TextEditingController _controllerR = TextEditingController();
  TextEditingController _controllerI = TextEditingController();
  FocusNode _focusNodeR = FocusNode();
  FocusNode _focusNodeI = FocusNode();

  @override
  void initState() {
    _controllerR.text = '3';
    _controllerI.text = '10000';
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
                      this._controllerR,
                      this._focusNodeR,
                      '半径',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                    MyTextField(
                      this._controllerI,
                      this._focusNodeI,
                      '次数',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                  ],
                ),
                ShowPathDistance(key: showPathDiatance),
                Column(
                  children: [
                    MySwitchButton(false, 'RRT*', '过滤', SwitchType.Op),
                    MySwitchButton(false, 'RRT*', '坐标', SwitchType.Axis),
                  ],
                ),
                MySlider('RRT*'),
                Column(
                  children: [
                    MyButton(() {
                      String s = '';
                      (showMapKeyForRRT.currentState as ShowMapForRRTState)
                          .save('/home/dmr/test.json')
                          .then(
                              (value) => value ? s = 'Success' : s = 'Failure')
                          .onError((error, stackTrace) => s = 'Error')
                          .whenComplete(
                            () => showSnakBar(context, s),
                          );
                    }, 'SAVE'),
                    SizedBox(height: 10),
                    MyButton(() {
                      _focusNodeR.unfocus();
                      _focusNodeI.unfocus();
                      (showMapKeyForRRT.currentState as ShowMapForRRTState).run(
                        double.parse(
                          _controllerR.text.isEmpty ? '1.0' : _controllerR.text,
                        ),
                        int.parse(
                          _controllerI.text.isEmpty ? '1.0' : _controllerI.text,
                        ),
                      );
                    }, 'START'),
                  ],
                ),
              ],
            ),
          ),
        ),
        ToggleButton(
          () => setState(() {
            _focusNodeR.unfocus();
            _focusNodeI.unfocus();
            _isShow = !_isShow;
          }),
          _isShow,
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(30),
            child: ShowMapForRRT(
              key: showMapKeyForRRT,
              myMap: widget._myMap,
              visualGraph: widget._visualGraph,
              visualPoints: widget._visualPoints,
            ),
          ),
        ),
      ],
    );
  }
}
