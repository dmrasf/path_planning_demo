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
  double _currentSliderValue = 500;
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 100,
      max: 2000,
      divisions: 5,
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
