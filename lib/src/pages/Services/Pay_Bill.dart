import 'package:flutter/material.dart';
import 'checkout.dart';
import 'class.dart';

class PayBill extends StatefulWidget {
  @override
  BillPage createState() => BillPage();
}

class BillPage extends State<PayBill> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Payment'),
      ),
      body: new Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              "Your Payment made for Rs. ${bloc.total} /-",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
