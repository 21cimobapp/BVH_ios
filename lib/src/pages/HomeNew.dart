import 'dart:io';

import 'package:flutter/material.dart';

class HomePageNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
          
          appBar: AppBar(
            centerTitle: true ,
            
          
                title:
          
                Text('Doctor World', 
                style: TextStyle(color: Colors.blue),             
                ),
         // ],),
               // icon:Icons.home,
              //  iconTheme: (Icons.home),
              backgroundColor: Colors.white,
              
              
              leading: IconButton(
            icon: Image.asset('assets/docworldapp.png'), 
            onPressed: () { },
          ),

              actions: <Widget>[
               
                new IconButton(
            icon: new Icon(Icons.notifications,color: Colors.grey,),

            tooltip: 'Notifications',
            onPressed: () => exit(0),
          ),
          
              ],
            ),
            body: 
            Container(

            child: Container(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,

               // child:
               
    children: <Widget>[   

           Container(
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                    /*  Align( 
                       alignment: Alignment.topRight,
                        child:Tab(
                       icon: Container(
                           child: Image(
                          
                          image: AssetImage(
                             'assets/doc2.jpg',
                       ),),),),), */
                  Container(
                   //alignment: Alignment.topLeft,
                  
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Align(
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
                   child:   Text('Veronica Taylor',style: TextStyle( fontSize: 16.0,fontWeight: FontWeight.bold,),),),
                   
                   //Icon(Icons.person_outline,color: Colors.grey,),
                      
                   
                    ],
                  ),),

                   
          
          //icon: Image.asset('assets/docworldapp.png'), 
        // new Icon( new Image.asset('name'), //color: Colors.blue),

                   ],
                 ),),

             Center(
            
         child: Padding(padding: EdgeInsets.all(8.0),
          child: Container(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,

               // child:
               
               children: <Widget>[
                
                

                SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                children: <Widget>[

                  Container(
                      alignment: Alignment.center,
                      child:
                         Image.asset('assets/d1.jpg',width: 300, height: 200, fit: BoxFit.contain), 
                      
                    
                  
                  ),

                  Container(
                      alignment: Alignment.center,
                      child:
                         Image.asset('assets/d2.jpg',width: 300, height: 200, fit: BoxFit.contain), 
                      
                    
                  
                  ),
                  Container(
                      alignment: Alignment.center,
                      child:
                         Image.asset('assets/d3.jpg',width: 300, height: 200, fit: BoxFit.contain), 
                      
                    
                  
                  ),

                
                ],
              ),
             ),
            ),

 /* Container(
       height: 200,
         width: 720,
         color: Colors.grey[300],
         child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
  */
         Container(
           height: 90,
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
               height: 70,
         width: 160,
         margin: EdgeInsets.only(top:20),
              color: Colors.white,
               child:Column(
                 children: [
                   
            Icon(Icons.video_call, color: Colors.blue),
            Text('Video Call a Doctor',style: TextStyle( fontSize: 15.0),),
           Text('24 hrs Teleconsultant',style: TextStyle( fontSize: 13.0),),
          ],
               ) ,
            ),

            
          ],
        ),
        Column(
          
          children: [

             Container(
               height: 70,
         width: 160,
         margin: EdgeInsets.only(top:20),
              color: Colors.white,
               child:Column(
                 children: [
                   
            Icon(Icons.search, color: Colors.blue,),
            Text('Search Doctor',style: TextStyle( fontSize: 15.0),),
            Text('Request Appointment',style: TextStyle( fontSize: 13.0),),
          ],
               ) ,
            ),
            
          ],
        ),
        
      ],
    ), 

     
   // ],),
  ),
       Container(
         height: 100,
         width: 360,
         decoration: BoxDecoration(
         color: Colors.grey[300],),
       // color: Colors.grey,
   // padding: EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          
          children: [
            Container(
              height: 70,
         width: 160,
         margin: EdgeInsets.only(top:15),
              color: Colors.white,
               child:Column(
                 children: [
            Icon(Icons.line_style, color: Colors.blue,),
            Text('Health Advisor',style: TextStyle( fontSize: 15.0),),
          Text('Tips and alerts',style: TextStyle( fontSize: 13.0),),
          ],
               ) ,
            ),
          
          ],
        ),
        Column(
          children: [
             Container(
               height: 70,
         width: 160,
         margin: EdgeInsets.only(top:15),
              color: Colors.white,
               child:Column(
                 children: [
                   
            Icon(Icons.store_mall_directory, color: Colors.blue),
            Text('Health Store',style: TextStyle( fontSize: 15.0),),
          Text('Shop Healthcare Product',style: TextStyle( fontSize: 13.0),),
          ],
               ) ,
            ),
           
          
          ],
        ),
        
      ],
    ),
  ), 
          //  ],
        // ),)
    Container(
     height: 70,
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
             
                ] )
           ), )
            )
    ],),),),
              )
      );
  }
}
