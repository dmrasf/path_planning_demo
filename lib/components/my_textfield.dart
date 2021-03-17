import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController _controller;
  final FocusNode _focusNode;
  final String _name;
  MyTextField(this._controller, this._focusNode, this._name);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: 1,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(4),
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d+[\.\d]?\d*$'),
          ),
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          labelText: _name,
          hintText: 'double',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }
}
