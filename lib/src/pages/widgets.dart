import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final String text;

  const SubTitle({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(' $text',
            style: TextStyle(color: Colors.white, fontSize: 14.0)));
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String prefix;

  const PhoneNumberField({Key key, this.controller, this.prefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Text("  " + prefix + "  ", style: TextStyle(fontSize: 16.0)),
          SizedBox(width: 8.0),
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: false,
              keyboardType: TextInputType.phone,
              key: Key('EnterPhone-TextFormField'),
              decoration: InputDecoration(
                border: InputBorder.none,
                errorMaxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
