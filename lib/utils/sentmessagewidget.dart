import 'package:flutter/material.dart';

//Color mySentColor = Colors.white70;

class SentMessageWidget extends StatelessWidget {
  final String message;
  final String time;
  const SentMessageWidget(
      {Key key, @required this.message, @required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            "$time",
            style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
          ),
          SizedBox(width: 15),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .6),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            child: Text(
              "$message",
              style: Theme.of(context).textTheme.body2.apply(
                    color: Colors.black,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
