import 'package:flutter/material.dart';

class MyCircleAvatar extends StatelessWidget {
  final String imgUrl;
  final double size;
  final String personType;
  const MyCircleAvatar(
      {Key key, @required this.imgUrl, @required this.personType, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (size == null) ? 40 : size,
      height: (size == null) ? 40 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.3),
              offset: Offset(0, 2),
              blurRadius: 5)
        ],
      ),
      child: CircleAvatar(
        backgroundImage: (personType == "DOCTOR")
            ? AssetImage("assets/doctor_defaultpic.png")
            : AssetImage("assets/patient_defaultpic.png"),
      ),
    );
  }
}
