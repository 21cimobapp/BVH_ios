import 'dart:math';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'rounded_shadow.dart';
import 'syles.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class DoctorCardMini extends StatefulWidget {
  static double nominalHeightClosed = 96;
  static double nominalHeightOpen = 270;

  final DoctorData doctorData;
  //final int earnedPoints;

  const DoctorCardMini({
    Key key,
    this.doctorData,

    //this.earnedPoints = 100
  }) : super(key: key);

  @override
  _DoctorCardMiniState createState() => _DoctorCardMiniState();
}

class _DoctorCardMiniState extends State<DoctorCardMini>
    with TickerProviderStateMixin {
  bool _wasOpen = false;
  bool isOpen = false;
  Color get mainTextColor {
    Color textColor;

    textColor = Color(0xFF083e64);
    return textColor;
  }

  Color get secondaryTextColor {
    Color textColor;

    textColor = Color(0xFF838383);
    return textColor;
  }

  Color get separatorColor {
    Color color;

    color = Color(0xff396583);
    return color;
  }

  TextStyle get bodyTextStyle => TextStyle(
        color: mainTextColor,
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  //Animation<double> _fillTween;
  //Animation<double> _pointsTween;
  //AnimationController _liquidSimController;

  //Create 2 simulations, that will be passed to the LiquidPainter to be drawn.
  // LiquidSimulation _liquidSim1 = LiquidSimulation();
  // LiquidSimulation _liquidSim2 = LiquidSimulation();

  @override
  void initState() {
    //Create a controller to drive the "fill" animations
    // _liquidSimController = AnimationController(
    //     vsync: this, duration: Duration(milliseconds: 3000));
    // _liquidSimController.addListener(_rebuildIfOpen);
    //create tween to raise the fill level of the card
    // _fillTween = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(
    //       parent: _liquidSimController,
    //       curve: Interval(.12, .45, curve: Curves.easeOut)),
    // );
    // //create tween to animate the 'points remaining' text
    // _pointsTween = Tween<double>(begin: 0, end: 1).animate(
    //   CurvedAnimation(
    //       parent: _liquidSimController,
    //       curve: Interval(.1, .5, curve: Curves.easeOutQuart)),
    // );
    super.initState();
  }

  @override
  void dispose() {
    //_liquidSimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Determine the points required text value, using the _pointsTween
    //var pointsRequired = widget.doctorData.requiredPoints;
    //var pointsValue = pointsRequired * 1.0;
    // var pointsValue = pointsRequired -
    //     _pointsTween.value * min(widget.earnedPoints, pointsRequired);
    //Determine current fill level, based on _fillTween
    // double _maxFillLevel =
    //     min(1, widget.earnedPoints / widget.doctorData.requiredPoints);
    // double fillLevel = _maxFillLevel; //_maxFillLevel * _fillTween.value;

    double cardHeight = isOpen
        ? DoctorCardMini.nominalHeightOpen
        : DoctorCardMini.nominalHeightClosed;

    return AnimatedContainer(
      curve: !_wasOpen ? ElasticOutCurve(.9) : Curves.elasticOut,
      duration: Duration(milliseconds: !_wasOpen ? 1200 : 1500),
      height: cardHeight,
      //Wrap content in a rounded shadow widget, so it will be rounded on the corners but also have a drop shadow
      child: RoundedShadow.fromRadius(
        12,
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              //Background liquid layer
              // AnimatedOpacity(
              //   opacity: isOpen ? 1 : 0,
              //   duration: Duration(milliseconds: 500),
              //   child: _buildLiquidBackground(_maxFillLevel, fillLevel),
              // ),

              //Card Content
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                //Wrap content in a ScrollView, so there's no errors on over scroll.
                child: SingleChildScrollView(
                  //We don't actually want the scrollview to scroll, disable it.
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      //Top Header Row
                      _buildTopContent(),
                      // _buildBottomIcon(),

                      // //Spacer
                      // SizedBox(height: 12),
                      // //Bottom Content, use AnimatedOpacity to fade
                      // AnimatedOpacity(
                      //   duration: Duration(
                      //       milliseconds: isOpen ? 1000 : 500),
                      //   curve: Curves.easeOut,
                      //   opacity: isOpen ? 1 : 0,
                      //   //Bottom Content
                      //   child: _buildBottomContent(),
                      //),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stack _buildLiquidBackground(double _maxFillLevel, double fillLevel) {
  //   return Stack(
  //     fit: StackFit.expand,
  //     children: <Widget>[
  //       Transform.translate(
  //         offset: Offset(
  //             0,
  //             DoctorCardMini.nominalHeightOpen * 1.2 -
  //                 DoctorCardMini.nominalHeightOpen *
  //                     _fillTween.value *
  //                     _maxFillLevel *
  //                     1.2),
  //         child: CustomPaint(
  //           painter: LiquidPainter(fillLevel, _liquidSim1, _liquidSim2,
  //               waveHeight: 100),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Padding _buildTopContent() {
    return Padding(
        padding: const EdgeInsets.only(left: 18, right: 0),
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200]),
                  height: 50,
                  width: 50,
                  child: globals.getProfilePic("DOCTOR")),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //color: Colors.green,
                  width: MediaQuery.of(context).size.width - 130,
                  child: Text(
                    "${widget.doctorData.doctorName}".toUpperCase(),
                    style: bodyTextStyle.copyWith(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${widget.doctorData.designation}".toUpperCase(),
                  style: bodyTextStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ));
  }

  // Widget _buildBottomIcon() {
  //   IconData icon;
  //   if (isOpen == false)
  //     icon = Icons.keyboard_arrow_down;
  //   else
  //     icon = Icons.keyboard_arrow_up;
  //   return Icon(
  //     icon,
  //     color: mainTextColor,
  //     size: 18,
  //   );
  // }

  // Column _buildBottomContent() {
  //   bool isDisabled = false;

  //   return Column(
  //     children: [
  //       //Body Text
  //       Text(
  //         "Book your appointment with ${widget.doctorData.doctorName}.",
  //         textAlign: TextAlign.center,
  //         style: bodyTextStyle.copyWith(fontSize: 14),
  //         //style: Styles.text(14, Colors.black, false, height: 1.5),
  //       ),
  //       SizedBox(height: 30),
  //       //Main Button
  //       ButtonTheme(
  //         minWidth: 250,
  //         height: 40,
  //         child: Opacity(
  //           opacity: isDisabled ? .6 : 1,
  //           child: FlatButton(
  //             //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
  //             onPressed: () {
  //               _handleOptionSelected(1);
  //             },
  //             color: AppColors.orangeAccent,
  //             disabledColor: AppColors.orangeAccent,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //             child: Row(
  //               children: [
  //                 Image.asset("assets/images/Video.png", height: 20, width: 20),
  //                 SizedBox(width: 10),
  //                 Text("Book Video Consultation",
  //                     style: Styles.text(16, Colors.white, true)),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       ButtonTheme(
  //         minWidth: 250,
  //         height: 40,
  //         child: Opacity(
  //           opacity: isDisabled ? .6 : 1,
  //           child: FlatButton(
  //             onPressed: () {
  //               _handleOptionSelected(2);
  //             },
  //             color: AppColors.orangeAccent,
  //             disabledColor: AppColors.orangeAccent,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //             child: Row(
  //               children: [
  //                 Image.asset("assets/images/InPerson.png",
  //                     height: 20, width: 20),
  //                 SizedBox(width: 10),
  //                 Text("Book In Person Consultation",
  //                     style: Styles.text(16, Colors.white, true)),
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  // void _handleTap() {
  //   if (widget.onTap != null) {
  //     widget.onTap(widget.doctorData);
  //   }
  // }

  // void _handleOptionSelected(opt) {
  //   if (widget.onOptionSelected != null) {
  //     widget.onOptionSelected(widget.doctorData, opt);
  //   }
  // }

  // void _rebuildIfOpen() {
  //   if (isOpen) {
  //     setState(() {});
  //   }
  // }
}
