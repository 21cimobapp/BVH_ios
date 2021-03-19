import 'package:flutter/material.dart';

class Slide {
  final String name;
  final String title;
  final String description;
  final Color color;

  Slide({
    this.title,
    this.name,
    this.description,
    this.color,
  });
}

class DemoData {
  List<Slide> _slides = [
    Slide(
        name: 'slide1',
        title: 'Slide 1',
        description: '',
        color: Color(0xffdee5cf)),
    Slide(
      name: 'slide2',
      title: 'Slide 2',
      description: '',
      color: Color(0xffdaf3f7),
    ),
    Slide(
        name: 'slide3',
        title: 'Slide 3',
        description: '',
        color: Color(0xfff9d9e2)),
  ];

  List<Slide> getSlides() => _slides;
}
