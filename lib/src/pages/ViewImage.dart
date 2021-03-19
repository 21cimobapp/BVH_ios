import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:civideoconnectapp/data_models/filedata.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class ViewImage extends StatefulWidget {
  final DocumentSnapshot document;

  /// Creates a call page with given channel name.
  const ViewImage({Key key, this.document}) : super(key: key);

  final String title = 'View Image';

  @override
  ViewImageState createState() => ViewImageState();
}

class ViewImageState extends State<ViewImage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _showDetails = true;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          (_showDetails == true) ? _showDetails = false : _showDetails = true;
        });
      },
      child: Container(
          child: Stack(
        children: <Widget>[
          PhotoView(
            imageProvider: NetworkImage(widget.document.data["documentURL"]),
            enableRotation: true,
          ),
          (_showDetails == true)
              ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    color: Colors.transparent,

                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [
                    //       Color.fromARGB(200, 0, 0, 0),
                    //       Color.fromARGB(0, 0, 0, 0)
                    //     ],
                    //     begin: Alignment.bottomCenter,
                    //     end: Alignment.topCenter,
                    //   ),
                    // ),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5.0),
                          child: Text(
                            "${widget.document.data["documentTitle"]}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5.0),
                          color: Colors.black,
                          child: Text(
                            "${DateFormat("dd MMM yyyy").format(widget.document.data["documentDate"].toDate())}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      )),
    );
  }
}
