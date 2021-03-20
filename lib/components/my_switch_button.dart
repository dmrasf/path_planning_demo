import 'package:flutter/material.dart';
import 'package:path_planning/utils.dart';
import 'package:path_planning/components/show_map_ant.dart';
import 'package:path_planning/components/show_map_a.dart';

class MySwitchButton extends StatefulWidget {
  final String _algorithmName;
  final bool _value;
  MySwitchButton(this._value, this._algorithmName);
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
        Text('过滤：'),
        Switch(
          value: _value,
          onChanged: (newValue) {
            setState(() {
              _value = newValue;
            });
            if (widget._algorithmName == 'A*')
              (showMapKey.currentState as ShowMapForAState)
                  .toggleShowOp(newValue);
            else
              (showMapKeyForAnt.currentState as ShowMapForAntState)
                  .toggleShowOp(newValue);
          },
        ),
      ],
    );
  }
}
