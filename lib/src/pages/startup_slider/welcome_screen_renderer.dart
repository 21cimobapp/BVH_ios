import 'package:flutter/material.dart';
import 'slide_data.dart';
import 'styles.dart';

class WelcomeScreenRenderer extends StatelessWidget {
  final double offset;
  final double cardWidth;
  final double cardHeight;
  final Slide slide;

  const WelcomeScreenRenderer(this.offset,
      {Key key, this.cardWidth = 250, @required this.slide, this.cardHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(top: 8),
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          // Card background color & decoration
          Container(
            margin: EdgeInsets.only(top: 30, left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              //color: slide.color,
              color: Colors.white,
              // borderRadius: BorderRadius.circular(8),
              // boxShadow: [
              //   BoxShadow(color: Colors.black12, blurRadius: 4 * offset.abs()),
              //   BoxShadow(
              //       color: Colors.black12, blurRadius: 10 + 6 * offset.abs()),
              // ],
            ),
          ),
          // slide image, out of card by 15px
          Positioned(top: 0, child: _buildslideImage()),
          // slide information
          //_buildslideData()
        ],
      ),
    );
  }

  Widget _buildslideImage() {
    double maxParallax = 40;
    double globalOffset = offset * maxParallax * 2;
    double cardPadding = 28;
    double containerWidth = cardWidth - cardPadding;
    return Container(
      //color: Colors.grey,
      height: cardHeight,
      width: containerWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          _buildPositionedLayer(
              "assets/images/slide_images/${slide.name}-Bg.png",
              containerWidth * 1,
              maxParallax,
              globalOffset),
          _buildPositionedLayer(
              "assets/images/slide_images/${slide.name}-Back.png",
              containerWidth * 1,
              maxParallax * .1,
              globalOffset),
          _buildPositionedLayer(
              "assets/images/slide_images/${slide.name}-Middle.png",
              containerWidth * 1,
              maxParallax * .6,
              globalOffset),
          _buildPositionedLayer(
              "assets/images/slide_images/${slide.name}-Front.png",
              containerWidth * 1,
              maxParallax,
              globalOffset),
        ],
      ),
    );
  }

  Widget _buildslideData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // The sized box mock the space of the slide image
        SizedBox(width: double.infinity, height: cardHeight * .80),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(slide.title,
              style: Styles.cardTitle, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(slide.description,
              style: Styles.cardSubtitle, textAlign: TextAlign.center),
        ),
        Expanded(
          child: SizedBox(),
        ),
        FlatButton(
          disabledColor: Colors.transparent,
          color: Colors.transparent,
          child: Text('Learn More'.toUpperCase(), style: Styles.cardAction),
          onPressed: null,
        ),
        SizedBox(height: 8)
      ],
    );
  }

  Widget _buildPositionedLayer(
      String path, double width, double maxOffset, double globalOffset) {
    double cardPadding = 24;
    double layerWidth = cardWidth - cardPadding;
    return Positioned(
        left: ((layerWidth * .5) - (width / 2) - offset * maxOffset) +
            globalOffset,
        bottom: cardHeight * .15,
        child: Image.asset(
          path,
          width: width,
          fit: BoxFit.fill,
        ));
  }
}
