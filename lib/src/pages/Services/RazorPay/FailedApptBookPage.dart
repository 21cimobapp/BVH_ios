import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/Razorpay.dart';
import 'package:flutter/material.dart';

class FailedApptBookPage extends StatelessWidget {
  final PaymentSuccessResponse response;
  FailedApptBookPage({@required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Success (Error while Booking)"),
      ),
      body: new Column(
        children: <Widget>[
          new Center(
            child: Container(
              child: Text(
                //"Your payment is successful and the response is\n PaymentId: ${response.paymentId}\nSignature: ${response.signature}",
                "Payment Success but error while Booking. Please note your PaymentId: ${response.paymentId}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          new RaisedButton(
              child: Text('Back To Home'),
              textColor: Colors.white,
              color: Colors.cyan,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => IndexNew()),
                );
              }),
        ],
      ),
    );
  }
}
