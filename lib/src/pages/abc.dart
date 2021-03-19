import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

//void main() => runApp(MyApp());
void main() {
  runApp(MaterialApp(
    // title: 'Navigation Basics',
    home: MyApp(),
  ));
}

final List<String> imgList = [
  'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
  'https://images.unsplash.com/photo-1578496480240-32d3e0c04525?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
  'https://images.pexels.com/photos/127873/pexels-photo-127873.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  'https://images.pexels.com/photos/139398/thermometer-headache-pain-pills-139398.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  'https://images.pexels.com/photos/4386513/pexels-photo-4386513.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  // 'https://www.pexels.com/photo/blue-and-silver-stetoscope-40568/',
  // 'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  //'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  // 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  //'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          'No. ${imgList.indexOf(item)} image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
    .toList();

class _State extends State<MyApp> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Text(
          'Doctor World',
          style: TextStyle(color: Colors.blue),
        ),
        // ],),
        // icon:Icons.home,
        //  iconTheme: (Icons.home),
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: Image.asset('assets/docworldapp.png'),
          onPressed: () {},
        ),

        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.notifications,
              color: Colors.grey,
            ),
            tooltip: 'Notifications',
            onPressed: () => exit(0),
          ),
        ],
      ),
      body: Container(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            // child:

            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*  Align(
                        alignment: Alignment.centerRight,child: 
                         Tab(
                       icon: Container(
                           child: Image(
                          
                          image: AssetImage(
                             'assets/doc2.jpg',
                       ),),),), ),
                   Align(
                     alignment: Alignment.topLeft,
                     child:   Text('Hello', style: TextStyle( fontSize: 13.0,
                     
                    ) ,),),
                   Align(
                     alignment: Alignment.centerLeft,
                   child:   Text('Veronica Taylor',style: TextStyle( fontSize: 16.0,fontWeight: FontWeight.bold,),),), */

                          Column(
                            children: <Widget>[
                              // Text('Hello',textAlign: TextAlign.left,style: TextStyle( fontSize: 13.0),),
                              // Text('Veronica Taylor',textAlign: TextAlign.left,style: TextStyle( fontSize: 16.0,fontWeight: FontWeight.bold,),),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Hello',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Veronica Taylor',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Tab(
                                  icon: Container(
                                    child: Image(
                                      image: AssetImage(
                                        'assets/doc2.jpg',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                      Column(children: [
                        CarouselSlider(
                          items: imageSliders,
                          options: CarouselOptions(
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 2.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imgList.map((url) {
                            int index = imgList.indexOf(url);
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? Color.fromRGBO(0, 0, 0, 0.9)
                                    : Color.fromRGBO(0, 0, 0, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ]),


                      Container(
                        height: 120,
                        width: 360,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //Padding(padding: EdgeInsets.all(20),),
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 150,
                                  margin: EdgeInsets.only(top: 20),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.video_call,
                                            color: Colors.blue),
                                        // onPressed: ()=>Navigator.pushNamed(context, "/appointment"),
                                        onPressed: () {},
                                      ),
                                      //Icon(Icons.video_call, color: Colors.blue),
                                      Text(
                                        'Video Call a Doctor',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      Text(
                                        '24 hrs Teleconsultant',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 150,
                                  margin: EdgeInsets.only(top: 20),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.search,
                                          color: Colors.blue,
                                        ),
                                        // onPressed: ()=>Navigator.pushNamed(context, "/appointment"),
                                        onPressed: () {},
                                      ),

                                      Text(
                                        'Search Doctor',
                                        style: TextStyle(fontSize: 15.0),
                                      ),

                                      // Text('Search Doctor',style: TextStyle( fontSize: 15.0),),
                                      Text(
                                        'Request Appointment',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ],),
                      ),
                      Container(
                        height: 120,
                        width: 360,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        // color: Colors.grey,
                        // padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 150,
                                  margin: EdgeInsets.only(top: 10),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.line_style,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        'Health Advisor',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      Text(
                                        'Tips and alerts',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 150,
                                  margin: EdgeInsets.only(top: 10),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Icon(Icons.store_mall_directory,
                                          color: Colors.blue),
                                      Text(
                                        'Health Store',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      Text(
                                        'Shop Healthcare Product',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //  ],
                      // ),)
                      Container(
                        height: 50,
                        //width: 300,
                        //color: Colors.grey,
                        /* padding: EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
             Icon(Icons.home, color: Colors.blue, ),
           
           Text('Home'),
          ],
        ),
         Column(
          children: [
             
            Icon(Icons.event_note, color: Colors.grey),
           
            Text('Appointment'),
           
          ],
        ),
         Column(
          children: [
            
            Icon(Icons.person_pin, color: Colors.grey),
           
           Text('Accountant'),
           
          ],
        ),
         Column(
          children: [
             
             Icon(Icons.more_horiz, color: Colors.grey),
            Text('More'),
           
          ],
        ),
        
        
      ],
    ), */
                      ),
                    ])),
              ))
            ],
          ),
        ),
      ),
    ));
  }
}
