import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:newsapp/pages/Home.dart';

import 'Routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(builder: BotToastInit()),
      //1. call BotToastInit
      navigatorObservers: [BotToastNavigatorObserver()],
      title: 'News App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xFF311B92, colorPalette),
        accentColor: Color(0xFF311B92),
      ),
      home: Home(),
      initialRoute: 'home',
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

Map<int, Color> colorPalette = {
  50: Color(0xFFEDE7F6),
  100: Color(0xFFD1C4E9),
  200: Color(0xFFB39DDB),
  300: Color(0xFF9575CD),
  400: Color(0xFF7E57C2),
  500: Color(0xFF6E57C2),
  600: Color(0xFF5E35B1),
  700: Color(0xFF512DA8),
  800: Color(0xFF4527A0),
  900: Color(0xFF311B92),
};
