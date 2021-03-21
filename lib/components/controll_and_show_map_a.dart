import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/my_textfield.dart';
import 'package:path_planning/components/show_map_a.dart';
import 'package:path_planning/components/show_distance.dart';
import 'package:path_planning/components/toggle_button.dart';
import 'package:path_planning/components/my_slider.dart';
import 'package:path_planning/components/my_button.dart';
import 'package:path_planning/components/my_switch_button.dart';

class ControllAndShowMapForA extends StatefulWidget {
  final String _fileName;
  ControllAndShowMapForA(this._fileName);
  @override
  _ControllAndShowMapForAState createState() => _ControllAndShowMapForAState();
}

class _ControllAndShowMapForAState extends State<ControllAndShowMapForA> {
  bool _isShow = false;
  TextEditingController _controllerH = TextEditingController();
  TextEditingController _controllerG = TextEditingController();
  FocusNode _focusNodeH = FocusNode();
  FocusNode _focusNodeG = FocusNode();

  @override
  void initState() {
    _controllerG.text = '1';
    _controllerH.text = '1';
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
                      this._controllerH,
                      this._focusNodeH,
                      'H 权重',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                    MyTextField(
                      this._controllerG,
                      this._focusNodeG,
                      'G 权重',
                      'double',
                      r'^\d+[\.\d]?\d*$',
                    ),
                  ],
                ),
                ShowPathDistance(key: showPathDiatance),
                MySwitchButton(false, 'A*', '过滤', 0),
                MySlider('A*'),
                MyButton(() {
                  _focusNodeH.unfocus();
                  _focusNodeG.unfocus();
                  (showMapKey.currentState as ShowMapForAState).run(
                    double.parse(
                      _controllerH.text.isEmpty ? '1.0' : _controllerH.text,
                    ),
                    double.parse(
                      _controllerG.text.isEmpty ? '1.0' : _controllerG.text,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        ToggleButton(
          () => setState(() {
            _isShow = !_isShow;
            _focusNodeH.unfocus();
          }),
          _isShow,
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.all(15),
            child: ShowMapForA(key: showMapKey, fileName: widget._fileName),
          ),
        ),
      ],
    );
  }
}
