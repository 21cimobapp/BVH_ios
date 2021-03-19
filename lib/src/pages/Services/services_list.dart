import 'package:civideoconnectapp/src/pages/Services/lab_tests.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

Color myTitleColor;

class ServicesList extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ServicesList> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  Stream<QuerySnapshot> orders;
  final ScrollController _scrollController = ScrollController();

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
    fontSize: 15,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  @override
  void initState() {
    super.initState();
    getStream();
  }

  getStream() {
    DatabaseMethods().getPatientOrders(globals.personCode).then((val) {
      setState(() {
        orders = val;
      });
    });
  }

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  Widget build(BuildContext context) {
    myTitleColor = Theme.of(context).primaryColor;

    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Lab Tests",
        currentButton: FloatingActionButton(
          heroTag: "LabTest",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTests(
                    serviceType: "LABTEST", serviceTypeName: "Lab Tests"),
              ),
            );
          },
        )));
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Health Checkup Packages",
        currentButton: FloatingActionButton(
          heroTag: "HealthCheckup",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTests(
                    serviceType: "HEALTHCHECKUP",
                    serviceTypeName: "Health Checkup Packages"),
              ),
            );
          },
        )));
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Counselling Packages",
        currentButton: FloatingActionButton(
          heroTag: "Counselling",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTests(
                    serviceType: "COUNSELLING",
                    serviceTypeName: "Counselling Packages"),
              ),
            );
          },
        )));
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "kirtan booking",
        currentButton: FloatingActionButton(
          heroTag: "Kirtan",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTests(
                    serviceType: "KIRTAN", serviceTypeName: "kirtan booking"),
              ),
            );
          },
        )));
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Home Services",
        currentButton: FloatingActionButton(
          heroTag: "HomeServices",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.medical_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTests(
                    serviceType: "HOMESERVICES",
                    serviceTypeName: "Home Services"),
              ),
            );
          },
        )));
    return Scaffold(
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Theme.of(context).accentColor,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons),
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        child: Flex(direction: Axis.vertical, children: <Widget>[
          Container(
              height: 40,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Text("Check here, all your Orders",
                    style: TextStyle(fontSize: 16)),
              )),
          SizedBox(height: 5),
          Expanded(
            child: StreamBuilder(
                stream:
                    orders, //selectedIndex == 0 ? appointments1 : appointments2,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? snapshot.data.documents.length == 0
                          ? Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("You don't have any Orders!"),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: BouncingScrollPhysics(),
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: getOrderCard(
                                      snapshot.data.documents[index], index),
                                );
                              },
                            )
                      : Container(
                          child: Text("Loading data..."),
                        );
                }),
          ),
        ]),
      ),
    );
  }

  getOrderCard(DocumentSnapshot order, index) {
    return Column(
      children: [
        _buildLogoHeader(order),
        SizedBox(
          height: 20,
        ),
        Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order Date ", style: titleTextStyle),
                Text(
                    DateFormat('EEE, MMM d yyyy')
                        .format(order.data["orderDate"].toDate()),
                    style: titleTextStyle.copyWith(color: Colors.black)),
              ],
            )),
        Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PatientCode ", style: titleTextStyle),
                    Text(order.data["patientCode"], style: contentTextStyle),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Patient Name", style: titleTextStyle),
                    Text(order.data["patientName"], style: contentTextStyle),
                  ],
                ),
              ],
            )),
        order.data["bookingType"] == "HCOLL"
            ? Container(
                padding: const EdgeInsets.all(5),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sample Pickup Date ", style: titleTextStyle),
                        Text(
                            DateFormat('EEE, MMM d yyyy')
                                .format(order.data["bookingDate"].toDate()),
                            style: contentTextStyle),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sample Pickup Time slot", style: titleTextStyle),
                        Text(order.data["slotName"], style: contentTextStyle),
                      ],
                    ),
                  ],
                ))
            : Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Schedule Date ", style: titleTextStyle),
                        Text(
                            DateFormat('EEE, MMM d yyyy')
                                .format(order.data["bookingDate"].toDate()),
                            style: contentTextStyle),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        order.data["slotName"] != ""
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Schedule Time slot",
                                      style: titleTextStyle),
                                  Text(order.data["slotName"],
                                      style: contentTextStyle),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ],
                )),
        _buildOrderItems(order, index),
      ],
    );
  }

  _buildOrderItems(DocumentSnapshot order, index) {
    List<Widget> services = [];

    for (int i = 0; i < order.data["services"].length; i++) {
      services.add(Container(
          child: Text(
              '${i + 1} - ${_destructureName(order.data["services"][i])}')));
    }

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: services,
      ),
    );
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('##'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('##') + 2);
  }

  _buildLogoHeader(order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //   child: Image.asset(
        //     order.ServiceType == "LABTEST"
        //         ? 'assets/images/Pickup.png'
        //         : 'assets/images/Hospital.png',
        //     width: 20,
        //   ),
        // ),
        Container(
          width: 200,
          child: Text(
              order.data["ServiceType"] == "LABTEST"
                  ? 'Lab Tests'.toUpperCase()
                  : order.data["ServiceType"] == "HEALTHCHECKUP"
                      ? 'Health Checkup Packages'.toUpperCase()
                      : order.data["ServiceType"] == "COUNSELLING"
                          ? "counselling"
                          : order.data["ServiceType"] == "KIRTAN"
                              ? "kirtan booking"
                              : order.data["ServiceType"] == "HOMESERVICES"
                                  ? "Home services"
                                  : 'Others'.toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
        ),

        Text(
            order.data["bookingType"] == "HCOLL"
                ? 'Home Collection'.toUpperCase()
                : order.data["bookingType"] == "WI"
                    ? 'Walk-in'.toUpperCase()
                    : order.data["bookingType"] == "VISIT"
                        ? "Schedule Visit"
                        : order.data["bookingType"] == "HOMESER"
                            ? "Home Delivery"
                            : order.data["bookingType"],
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ))
      ],
    );
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      //leading: Icon(Icons.home, color: appBarIconsColor),
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
        child: Text('Services'.toUpperCase(),
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
