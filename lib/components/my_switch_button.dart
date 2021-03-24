import 'package:flutter/material.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/show_map_ant.dart';
import 'package:path_planning/components/show_map_a.dart';
import 'package:path_planning/components/show_map_rrt.dart';

class MySwitchButton extends StatefulWidget {
  final String _algorithmName;
  final bool _value;
  final String _name;
  final SwitchType _type;
  MySwitchButton(this._value, this._algorithmName, this._name, this._type);
  @override
  _MySwitchButtonState createState() => _MySwitchButtonState();
}

class _MySwitchButtonState extends State<MySwitchButton> {
  bool _value;

  @override
  void initState() {
    _value = widget._value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget._name + '：'),
        Switch(
          value: _value,
          onChanged: (newValue) {
            setState(() {
              _value = newValue;
            });
            if (widget._type == SwitchType.Op) {
              if (widget._algorithmName == 'A*')
                (showMapKeyForA.currentState as ShowMapForAState)
                    .toggleShowOp(newValue);
              else if (widget._algorithmName == 'Ant Colony')
                (showMapKeyForAnt.currentState as ShowMapForAntState)
                    .toggleShowOp(newValue);
              else if (widget._algorithmName == 'RRT*')
                (showMapKeyForRRT.currentState as ShowMapForRRTState)
                    .toggleShowOp(newValue);
            } else if (widget._type == SwitchType.Ants) {
              if (widget._algorithmName == 'Ant Colony')
                (showMapKeyForAnt.currentState as ShowMapForAntState)
                    .toggleShowAnts(newValue);
            } else if (widget._type == SwitchType.Axis) {
              if (widget._algorithmName == 'A*')
                (showMapKeyForA.currentState as ShowMapForAState)
                    .toggleShowAxis(newValue);
              else if (widget._algorithmName == 'Ant Colony')
                (showMapKeyForAnt.currentState as ShowMapForAntState)
                    .toggleShowAxis(newValue);
              else if (widget._algorithmName == 'RRT*')
                (showMapKeyForRRT.currentState as ShowMapForRRTState)
                    .toggleShowAxis(newValue);
            }
          },
        ),
      ],
    );
  }
}
