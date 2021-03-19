import 'package:flutter/material.dart';
//import 'package:messengerish/global.dart';

import 'mycircleavatar.dart';

//Color myReceivedColor = Color(0xfff9f9f9);

class ReceivedMessagesWidget extends StatelessWidget {
  final String contactImgUrl;
  final String message;
  final String time;
  const ReceivedMessagesWidget(
      {Key key,
      @required this.contactImgUrl,
      @required this.message,
      @required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: <Widget>[
          MyCircleAvatar(
            imgUrl: contactImgUrl,
            personType: "PATIENT",
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text(
              //   "${messages[i]['contactName']}",
              //   style: Theme.of(context).textTheme.caption,
              // ),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  "$message",
                  style: Theme.of(context).textTheme.body1.apply(
                        color: Colors.black87,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(width: 15),
          Text(
            "$time",
            style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
