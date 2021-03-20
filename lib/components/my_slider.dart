import 'package:flutter/material.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/show_map_a.dart';
import 'package:path_planning/components/show_map_ant.dart';

class MySlider extends StatefulWidget {
  final String _type;
  MySlider(this._type);
  @override
  _MySliderState createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  double _currentSliderValue = 300;
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 10,
      max: 1000,
      divisions: 150,
      label: _currentSliderValue.toInt().toString() + ' ms',
      onChanged: (double newValue) {
        setState(() {
          _currentSliderValue = newValue;
        });
        if (widget._type == 'A*')
          (showMapKey.currentState as ShowMapForAState).changeSpeed(
            newValue.toInt(),
          );
        else
          (showMapKeyForAnt.currentState as ShowMapForAntState).changeSpeed(
            newValue.toInt(),
          );
      },
    );
  }
}
