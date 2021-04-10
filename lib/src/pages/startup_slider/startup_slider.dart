import 'package:civideoconnectapp/src/pages/RegistrationPage.dart';
import 'package:civideoconnectapp/src/pages/get_phone.dart';
import 'package:civideoconnectapp/utils/backBtnAndImage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'slide_data.dart';

import 'styles.dart';
import 'welcome_screen.dart';

class StartupSlider extends StatefulWidget {
  @override
  _StartupSliderState createState() => _StartupSliderState();
}

class _StartupSliderState extends State<StartupSlider> {
  List<Slide> _slideList;
  Slide _currentSlide;
  int _currentSlideIndex = 0;
  Color myTitleColor;

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  void initState() {
    super.initState();
    var data = DemoData();
    _slideList = data.getSlides();
    _currentSlide = _slideList[1];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    myTitleColor = Theme.of(context).primaryColor;
    return Scaffold(
      //appBar: _buildAppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Welcome",
                      style: GoogleFonts.abel(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Image.asset("assets/images/Hospitalogo.png",
                        height: 50, fit: BoxFit.scaleDown),
                  ],
                ),
              ),
              Container(
                child: WelcomeScreen(
                  slides: _slideList,
                  onCityChange: _handleSlideChange,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _slideList.map((slide) {
                  int index = _slideList.indexOf(slide);
                  return Container(
                    width: 10.0,
                    height: 10.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentSlideIndex == index
                          ? Colors.orangeAccent
                          : Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              RaisedButton(
                elevation: 16.0,
                //onPressed: startPhoneAuth,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ));
                },
                child: Container(
                  height: 50,
                  width: 120,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                    ),
                  ),
                ),
                color: myTitleColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: bodyTextStyle.copyWith(
                          fontSize: 15, color: Colors.grey)),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/Login');
                    },
                    child: Text("Log in",
                        style: bodyTextStyle.copyWith(
                            fontSize: 20, color: myTitleColor)),
                  ),
                ],
              )
              // HotelList(_currentSlide.hotels),
              //Expanded(child: SizedBox()),
            ],
          ),
        ),
      )),
    );
  }

  void _handleSlideChange(Slide slide, int index) {
    setState(() {
      this._currentSlide = slide;
      this._currentSlideIndex = index;
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      leading: Icon(Icons.menu, color: Colors.black),
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Styles.hzScreenPadding),
          child: Icon(Icons.search, color: Colors.black),
        )
      ],
    );
  }
}
