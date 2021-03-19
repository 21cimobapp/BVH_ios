import 'package:civideoconnectapp/utils/backBtnAndImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BackBtn(),
                  // SizedBox(
                  //   height: height * 0.02,
                  // ),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'About',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: height * 0.07),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'assets/images/hospital.png',
                              height: height * 0.20,
                            ),
                            Image.asset(
                              'assets/images/Hospitalogo.png',
                              height: height * 0.15,
                            ),
                            Text(
                              'Bhaktivedanta Hospital & Research Institute is a 200 bedded not-for-profit, multi-specialty, NABH accredited hospital committed to integrated holistic healthcare practice, community service, education and research. The Hospital is a project of Sri Chaitanya Seva Trust which is rendering various community initiatives for the welfare of rural and tribal populations largely in 3 Districts – Thane, Palghar and Mathura.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40.0,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Text('Powered by',
                            style: TextStyle(
                              fontSize: 10,
                            )),
                        Text('21st century informatics (india) pvt. ltd',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('@Copyrights All Rights Reserved',
                            style: TextStyle(fontSize: 10))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
