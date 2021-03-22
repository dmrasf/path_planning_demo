import 'package:flutter/material.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/show_map_ant.dart';
import 'package:path_planning/components/show_map_a.dart';

class MySwitchButton extends StatefulWidget {
  final String _algorithmName;
  final bool _value;
  final String _name;
  final int _type;
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
            if (widget._type == 0) {
              if (widget._algorithmName == 'A*')
                (showMapKey.currentState as ShowMapForAState)
                    .toggleShowOp(newValue);
              else
                (showMapKeyForAnt.currentState as ShowMapForAntState)
                    .toggleShowOp(newValue);
            } else if (widget._type == 1) {
              (showMapKeyForAnt.currentState as ShowMapForAntState)
                  .toggleShowAnts(newValue);
            } else if (widget._type == 2) {
              if (widget._algorithmName == 'A*')
                (showMapKey.currentState as ShowMapForAState)
                    .toggleShowAxis(newValue);
              else
                (showMapKeyForAnt.currentState as ShowMapForAntState)
                    .toggleShowAxis(newValue);
            }
          },
        ),
      ],
    );
  }
}
