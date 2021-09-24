
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GoogleMapState();
  }
}


class _GoogleMapState extends State<GoogleMapView> {
  late GoogleMapController mapController;

  LatLng? currentLatLng;

  @override
  void initState(){
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) async{
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    Geolocator.getCurrentPosition().then((currLocation){
      setState((){
        currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Robos'),
          backgroundColor: Color(0xFF311B92),
          brightness: Brightness.dark,
        ),
        drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF311B92),
                  ),
                  child: Text('Menú'),
                ),
                ListTile(
                  title: const Text('Reportes de Robos'),
                  trailing: Icon(Icons.web),
                  onTap: () {
                    Navigator.pushNamed(context, "home");
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: const Text('Mapa de Robos'),
                  trailing: Icon(Icons.location_pin),
                  onTap: () {
                    Navigator.pushNamed(context, 'googlemap');
                  },
                  // Update the state of the app.
                ),
              ],
            ),
        ),
        body: currentLatLng == null ? Center(child:CircularProgressIndicator()) : GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: currentLatLng!,
            zoom: 14.0,
          ),
        ),
      ),
    );
  }
}