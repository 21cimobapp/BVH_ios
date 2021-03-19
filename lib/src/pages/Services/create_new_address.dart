import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'class.dart';
import 'Pay_Bill.dart';
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/data_models/service_order_slots.dart';
import 'package:civideoconnectapp/data_models/BookingDetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/CheckRazor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNewAddress extends StatefulWidget {
  final String serviceType;

  const CreateNewAddress({Key key, this.serviceType}) : super(key: key);

  @override
  _createNewAddress createState() => _createNewAddress();
}

class _createNewAddress extends State<CreateNewAddress> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  bool _disposed = false;
  bool isDisabled = true;
  String addressType = "HOME";
  bool isOtherAddress = false;
  final TextEditingController otherAddressController =
      new TextEditingController();
  final TextEditingController remarkController = new TextEditingController();
  final TextEditingController address1Controller = new TextEditingController();
  final TextEditingController address2Controller = new TextEditingController();
  final TextEditingController address3Controller = new TextEditingController();
  final TextEditingController address4Controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  height: 200,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text("New Address",
                            style: Styles.text(30, Colors.red, true))
                      ]),
                ),
                TextFormField(
                  controller: address1Controller,
                  onChanged: (value) {
                    checkData();
                  },
                  decoration: new InputDecoration(
                      labelText: "Buildiing Number, Name",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //  when the TextFormField in unfocused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        //  when the TextFormField in focused
                      ),
                      border: UnderlineInputBorder()),
                  keyboardType: TextInputType.text,
                ),
                TextFormField(
                  controller: address2Controller,
                  onChanged: (value) {
                    checkData();
                  },
                  decoration: new InputDecoration(
                      labelText: "Area, Landmark",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //  when the TextFormField in unfocused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        //  when the TextFormField in focused
                      ),
                      border: UnderlineInputBorder()),
                  keyboardType: TextInputType.text,
                ),
                TextFormField(
                  controller: address3Controller,
                  onChanged: (value) {
                    checkData();
                  },
                  decoration: new InputDecoration(
                      labelText: "City",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //  when the TextFormField in unfocused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        //  when the TextFormField in focused
                      ),
                      border: UnderlineInputBorder()),
                  keyboardType: TextInputType.text,
                ),
                TextFormField(
                  controller: address4Controller,
                  onChanged: (value) {
                    checkData();
                  },
                  decoration: new InputDecoration(
                      labelText: "Pincode",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //  when the TextFormField in unfocused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        //  when the TextFormField in focused
                      ),
                      border: UnderlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                // !isOtherAddress?
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Save as",
                          style: Styles.text(10, Colors.grey, true)),
                      SizedBox(height: 10),
                      CupertinoRadioChoice(
                          selectedColor: Colors.orange,
                          notSelectedColor: Colors.grey[300],
                          choices: {
                            "HOME": "HOME",
                            "OFFICE": "OFFICE",
                            "OTHERS": "OTHERS"
                          },
                          onChange: (selectedAddress) {
                            setState(() {
                              addressType = selectedAddress;

                              if (addressType == "OTHERS")
                                isOtherAddress = true;
                              else
                                isOtherAddress = false;

                              checkData();
                            });
                          },
                          initialKeyValue: "HOME"),
                    ],
                  ),
                ),
                // : Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         height: 100,
                //         child: TextFormField(
                //           controller: otherAddressController,
                //           onChanged: (value) {
                //             checkData();
                //           },
                //           decoration: new InputDecoration(
                //               labelText: "",
                //               enabledBorder: UnderlineInputBorder(
                //                 borderSide: BorderSide(color: Colors.grey),
                //                 //  when the TextFormField in unfocused
                //               ),
                //               focusedBorder: UnderlineInputBorder(
                //                 borderSide: BorderSide(color: Colors.blue),
                //                 //  when the TextFormField in focused
                //               ),
                //               border: UnderlineInputBorder()),
                //           keyboardType: TextInputType.text,
                //         ),
                //       ),
                //       new GestureDetector(
                //           onTap: () {
                //             setState(() {
                //               isOtherAddress = false;

                //               checkData();
                //             });
                //           },
                //           child: Text("Cancel")),
                //     ],
                //   ),
                SizedBox(height: 20),
                ButtonTheme(
                  //minWidth: 250,
                  //height: 40,
                  child: Opacity(
                    opacity: isDisabled ? .5 : 1,
                    child: FlatButton(
                      //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                      onPressed: isDisabled
                          ? null
                          : () {
                              addAddress();
                            },
                      color: Colors.orangeAccent,
                      disabledColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Save Address",
                              style: Styles.text(16, Colors.white, true)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  addAddress() async {
    Map<String, dynamic> addressDetail = {
      "addressType": addressType,
      "address1": address1Controller.text,
      "address2": address2Controller.text,
      "address3": address3Controller.text,
      "address4": address4Controller.text,
    };
    await DatabaseMethods().addAddressBook(addressDetail, globals.personCode);
    Navigator.pop(context);
  }

  checkData() {
    setState(() {
      if (addressType != "" &&
          address1Controller.text != "" &&
          address2Controller.text != "" &&
          address3Controller.text != "" &&
          address4Controller.text != "")
        isDisabled = false;
      else
        isDisabled = true;
    });
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
        child: Text('Address Book'.toUpperCase(),
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
