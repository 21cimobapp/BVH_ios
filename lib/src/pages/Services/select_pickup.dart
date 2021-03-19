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
import 'create_new_address.dart';

class SelectPickup extends StatefulWidget {
  final String serviceType;

  const SelectPickup({Key key, this.serviceType}) : super(key: key);

  @override
  Showpagee createState() => Showpagee();
}

class Showpagee extends State<SelectPickup> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  List<ServiceOrderSlot> _sessionfilter = List<ServiceOrderSlot>();
  ServiceOrderSlot selectedSlot;
  BookingDetails bookingDet;
  bool isDisabled = true;
  String bookingType = "HCOLL";
  final ScrollController _addressController = ScrollController();
  DatePickerController _controller = DatePickerController();
  DatePickerController _controllerVisit = DatePickerController();
  final TextEditingController remarkController = new TextEditingController();
  final TextEditingController couponController = new TextEditingController();
  final TextEditingController address1Controller = new TextEditingController();
  final TextEditingController address2Controller = new TextEditingController();
  final TextEditingController address3Controller = new TextEditingController();
  final TextEditingController address4Controller = new TextEditingController();
  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  String healthCheckUpGuidelines;
  DocumentSnapshot selectedAddress;

  Stream<QuerySnapshot> address;
  String couponCode = "";
  getStream() {
    DatabaseMethods().getPatientAddressBook(globals.personCode).then((val) {
      setState(() {
        address = val;
      });
    });
  }

  getsum() {
    bloc.total = 0;
    for (int i = 0; i < bloc.allData1.length; i++) {
      bloc.total = bloc.total + bloc.allData1[i].Price;
      print(bloc.total);
    }
  }

  getGuidelinesFromAssets() async {
    healthCheckUpGuidelines =
        await getFileData("assets/HealthCheckUpGuidelines.txt");

    setState(() {});
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  bool _disposed = false;

  var options;
  String defaultValue;

  @override
  void initState() {
    super.initState();
    getsum();
    getGuidelinesFromAssets();
    getStream();
    options = {"HCOLL": "HOME COLLETION", "WI": "WALK-IN"};
    defaultValue = "HCOLL";

    bookingType = defaultValue;
    generateSlots(selectedDate);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  generateSlots(DateTime date) async {
    _sessionfilter.clear();

    _sessionfilter.add(new ServiceOrderSlot(
        "1", "8:00 AM", "8:00 AM", "9:00 AM", "8:00 AM to 9:00 AM", "1"));

    _sessionfilter.add(new ServiceOrderSlot("1", "9:00 AM to 10:00 AM",
        "9:00 AM", "10:00 AM", "9:00 AM to 10:00 AM", "1"));

    _sessionfilter.add(new ServiceOrderSlot("1", "10:00 AM to 11:00 AM",
        "10:00 AM", "11:00 AM", "10:00 AM to 11:00 AM", "1"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: new Container(
        child: Column(
          children: <Widget>[
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoRadioChoice(
                          selectedColor: Colors.orange,
                          notSelectedColor: Colors.grey[300],
                          choices: options,
                          onChange: (selectedGender) {
                            setState(() {
                              bookingType = selectedGender;
                              if (bookingType == "HCOLL") {
                                checkData();
                                generateSlots(selectedDate);
                              } else {
                                checkData();
                              }
                            });
                          },
                          initialKeyValue: defaultValue),
                    ),
                    _buildSeparationLine(),
                    bookingType == "HCOLL"
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Select Date and Time",
                                      style:
                                          Styles.text(16, Colors.black, true)),
                                  Text("*",
                                      style: Styles.text(16, Colors.red, true)),
                                ],
                              ),
                              Container(
                                child: DatePicker(
                                  DateTime.now().add(Duration(days: 1)),
                                  width: 60,
                                  height: 100,
                                  controller: _controller,
                                  initialSelectedDate:
                                      DateTime.now().add(Duration(days: 1)),
                                  selectionColor: Theme.of(context).accentColor,
                                  selectedTextColor: Colors.black,
                                  onDateChange: (date) {
                                    // New date selected
                                    setState(() {
                                      selectedDate = date;
                                    });

                                    generateSlots(selectedDate);
                                  },
                                ),
                              ),
                              Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: showSlots(),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              selectedSlot != null
                                  ? Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                                bookingType == "HCOLL"
                                                    ? "Collection Date and Time"
                                                    : "Appointment Date",
                                                style: Styles.text(
                                                    16, Colors.black, true)),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                                "${DateFormat('EEEE, dd MMM yyyy').format(selectedDate)}"),
                                            Text(
                                                "${selectedSlot.SlotTimeLabel}"),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: Colors.white,
                                  child: Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Remark",
                                            style: Styles.text(
                                                16, Colors.black, true)),
                                        Text("*",
                                            style: Styles.text(
                                                16, Colors.red, true)),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: remarkController,
                                      onChanged: (value) {
                                        checkData();
                                      },
                                      decoration: new InputDecoration(
                                          labelText:
                                              "Remarks for sample collection",
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            //  when the TextFormField in unfocused
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            //  when the TextFormField in focused
                                          ),
                                          border: UnderlineInputBorder()),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ])),
                              SizedBox(
                                height: 20,
                              ),
                              bookingType == "HCOLL" && couponCode == ""
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                          color: Colors.grey[400],
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: couponController,
                                            onChanged: (value) {
                                              checkData();
                                            },
                                            decoration: new InputDecoration(
                                                labelText: "Coupon Code",
                                                // enabledBorder:
                                                //     UnderlineInputBorder(
                                                //   borderSide: BorderSide(
                                                //       color: Colors.grey),
                                                //   //  when the TextFormField in unfocused
                                                // ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                  //  when the TextFormField in focused
                                                ),
                                                border: UnderlineInputBorder()),
                                            keyboardType: TextInputType.text,
                                          ),
                                          Container(
                                              child: new GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (couponController
                                                                  .text !=
                                                              "" &&
                                                          couponController
                                                                  .text ==
                                                              "OFFER10")
                                                        couponCode =
                                                            couponController
                                                                .text;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text("Apply Code",
                                                          style: Styles.text(
                                                              15,
                                                              Colors.indigo,
                                                              true)),
                                                    ],
                                                  )))
                                        ],
                                      ))
                                  : Container(
                                      child: Text(
                                          "Coupon code applied successfully!",
                                          style: Styles.text(
                                              15, Colors.indigo, true))),
                              SizedBox(height: 20),
                              bookingType == "HCOLL"
                                  ? Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: Colors.white,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: new GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CreateNewAddress(),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.add,
                                                            size: 20.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                        Text("Add New Address",
                                                            style: Styles.text(
                                                                15,
                                                                Colors.indigo,
                                                                true)),
                                                      ],
                                                    ))),
                                            Container(
                                              child: StreamBuilder(
                                                  stream:
                                                      address, //selectedIndex == 0 ? appointments1 : appointments2,
                                                  builder: (context, snapshot) {
                                                    return snapshot.hasData
                                                        ? snapshot
                                                                    .data
                                                                    .documents
                                                                    .length ==
                                                                0
                                                            ? Container(
                                                                height: 80,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                color: Colors
                                                                    .grey[200],
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                        "Address Book is empty!"),
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 120,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  controller:
                                                                      _addressController,
                                                                  physics:
                                                                      BouncingScrollPhysics(),
                                                                  itemCount: snapshot
                                                                      .data
                                                                      .documents
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          Expanded(
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              selectedAddress = snapshot.data.documents[index];
                                                                              checkData();
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.all(10),
                                                                            color:
                                                                                Colors.white,
                                                                            child:
                                                                                getAddressCard(snapshot.data.documents[index], index),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                        : Container(
                                                            height: 80,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            color: Colors
                                                                .grey[200],
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    "Loading Address Book..."),
                                                              ],
                                                            ),
                                                          );
                                                  }),
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //   children: [
                                            //     Text("Sample pickup Address",
                                            //         style: Styles.text(
                                            //             16, Colors.black, true)),
                                            //     Text("*",
                                            //         style: Styles.text(
                                            //             16, Colors.red, true)),
                                            //   ],
                                            // ),
                                            // TextFormField(
                                            //   controller: address1Controller,
                                            //   onChanged: (value) {
                                            //     checkData();
                                            //   },
                                            //   decoration: new InputDecoration(
                                            //       labelText:
                                            //           "Buildiing Number, Name",
                                            //       enabledBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.grey),
                                            //         //  when the TextFormField in unfocused
                                            //       ),
                                            //       focusedBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.blue),
                                            //         //  when the TextFormField in focused
                                            //       ),
                                            //       border: UnderlineInputBorder()),
                                            //   keyboardType: TextInputType.text,
                                            // ),
                                            // TextFormField(
                                            //   controller: address2Controller,
                                            //   onChanged: (value) {
                                            //     checkData();
                                            //   },
                                            //   decoration: new InputDecoration(
                                            //       labelText: "Area, Landmark",
                                            //       enabledBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.grey),
                                            //         //  when the TextFormField in unfocused
                                            //       ),
                                            //       focusedBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.blue),
                                            //         //  when the TextFormField in focused
                                            //       ),
                                            //       border: UnderlineInputBorder()),
                                            //   keyboardType: TextInputType.text,
                                            // ),
                                            // TextFormField(
                                            //   controller: address3Controller,
                                            //   onChanged: (value) {
                                            //     checkData();
                                            //   },
                                            //   decoration: new InputDecoration(
                                            //       labelText: "City",
                                            //       enabledBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.grey),
                                            //         //  when the TextFormField in unfocused
                                            //       ),
                                            //       focusedBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.blue),
                                            //         //  when the TextFormField in focused
                                            //       ),
                                            //       border: UnderlineInputBorder()),
                                            //   keyboardType: TextInputType.text,
                                            // ),
                                            // TextFormField(
                                            //   controller: address4Controller,
                                            //   onChanged: (value) {
                                            //     checkData();
                                            //   },
                                            //   decoration: new InputDecoration(
                                            //       labelText: "Pincode",
                                            //       enabledBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.grey),
                                            //         //  when the TextFormField in unfocused
                                            //       ),
                                            //       focusedBorder:
                                            //           UnderlineInputBorder(
                                            //         borderSide: BorderSide(
                                            //             color: Colors.blue),
                                            //         //  when the TextFormField in focused
                                            //       ),
                                            //       border: UnderlineInputBorder()),
                                            //   keyboardType: TextInputType.number,
                                            // ),
                                          ]))
                                  : Container(),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        : Container(
                            child: Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Select Appointment Date",
                                          style: Styles.text(
                                              16, Colors.black, true)),
                                      Text("*",
                                          style: Styles.text(
                                              16, Colors.red, true)),
                                    ],
                                  ),
                                  Container(
                                    child: DatePicker(
                                      DateTime.now().add(Duration(days: 1)),
                                      width: 50,
                                      height: 90,
                                      controller: _controllerVisit,
                                      initialSelectedDate:
                                          DateTime.now().add(Duration(days: 1)),
                                      selectionColor:
                                          Theme.of(context).accentColor,
                                      selectedTextColor: Colors.black,
                                      onDateChange: (date) {
                                        // New date selected
                                        setState(() {
                                          selectedDate = date;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            "Please Proceed for make payment. Please read information before making the payment."),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(healthCheckUpGuidelines ?? ""),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            )),
            Container(
              margin: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 200,
                    // children: <Widget>[
                    child: Column(
                      children: <Widget>[
                        Text(
                          couponCode == "OFFER10"
                              ? "\Total Amount:  ${(bloc.total - ((bloc.total / 100) * 10)).round()} /-"
                              : "\Total Amount:  ${bloc.total} /-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                if (!isDisabled) {
                                  int charges = 0;
                                  if (couponCode == "OFFER10")
                                    charges =
                                        (bloc.total - ((bloc.total / 100) * 10))
                                            .round();
                                  else
                                    charges = bloc.total;

                                  if (bookingType == "WI")
                                    bookingDet = new BookingDetails(
                                        globals.personCode,
                                        "${_getUserData("FirstName")} ${_getUserData("LastName")}",
                                        selectedDate,
                                        "",
                                        "",
                                        null,
                                        null,
                                        "",
                                        widget.serviceType,
                                        bookingType,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        charges);
                                  else
                                    bookingDet = new BookingDetails(
                                        globals.personCode,
                                        "${_getUserData("FirstName")} ${_getUserData("LastName")}",
                                        selectedDate,
                                        selectedSlot.SlotTimeLabel,
                                        selectedSlot.SlotNumber,
                                        "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${selectedSlot.SlotFromTime}",
                                        "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${selectedSlot.SlotToTime}",
                                        selectedSlot.SlotTimeLabel,
                                        widget.serviceType,
                                        bookingType,
                                        selectedAddress.data["address1"],
                                        selectedAddress.data["address2"],
                                        selectedAddress.data["address3"],
                                        selectedAddress.data["address4"],
                                        remarkController.text,
                                        charges);

                                  List<String> services = new List<String>();

                                  for (int i = 0;
                                      i < bloc.allData1.length;
                                      i++) {
                                    services.add(
                                        "${bloc.allData1[i].id}##${bloc.allData1[i].TestName}");
                                  }

                                  //makePayment();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => CheckRazor(
                                        bookingDetails: bookingDet,
                                        services: services,
                                      ),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              },
                        color: Colors.orangeAccent,
                        disabledColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/Rs.png",
                                height: 20, width: 20),
                            SizedBox(width: 10),
                            Text("Pay Now",
                                style: Styles.text(16, Colors.white, true)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAddressCard(DocumentSnapshot address, index) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selectedAddress == null
              ? Colors.grey[200]
              : selectedAddress.documentID == address.documentID
                  ? Theme.of(context).accentColor
                  : Colors.grey[200],
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.data["addressType"],
              style: Styles.text(15, Colors.black, true)),
          Container(
            width: 100,
            child: Text(
              "${address.data["address1"]} ${address.data["address2"]} ${address.data["address3"]} ${address.data["address4"]}",
              style: Styles.text(10, Colors.black, true),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  showSlots() {
    List<Widget> sessions = [];

    if (isHoliday() == true) {
      sessions.add(Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("No slots available (Holiday)",
                  style: Styles.text(16, Colors.black, true)))));

      return sessions;
    } else if (selectedDate.weekday == 7) {
      sessions.add(Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("No slots available",
                  style: Styles.text(16, Colors.black, true)))));
      return sessions;
    } else {
      sessions.add(Container(
          child: Center(
              child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Select Time Slot', style: Styles.text(16, Colors.black, true)),
          Text("*", style: Styles.text(16, Colors.red, true)),
        ],
      ))));

      sessions.addAll(generateSlot(0));
      return sessions;
    }
  }

  generateSlot(session) {
    List<Widget> sessionSlot = [];
    var size = MediaQuery.of(context).size;
    print(size);
    final double itemHeight = (size.height - kToolbarHeight - 24) / 10;
    print(itemHeight);
    final double itemWidth = size.width / 2;
    print(itemWidth);

    sessionSlot.add(SizedBox(
      height: 10,
    ));
    sessionSlot.add(Container(
        child:
            Text("Morning slot", style: Styles.text(16, Colors.black, true))));

    sessionSlot.add(SizedBox(
      height: 10,
    ));

    sessionSlot.add(Container(
        child: GridView.count(
      // crossAxisCount is the number of columns
      crossAxisCount: 2,
      childAspectRatio: (itemWidth / itemHeight),
      controller: new ScrollController(keepScrollOffset: false),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      // This creates two columns with two items in each column
      children: List.generate(_sessionfilter.length, (index) {
        return GestureDetector(
          onTap: () {
            if (_sessionfilter[index].SlotAvailable == "1")
              setState(() {
                if (selectedSlot == _sessionfilter[index]) {
                  selectedSlot = null;
                  checkData();
                } else {
                  selectedSlot = _sessionfilter[index];
                  checkData();
                }
              });
            //confirmAppointment(_sessionfilter[index]);
          },
          //  child: Card(
          // elevation: 2.0,
          child: Container(
            decoration: BoxDecoration(
              color: selectedSlot != null
                  ? selectedSlot == _sessionfilter[index]
                      ? Theme.of(context).primaryColor
                      : Colors.white
                  : Colors.white,
              border: Border.all(
                  color: _sessionfilter[index].SlotAvailable == "1"
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200]),
              borderRadius: BorderRadius.circular(5.0),
            ),
            margin: new EdgeInsets.all(4.0),
            child: new Center(
              //child: new Text(_sessionfilter[index].SlotTimeLabel.split('-')[0]),
              child: new Text(_sessionfilter[index].SlotTimeLabel,
                  style: TextStyle(
                    color: _sessionfilter[index].SlotAvailable == "1"
                        ? selectedSlot != null
                            ? selectedSlot == _sessionfilter[index]
                                ? Colors.white
                                : Colors.black
                            : Colors.black
                        : Colors.grey[400],
                  )),
            ),
          ),
          // ),
        );
      }),
    )));

    return sessionSlot;
  }

  checkData() {
    setState(() {
      if (bookingType == "WI")
        isDisabled = false;
      else if (selectedDate != null &&
          selectedSlot != null &&
          selectedAddress != null)
        isDisabled = false;
      else
        isDisabled = true;
    });
  }

  bool isHoliday() {
    List<HolidayData> hList = List<HolidayData>();

    hList.addAll(globals.holidayList
        .where((element) => element.holidayDate == selectedDate));

    if (hList == null)
      return false;
    else if (hList.length > 0)
      return true;
    else
      return false;
  }

  Widget _buildSeparationLine() {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.grey,
    );
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
        child: Text('Checkout'.toUpperCase(),
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
