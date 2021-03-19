import 'package:civideoconnectapp/src/pages/ChatTabScreen.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class ChatMain extends StatefulWidget {
  @override
  _ChatMainState createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              // Tab(
              //   text: 'STATUS',
              // ),
            ],
          ),
          title: Text(
            'MyChat',
            style: TextStyle(fontSize: 21),
          ),
          actions: <Widget>[
            Icon(Icons.search),
            SizedBox(
              width: 15,
            ),
            Icon(Icons.more_vert),
            SizedBox(
              width: 5,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ChatTabScreen(),
            // Icon(Icons.directions_car),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.comment),
        //   backgroundColor: Theme.of(context).accentColor,
        //   onPressed: () {},
        // ),
      ),
    );
  }
}
