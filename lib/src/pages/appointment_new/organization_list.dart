import 'dart:convert';

import 'package:civideoconnectapp/data_models/OrganizationDetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/categoryList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/globals.dart' as globals;
import 'doctor_list.dart';

final Color _backgroundColor = Color(0xFFf0f0f0);

class OrganizationList extends StatefulWidget {
  @override
  _OrganizationListState createState() => _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList>{
  List<OrganizationDetails> _organization = List<OrganizationDetails>();
  List<OrganizationDetails> _filterorganization = List<OrganizationDetails>();
  ScrollController _scrollController = ScrollController();
  Icon cusIcon;
  bool issearching = false;
  Widget cusSearchBar;
  Widget cusSearchBarDefault;
  Color appBarIconsColor = Color(0xFF212121);

  @override
  void initState() {
    apiData().then((value) {
      setState(() {
        _organization.addAll(value);
        _filterorganization.addAll(value);
      });
    });

    cusIcon = Icon(Icons.search, color: appBarIconsColor);
    cusSearchBarDefault = Text('Organizations'.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          letterSpacing: 0.5,
          color: appBarIconsColor,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
        ));
    cusSearchBar = cusSearchBarDefault;
    super.initState();
  }


  Future<List<OrganizationDetails>> apiData() async {
    String url = "${globals.apiHostingURLBVH}/MobileMaster/GetMaster";
    var response = await http.post(url,body: {"masterDataType":"ORGANIZATION"});
    var organizations = List<OrganizationDetails>();
    if (response.statusCode == 200) {
      var notesJson = json.decode(response.body)['organizations'];
      for (var notejson in notesJson) {
        organizations.add(OrganizationDetails.fromJson(notejson));
      }
    }
    return organizations;
    //var extractdata = jsonDecode(response.body);
    //print(extractdata);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: _backgroundColor,
//      appBar: AppBar(
//        title: Text("Organization"),
//      ),
      appBar: _buildAppBar(),
      body:Center(child:
//      Column(
//children: <Widget>[
//        child:
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context,index){
          return new GestureDetector(
            child:Center(
              child: Container(
                height: 80,

                child:Card(
                    elevation: 10.0,
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child:Center(
                      child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
//                    SizedBox(height: 20,),
                            Text(
                              _filterorganization[index].organization_name,

                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ]
                      ),
                    )
                ),

              ),
            ),
            onTap: (){
              Navigator.push(
                context,
//                MaterialPageRoute(builder: (context) => CategoryList()),
                MaterialPageRoute(builder: (context) => DoctorList(specialization: null,organizationCode:_filterorganization[index].organization_code)),
              );

            },
          );
        },
        itemCount: _filterorganization.length,
      ),
//]
//    ),
      ),
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
        new IconButton(
          onPressed: () {
            setState(() {
              if (this.cusIcon.icon == Icons.search) {
                this.issearching = true;
                _filterorganization = _organization;
                this.cusIcon = Icon(
                  Icons.cancel,
                  color: Colors.black,
                );
                this.cusSearchBar = TextField(
                  textInputAction: TextInputAction.go,
                  autofocus: true,
                  decoration: new InputDecoration(
                    hintText: 'Search here...',
                  ),
                  onChanged: (string) {
                    setState(() {
                      _filterorganization = _organization
                          .where((n) => (n.organization_name
                          .toLowerCase()
                          .contains(string.toLowerCase())))
                          .toList();
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                );
              } else {
                this.issearching = false;
                _filterorganization = _organization;
                this.cusIcon = Icon(Icons.search, color: Colors.black);
                this.cusSearchBar = cusSearchBarDefault;
              }
            });
          },
          icon: cusIcon,
        ),
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: this.cusSearchBar,
      ),
    );
  }

//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//
//    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
//    var size = MediaQuery.of(context).size;
//    print(size);
//    final double itemHeight = 100;
//    print(itemHeight);
//    final double itemWidth = size.width / 4;
//    print(itemWidth);
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Organization"),
//      ),
//      body:Container(
//     child: GridView.count(
//          padding: EdgeInsets.all(5.0),
//          crossAxisCount: isLandscape ? 4 : 3,
//          childAspectRatio: 1,
//          controller: new ScrollController(keepScrollOffset: false),
//          shrinkWrap: true,
//          scrollDirection: Axis.vertical,
//          children: List.generate(_organization.length, (index) {
//            return _buildListItem(index);
//          })
//      ),
//
//      ),
//
//    );
//  }
//  Widget _buildListItem(int index) {
//    return  GestureDetector(
//      onTap: (){
//         Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => CategoryList()),
//        );
//      },
//      child: Container(
//      decoration: BoxDecoration(
//        color: Colors.blue
//      ),
//
//        child:Card(
////          color: Colors.blue,
//          elevation: 10.0,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(15.0),
//          ),
//child:Center(
//          child:Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Text(
//                  _organization[index].organization_name,
//                  style: TextStyle(
//                      fontSize: 14.0, fontWeight: FontWeight.bold),
//                ),
//
//              ]
//          ),
//        )
//        ),
//
//      ),
//    );
//
//  }
}