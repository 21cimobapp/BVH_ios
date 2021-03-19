import 'package:civideoconnectapp/src/pages/Index.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/Razorpay.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class FailedPage extends StatefulWidget {
  final PaymentFailureResponse response;

  const FailedPage({Key key, this.response}) : super(key: key);

  @override
  _FailedPageState createState() => _FailedPageState();
}

class _FailedPageState extends State<FailedPage> {
  final Color _backgroundColor = Color(0xFFf0f0f0);

  final TextStyle titleTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 11,
    height: 1,
    letterSpacing: .2,
    fontWeight: FontWeight.w600,
    color: Color(0xffafafaf),
  );
  final TextStyle contentTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        //color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    "assets/images/AppointmentFailed.png",
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Booking Failed",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Your Payment has been failed. Please try again!",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ButtonTheme(
                        //minWidth: 250,
                        height: 40,
                        child: FlatButton(
                          //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IndexNew()));
                          },
                          color: Colors.orangeAccent,
                          disabledColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Text("back to home".toUpperCase(),
                              style: Styles.text(16, Colors.white, true)),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back, color: appBarIconsColor),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      actions: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(right: 18.0),
        //   child: Icon(Icons.more_horiz, color: appBarIconsColor, size: 28),
        // )
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('Failed'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.5,
              color: appBarIconsColor,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
