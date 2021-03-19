import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SlidingCardsView extends StatefulWidget {
  @override
  _SlidingCardsViewState createState() => _SlidingCardsViewState();
}

class _SlidingCardsViewState extends State<SlidingCardsView> {
  PageController pageController;
  double pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      setState(() => pageOffset = pageController.page);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: PageView(
        controller: pageController,
        children: <Widget>[
          SlidingCard(
            name: 'Hospital',
            descr: '',
            date: '',
            assetName:
                'https://cdn.docprime.com/media/hospital/images/bhaktivedanta-hospital.jpg',
            offset: pageOffset,
          ),
          SlidingCard(
            name: 'Organisational Culture based on Spirituality',
            descr: '',
            date: '',
            assetName:
                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR2LjCQPoSMLYVPv8SZYMdySLLnpkPYeEIa2A&usqp=CAU',
            offset: pageOffset - 1,
          ),
          SlidingCard(
            name: 'Services',
            descr: '',
            date: '',
            assetName:
                'https://www.bhaktivedantahospital.com/media/1220/bhaktivedanta-clinic.jpg',
            offset: pageOffset - 1,
          )
        ],
      ),
    );
  }
}

class SlidingCard extends StatelessWidget {
  final String name;
  final String descr;
  final String date;
  final String assetName;
  final double offset;

  const SlidingCard({
    Key key,
    @required this.name,
    @required this.descr,
    @required this.date,
    @required this.assetName,
    @required this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double gauss = math.exp(-(math.pow((offset.abs() - 0.5), 2) / 0.08));
    return Transform.translate(
      offset: Offset(-32 * gauss * offset.sign, 0),
      child: Card(
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 24),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              child: Image.network(
                '$assetName',
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment(-offset.abs(), 0),
                fit: BoxFit.none,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: CardContent(
                name: name,
                descr: descr,
                date: date,
                offset: gauss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  final String name;
  final String descr;
  final String date;
  final double offset;

  const CardContent(
      {Key key,
      @required this.name,
      @required this.descr,
      @required this.date,
      @required this.offset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Transform.translate(
            offset: Offset(8 * offset, 0),
            child: Text(name, style: TextStyle(fontSize: 20)),
          ),
          SizedBox(height: 8),
          Transform.translate(
            offset: Offset(32 * offset, 0),
            child: Text(
              descr,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Spacer(),
          Row(
            children: <Widget>[
              // Transform.translate(
              //   offset: Offset(48 * offset, 0),
              //   child: RaisedButton(
              //     color: Color(0xFF162A49),
              //     child: Transform.translate(
              //       offset: Offset(24 * offset, 0),
              //       child: Text('View'),
              //     ),
              //     textColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(32),
              //     ),
              //     onPressed: () {},
              //   ),
              // ),
              Spacer(),
              Transform.translate(
                offset: Offset(32 * offset, 0),
                child: Text(
                  date,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(width: 16),
            ],
          )
        ],
      ),
    );
  }
}
