import 'package:flutter/material.dart';
import 'package:newsapp/pages/GoogleMapView.dart';
import 'package:newsapp/pages/Home.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
      case "home":
        return MaterialPageRoute(builder: (_) => Home());
      case "googlemap":
        return MaterialPageRoute(builder: (_) => GoogleMapView());
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
