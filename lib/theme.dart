import 'package:flutter/material.dart';

enum MyThemeKeys { LIGHT1, LIGHT2, LIGHT3, DARK, DARKER }

class MyThemes {
  static final ThemeData lightTheme1 = ThemeData(
    primaryColor: Colors.teal,
    accentColor: Colors.teal[400],
    brightness: Brightness.light,
  );

  static final ThemeData lightTheme2 = ThemeData(
    primaryColor: Colors.indigo,
    accentColor: Colors.indigo[400],
    brightness: Brightness.light,
  );

  static final ThemeData lightTheme3 = ThemeData(
    primaryColor: Colors.amber,
    accentColor: Colors.amberAccent,
    brightness: Brightness.light,
  );
  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey,
    accentColor: Colors.grey[400],
    brightness: Brightness.dark,
  );

  static final ThemeData darkerTheme = ThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.black,
    brightness: Brightness.dark,
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT1:
        return lightTheme1;
      case MyThemeKeys.LIGHT2:
        return lightTheme2;
      case MyThemeKeys.LIGHT3:
        return lightTheme3;
      case MyThemeKeys.DARK:
        return darkTheme;
      case MyThemeKeys.DARKER:
        return darkerTheme;
      default:
        return lightTheme1;
    }
  }
}
