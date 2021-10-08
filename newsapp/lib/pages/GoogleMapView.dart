
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:newsapp/dto/Reporte.dart';
import 'package:newsapp/srv/ReporteSrv.dart';
import 'package:http/http.dart' as http;
import 'package:newsapp/util/network_utils.dart';

class GoogleMapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    configLoading();
    return _GoogleMapState();
  }
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

List<Marker> markers = [];

class _GoogleMapState extends State<GoogleMapView> {
  late GoogleMapController mapController;

  NetworkUtils netUtils = new NetworkUtils();

  LatLng? currentLatLng;

  late ReporteSrv reporteSrv;

  LatLng? latlng;

  @override
  void initState(){
    markers = [];
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) async{
    EasyLoading.showInfo("Cargando Marcadores...");
    reporteSrv = new ReporteSrv(netUtils);
    reporteSrv.loadReportes(http.Client(), false).then((value) {
      for(Reporte report in value){
        latlng = new LatLng(double.parse(report.coordenadas!.split(',')[0]),
            double.parse(report.coordenadas!.split(',')[1]));
        markers.add(Marker(markerId: MarkerId(report.idNew.toString()),
            position: latlng!,infoWindow: InfoWindow(title: report.titulo)));
        mapController = controller;
        EasyLoading.dismiss();
      }
    }).onError((error, stackTrace) {
      BotToast.showText(text: "No se pueden cargar los Marcadores.", duration: Duration(seconds: 15));
    });
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
                    image: DecorationImage(image:AssetImage("assets/bg/news.jpg"),
                        fit: BoxFit.cover),
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
          markers: markers.toSet(),
          initialCameraPosition: CameraPosition(
            target: currentLatLng!,
            zoom: 14.0,
          ),
        ),
      ),
    );
  }
}