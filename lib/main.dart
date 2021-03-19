//import 'package:civideoconnectapp/src/pages/XDSplash1Patient.dart';
import 'package:civideoconnectapp/src/pages/aboutUs.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/categoryList.dart';
import 'package:civideoconnectapp/src/pages/get_phone.dart';
import 'package:civideoconnectapp/src/pages/login_page.dart';
import 'package:civideoconnectapp/src/pages/startup_slider/startup_slider.dart';
import 'package:civideoconnectapp/startscreen.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/providers/countries.dart';
import 'package:civideoconnectapp/providers/phone_auth.dart';
//import 'package:intro_slider/intro_slider.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:civideoconnectapp/startscreen.dart';
//import 'package:civideoconnectapp/intro_slider.dart';
import 'package:civideoconnectapp/theme.dart';
import 'package:civideoconnectapp/custom_theme.dart';

import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/src/utils/settings.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

//void main() => runApp(MyApp());

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();

  runApp(
    CustomTheme(
      initialThemeKey: MyThemeKeys.LIGHT2,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //secureScreen();
  }

  secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CountryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => PhoneAuthDataProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Video Connect App',
          theme: CustomTheme.of(context),
          home: StartScreen(),
          routes: {
            '/Login': (context) => LoginPage(),
            '/AboutUs': (context) => AboutUs(),
            '/StartupSlider': (context) => StartupSlider(),
            '/CategoryList': (context) => CategoryList()
          },
        )
        //home :HomePageNew(),

        );
  }
}
