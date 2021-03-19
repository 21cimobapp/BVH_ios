import 'package:civideoconnectapp/src/pages/Index.dart';
import 'package:civideoconnectapp/src/pages/appointment/RazorPay/Razorpay.dart';
import 'package:flutter/material.dart';

class FailedApptBookPagePayAtHospital extends StatelessWidget {
  // final PaymentSuccessResponse response;
  // FailedApptBookPagePayAtHospital({@required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error while Booking Appointmnet"),
      ),
      body: new Column(
        children: <Widget>[
          new Center(
            child: Container(
              child: Text(
                //"Your payment is successful and the response is\n PaymentId: ${response.paymentId}\nSignature: ${response.signature}",
                "Error Occure while Booking Appointmnent.",
                // Please note your PaymentId: ${response.paymentId}",
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
                  MaterialPageRoute(builder: (context) => IndexPage()),
                );
              }),
        ],
      ),
    );
  }
}
