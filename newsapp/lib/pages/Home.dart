import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:newsapp/dto/Reporte.dart';
import 'package:newsapp/srv/ReporteSrv.dart';
import 'package:newsapp/util/network_utils.dart';

//la clase necesita extender StatefulWidget ya que necesitamos hacer cambios en
// la barra inferior de la aplicación según los clics del usuario
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    configLoading();
    return HomeState();
  }
}

List<Marker> markers = [];

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

class HomeState extends State<Home> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  bool clickedCentreFAB =
      false; //booleano utilizado para manejar la animación del contenedor que se expande desde el FAB
  int selectedIndex =
      0; //para controlar qué elemento está actualmente seleccionado en la barra inferior de la aplicación
  String text = "Home";

  bool isFake = false;

  bool _load = false;

  int value = 18;

  String val = "";

  NetworkUtils netUtils = new NetworkUtils();

  late ReporteSrv reporteSrv;

  LatLng? currentLatLng ;

  //llamar a este método al hacer clic en cada elemento de la barra de
  //aplicaciones inferior para actualizar la pantalla
  void updateTabSelection(int index, bool flag) {
    setState(() {
      selectedIndex = index;
      isFake = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    reporteSrv = new ReporteSrv(netUtils);
    Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng = new LatLng(
            currLocation.latitude, currLocation.longitude);
      });
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF311B92),
        title: Text("Reportes"),
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
            child: Text(''),
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
      )),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: FractionalOffset.center,
            child: FutureBuilder<List<Reporte>>(
              future: reporteSrv.loadReportes(http.Client(), isFake),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Reporte>? reportes = snapshot.data;
                  return new CustomListView(reportes!);
                } else if (snapshot.hasError) {
                  print("No data");
                  return Text('${snapshot.error}');
                }
                return new CircularProgressIndicator();
                //return  a circular progress indicator.
              },
            ),
          ),
          //este es el código del contenedor del widget que sale de detrás del botón de acción flotante (FAB)
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              //si clickedCentreFAB == true, se utiliza el primer parámetro. Si es falso, el segundo.
              height:
                  clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              width:
                  clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(clickedCentreFAB ? 0.0 : 300.0),
                  color: Colors.blue),
            ),
          ),
          Align(
              alignment: FractionalOffset.bottomCenter,
              child: _load
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //especifica la localizacion del FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                markers = [];
                return StatefulBuilder(builder: (context, newSetState) {
                  return _buildAboutDialog(context, newSetState);
                });
              });
        },
        tooltip: "Ingresar Reporte",
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Icon(Icons.add),
        ),
        elevation: 4.0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.only(left: 5.0, right: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                //actualizar la vista de la barra inferior de la aplicación cada vez que se hace clic en un elemento
                onPressed: () {
                  EasyLoading.showInfo("Cargando...");
                  updateTabSelection(0, false);
                },
                iconSize: 40.0,
                icon: Icon(
                  Icons.web_rounded,
                  //oscurecer el icono si está seleccionado o darle un color diferente
                  color: selectedIndex == 0
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
              IconButton(
                onPressed: () {
                  EasyLoading.showInfo("Cargando...");
                  updateTabSelection(1, true);
                },
                iconSize: 40.0,
                icon: Icon(
                  Icons.web_asset_off_rounded,
                  color: selectedIndex == 1
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        //to add a space between the FAB and BottomAppBar
        shape: CircularNotchedRectangle(),
        //color of the BottomAppBar
        color: Colors.white,
      ),
    );
  }

  Widget _buildAboutDialog(BuildContext context, newSetState) {
    return new AlertDialog(
      title: const Text(
        'Ingresar Reporte de Robo',
        style: TextStyle(fontSize: 17),
      ),
      content: SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _controllerName ,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre y Apellidos'),
              validator: (value) => value == null ? 'Campo Requerido' : null,
            ),
            SizedBox(
              height: 10.0,
            ),
            DividerWithTextWidget(text: "Edad"),
            DropdownButtonFormField<int>(
                items: <int>[
                  18,
                  19,
                  20,
                  21,
                  22,
                  23,
                  24,
                  25,
                  26,
                  27,
                  28,
                  29,
                  30,
                  32,
                  33,
                  34,
                  35,
                  36,
                  37,
                  38,
                  39,
                  40,
                  41,
                  42,
                  43,
                  44,
                  45,
                  46,
                  47,
                  48,
                  49,
                  50,
                  51,
                  52,
                  53,
                  54,
                  55,
                  56,
                  57,
                  58,
                  59,
                  60,
                  61,
                  62,
                  63,
                  64,
                  65,
                  66,
                  67,
                  68,
                  69,
                  70,
                  71,
                  72,
                  73,
                  74,
                  75,
                  76,
                  77,
                  78,
                  79,
                  80,
                  81,
                  82,
                  83,
                  84,
                  85,
                  86,
                  87,
                  88,
                  89,
                  90,
                  91,
                  92,
                  93,
                  94,
                  95,
                  96,
                  97,
                  98,
                  99,
                  100
                ].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Campo Requerido' : null,
                onChanged: (int? newValue) {
                  setState(() {
                    value = newValue!;
                  });
                }),
            SizedBox(
              height: 10.0,
            ),
            DividerWithTextWidget(text: "Tipo de Robo"),
            DropdownButtonFormField<String>(
                items: <String>[
                  'Asalto en la calle',
                  'Robo de vehículo',
                  'Robo de Motocicleta'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Campo Requerido' : null,
                onChanged: (String? newValue) {
                  setState(() {
                    val = newValue!;
                  });
                }),
            TextFormField(
              controller: _controllerDesc,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descripción del Robo'),
              maxLines: 3,
            ),
            SizedBox(
              height: 10.0,
            ),
            DividerWithTextWidget(text: "Sector Robo"),
            SizedBox(
              height: 200.0,
              width: 300.0,
              child: currentLatLng == null
                  ? Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      initialCameraPosition:
                          CameraPosition(target: currentLatLng!, zoom: 15),
                      markers: markers.toSet(),
                      onTap: (newLatLng) {
                        addMarker(newLatLng, newSetState);
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                if (markers.isEmpty) {
                  BotToast.showText(text: "Ingrese la Ubicación en el Mapa");
                } else {
                  EasyLoading.show(status: 'Cargando...');
                  Navigator.of(context).pop();
                  reporteSrv.createReporte(_controllerName.text, value,
                      markers.elementAt(0).position.latitude.toString()+","+markers.elementAt(0).position.longitude.toString(), _controllerDesc.text,
                      '', val).then((report) {
                        EasyLoading.dismiss();
                        if(report!.isFake==0){
                          BotToast.showText(text: "Su reporte se ha creado Correctamente", duration: Duration(seconds: 10));
                        }else if(report.isFake==1){
                          BotToast.showText(text: "Su reporte parece ser FALSO.", duration: Duration(seconds: 10));
                        }else{
                          BotToast.showText(text: "Al parecer el reporte no está en Español.", duration: Duration(seconds: 10));
                        }
                      })
                  .onError((error, stackTrace) {
                    BotToast.showText(text: "Error al crear Reporte. \n"+error.toString(),duration: const Duration(seconds: 30));
                    Navigator.of(context).pop();
                  });
                  /*BotToast.showText(text: _controllerName.text + "\n"+ "Edad:" +value.toString() + "\n"+
                markers.elementAt(0).position.latitude.toString()+","+markers.elementAt(0).position.longitude.toString()+_controllerDesc.text
                + val, duration: const Duration(seconds: 40));*/
                }
              },
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text('Registrar',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  addMarker(latLng, newSetState) {
    newSetState(() {
      markers.clear();
      markers.add(Marker(markerId: MarkerId('Nuevo'), position: latLng));
    });
  }
}

class CustomListView extends StatelessWidget {
  final List<Reporte> spacecrafts;

  CustomListView(this.spacecrafts);

  Widget build(context) {
    return ListView.builder(
      itemCount: spacecrafts.length,
      itemBuilder: (context, int currentIndex) {
        return createViewItem(spacecrafts[currentIndex], context);
      },
    );
  }

  Widget createViewItem(Reporte reporte, BuildContext context) {
    return new ListTile(
      title: new Card(
        elevation: 5.0,
        child: new Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          padding: EdgeInsets.all(20.0),
          margin: EdgeInsets.all(1.0),
          child: Column(
            children: <Widget>[
              Divider(height: 5.0, color: Colors.transparent),
              ListTile(
                title: Transform.translate(
                  offset: Offset(-16, -20),
                  child: Text(
                    '${reporte.titulo}',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: reporte.isFake == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                trailing: Transform.translate(
                  offset: Offset(25, -30),
                  child: Text(
                    '${reporte.fecha}',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                subtitle: Transform.translate(
                  offset: Offset(-16, 0),
                  child: Text(
                    '${reporte.noticia}',
                    style: new TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                ),
                onTap: () => _onTapItem(context, reporte),
              ),
            ],
          ),
        ),
      ),
    );
    EasyLoading.dismiss();
  }

  void _onTapItem(BuildContext context, Reporte reporte) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(reporte.idNew.toString() + ' - ' + reporte.titulo!)));
  }
}

class DividerWithTextWidget extends StatelessWidget {
  final String text;

  DividerWithTextWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Divider(height: 20, thickness: 5),
    ));

    return Row(children: [line, Text(this.text), line]);
  }
}
