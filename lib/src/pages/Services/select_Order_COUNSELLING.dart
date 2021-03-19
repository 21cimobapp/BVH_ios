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
import 'paramcombine1.dart';

class SelectOrderCOUNSELLING extends StatefulWidget {
  final ParametFirestore note;

  const SelectOrderCOUNSELLING({Key key, this.note}) : super(key: key);

  @override
  Showpagee createState() => Showpagee();
}

class Showpagee extends State<SelectOrderCOUNSELLING> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  List<ServiceOrderSlot> _sessionfilter = List<ServiceOrderSlot>();
  ServiceOrderSlot selectedSlot;
  BookingDetails bookingDet;
  bool isDisabled = true;
  String bookingType;
  DatePickerController _controller = DatePickerController();
  DatePickerController _controllerVisit = DatePickerController();
  final TextEditingController remarkController = new TextEditingController();
  final TextEditingController address1Controller = new TextEditingController();
  final TextEditingController address2Controller = new TextEditingController();
  final TextEditingController address3Controller = new TextEditingController();
  final TextEditingController address4Controller = new TextEditingController();
  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  String healthCheckUpGuidelines;
  // getsum() {
  //   bloc.total = bookingDet.TotalAmount;
  // }

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
    //getsum();
    getGuidelinesFromAssets();

    options = {"WI": "WALK-IN"};
    defaultValue = "WI";

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
    if (bookingType == "WI") {
      _sessionfilter.add(new ServiceOrderSlot(
          "1", "8:00 AM", "8:00 AM", "9:00 AM", "8:00 AM to 9:00 AM", "1"));

      _sessionfilter.add(new ServiceOrderSlot("1", "9:00 AM to 10:00 AM",
          "9:00 AM", "10:00 AM", "9:00 AM to 10:00 AM", "1"));

      _sessionfilter.add(new ServiceOrderSlot("1", "10:00 AM to 11:00 AM",
          "10:00 AM", "11:00 AM", "10:00 AM to 11:00 AM", "1"));
    }
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Select Date and Time",
                                style: Styles.text(16, Colors.black, true)),
                            Text("*", style: Styles.text(16, Colors.red, true)),
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
                                              : bookingType == "WISLOT"
                                                  ? "Counselling Date and Time"
                                                  : bookingType == "HVISIT"
                                                      ? "Kirtan Date and Time"
                                                      : "Date and Time",
                                          style: Styles.text(
                                              16, Colors.black, true)),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                          "${DateFormat('EEEE, dd MMM yyyy').format(selectedDate)}"),
                                      Text("${selectedSlot.SlotTimeLabel}"),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Remark",
                                      style:
                                          Styles.text(16, Colors.black, true)),
                                  Text("*",
                                      style: Styles.text(16, Colors.red, true)),
                                ],
                              ),
                              TextFormField(
                                controller: remarkController,
                                onChanged: (value) {
                                  checkData();
                                },
                                decoration: new InputDecoration(
                                    labelText: "Remarks",
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
                        bookingType == "HCOLL"
                            ? Container(
                                padding: const EdgeInsets.all(8.0),
                                color: Colors.white,
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Sample pickup Address",
                                          style: Styles.text(
                                              16, Colors.black, true)),
                                      Text("*",
                                          style: Styles.text(
                                              16, Colors.red, true)),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: address1Controller,
                                    onChanged: (value) {
                                      checkData();
                                    },
                                    decoration: new InputDecoration(
                                        labelText: "Buildiing Number, Name",
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
                                  TextFormField(
                                    controller: address2Controller,
                                    onChanged: (value) {
                                      checkData();
                                    },
                                    decoration: new InputDecoration(
                                        labelText: "Area, Landmark",
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
                                  TextFormField(
                                    controller: address3Controller,
                                    onChanged: (value) {
                                      checkData();
                                    },
                                    decoration: new InputDecoration(
                                        labelText: "City",
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
                                  TextFormField(
                                    controller: address4Controller,
                                    onChanged: (value) {
                                      checkData();
                                    },
                                    decoration: new InputDecoration(
                                        labelText: "Pincode",
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
                                    keyboardType: TextInputType.number,
                                  ),
                                ]))
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
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
                          "\Total Amount:  ${widget.note.Price} /-",
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
                                bookingDet = new BookingDetails(
                                    globals.personCode,
                                    "${_getUserData("FirstName")} ${_getUserData("LastName")}",
                                    selectedDate,
                                    selectedSlot.SlotTimeLabel,
                                    selectedSlot.SlotNumber,
                                    "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${selectedSlot.SlotFromTime}",
                                    "${DateFormat('yyyy-MM-dd').format(selectedDate)} ${selectedSlot.SlotToTime}",
                                    selectedSlot.SlotTimeLabel,
                                    widget.note.ServiceType,
                                    bookingType,
                                    address1Controller.text,
                                    address2Controller.text,
                                    address3Controller.text,
                                    address4Controller.text,
                                    remarkController.text,
                                    widget.note.Price);

                                List<String> services = new List<String>();
                                services.add(
                                    "${widget.note.id}##${widget.note.TestName}");
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
      if (selectedDate != null &&
          remarkController.text != "" &&
          selectedSlot != null)
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
