import 'dart:async';
//import 'dart:developer';
import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'param.dart';
import 'paramcombine1.dart';
import 'class.dart';
import 'checkout.dart';
//import 'ShowCheckout.dart';
import 'lab_tests_NextPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Firebase_firestore_service.dart';
//import 'package:flutter_tags/flutter_tags.dart';

//import 'package:location/location.dart';

class LabTests extends StatefulWidget {
  final String serviceType;
  final String serviceTypeName;

  const LabTests({Key key, this.serviceType, this.serviceTypeName})
      : super(key: key);

  @override
  _ShowDataPageState createState() => _ShowDataPageState();
}

class _ShowDataPageState extends State<LabTests> {
  // List<Need> allData = [];
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> noteSub;
  var totalCount;
  final Color _backgroundColor = Color(0xFFf0f0f0);
  /* bool _isVisible = false;
  String _value = '';
  var count = 0;
  var j;
  var i;
  _onChanged() {
    // if(bloc.allData1 != null){
    // for (i = 0; i < bloc.allData1.length; i++) {
    // bloc.empdata[i]="added";
    for (j = 0; j < bloc.allData1.length; j++) {
      //for (var k = 0; k < bloc.empdata.length; k++) {
      if (bloc.items[j] == bloc.allData1[j]) {
        setState(() // =>
            {
          bloc.empdata[j] = "added";

          // count=i;
          // bloc.flag=1;
          // if(count==j){
          // _value = 'added';
          //visiblecheck(j);
          //_isVisible = true;//}
        });
      } else {
        bloc.flag = 0;
      } //else{_onChanged();}
      // } // }// }
    }
    /* else
    {
      bloc.flag=0;
    } */
  } */

/* visiblecheck(j){
  if(count==j){}
} */
  /* void showToast() {
      setState(() {
        _isVisible = !_isVisible;
      });
    } */

  bool _disposed = false;
  @override
  void initState() {
    super.initState();
    //print(totalCount);
    // items = new List();
    //bloc.allData = new List();
    //bloc.items = new List();

    ////// Note: calling onchange() method
    // const oneSecond = const Duration(seconds: 1);
    // new Timer.periodic(oneSecond, (Timer t) {
    //   if (!_disposed)
    //     setState(() {
    //       //_onChanged();
    //       //time = time.add(Duration(seconds: -1));
    //     });
    // }
    // );

    noteSub?.cancel();
    noteSub = db.getNoteList().listen((QuerySnapshot snapshot) {
      final List<ParametFirestore> notes = snapshot.documents
          .where((element) => element.data["ServiceType"] == widget.serviceType)
          .map((documentSnapshot) =>
              ParametFirestore.fromMap(documentSnapshot.data))

          //.where((element) => element.ServiceType == widget.serviceType)
          .toList();

      /* final List<Need> notes = snapshot.documents
          .map((documentSnapshot) => Need.fromMap(documentSnapshot.data))
          .toList(); */

      setState(() {
        // bloc.allData.add(notes);
        //this.items = notes;
        bloc.items = notes;

        for (var i = 0; i < bloc.items.length; i++) {
          final item = bloc.allData1.firstWhere(
              (element) => element.id == bloc.items[i].id, orElse: () {
            return null;
          });

          if (item != null) {
            bloc.items[i].selected = true;
          }
        }

//items.sort((a, b) => (b['TestName']).compareTo(a['TestName']));

        // items.sort((a, b) => compare(a.TestName, b.TestName));
        // items.sort((a, b) => a[].compareTo(b));
        //bloc.allData = notes;
      });
    });
  }

  //items.sort((a, b) => a.compareTo(b.length));

//items.sort((a, b) => (b['TestName']).compareTo(a['TestName']));
  @override
  void dispose() {
    _disposed = true;
    noteSub?.cancel();
    super.dispose();
  }

  ////// sort alphabets
/* List<String> alphabets = [];
List<String> getAlphabetsFromStringList(List<String> items) {
  //List<String> alphabets = [];

  for (String item in items)
    if (!alphabets.contains(item[0]))
      alphabets.add(item[0]);

  alphabets.sort((a,b) => a.compareTo(b));

  return alphabets;
} */

  /////realtime databse
  /* void initState() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    // ref.child('TestLab').limitToFirst(6).once().then((DataSnapshot snap) {
    ref.child('TestLab').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      bloc.allData.clear();
      for (var key in keys) {
        Need d = new Need(
          data[key]['TestName'],
          //data[key]['changeButtonColor'],
          data[key]['Price'],
          data[key]['ImagePath'],
        );
        bloc.allData.add(d);
      }
      setState(() {
        print('Length : ${bloc.allData.length}');
      });
    });
  } */

  bool selectingmode = false; //// 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: new Container(
        child: bloc.items.length == 0
            ? new Text('')
            : //new Expanded(
            // child: SingleChildScrollView(

            ListView.builder(
                itemCount: bloc.items.length,
                itemBuilder: (_, index) {
                  return getServiceWidget(index);
                },
              ),

        //),
        //  ),
      ),
    );
  }

  checkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Checkout(serviceType: widget.serviceType)),
    );

    setState(() {
      for (var i = 0; i < bloc.items.length; i++) {
        final item = bloc.allData1.firstWhere(
            (element) => element.id == bloc.items[i].id, orElse: () {
          return null;
        });

        if (item != null) {
          bloc.items[i].selected = true;
        } else {
          bloc.items[i].selected = false;
        }
      }
    });
  }

  getServiceWidget(index) {
    return InkWell(
      onTap: () {
        _navigateToNote(context, bloc.items[index]);
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purple[200],
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 110,
                  decoration: BoxDecoration(
                    //shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                          '${bloc.items[index].ImagePath}',
                        ),
                        fit: BoxFit.fill),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width / 3) -
                          30,
                      child: Text(
                        '${bloc.items[index].TestName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(3.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '\Rs. ${bloc.items[index].Price}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        (bloc.items[index].selected)
                            ? Icon(Icons.offline_pin, color: Colors.blue)
                            : Text("") //Icon(Icons.shopping_cart))
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    totalCount = bloc.allData1.length;
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        widget.serviceType == "LABTEST" || widget.serviceType == "HEALTHCHECKUP"
            ? new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new Container(
                    height: 150.0,
                    width: 30.0,
                    child: new GestureDetector(
                      onTap: () {
                        checkout();
                      },
                      child: new Stack(
                        children: <Widget>[
                          new IconButton(
                            icon: new Icon(
                              Icons.shopping_cart,
                              color: Colors.black,
                            ),
                            onPressed: null,
                          ),
                          totalCount > 0
                              ? new Positioned(
                                  child: new Stack(
                                  children: <Widget>[
                                    new Icon(Icons.brightness_1,
                                        size: 20.0, color: Colors.red[700]),
                                    new Positioned(
                                        top: 3.0,
                                        right: 7,
                                        child: new Center(
                                          child: new Text(
                                            '$totalCount',
                                            style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )),
                                  ],
                                ))
                              : Container(),
                        ],
                      ),
                    )),
              )
            : Container()
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('${widget.serviceTypeName}'.toUpperCase(),
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

  void _navigateToNote(BuildContext context, ParametFirestore note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NextPage(note, widget.serviceTypeName)),
    );
    setState(() {});
  }
}
