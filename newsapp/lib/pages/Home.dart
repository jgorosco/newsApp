import 'package:flutter/material.dart';

//la clase necesita extender StatefulWidget ya que necesitamos hacer cambios en
// la barra inferior de la aplicación según los clics del usuario
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  bool clickedCentreFAB =
      false; //booleano utilizado para manejar la animación del contenedor que se expande desde el FAB
  int selectedIndex =
      0; //para controlar qué elemento está actualmente seleccionado en la barra inferior de la aplicación
  String text = "Home";

  //llamar a este método al hacer clic en cada elemento de la barra de
  //aplicaciones inferior para actualizar la pantalla
  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
      text = buttonText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: FractionalOffset.center,
            //en esta demostración, sólo se actualiza el texto del botón en función de los clics de la barra inferior de la aplicación
            child: ElevatedButton(
              child: Text(text),
              onPressed: () {},
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, //especifica la localizacion del FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildAboutDialog(context),
          );
        },
        tooltip: "Centre FAB",
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
                  updateTabSelection(0, "Reales");
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
                  updateTabSelection(3, "Falsas");
                },
                iconSize: 40.0,
                icon: Icon(
                  Icons.web_asset_off_rounded,
                  color: selectedIndex == 3
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
}

Widget _buildAboutDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('Ingresar Reporte de Robo'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre y Apellidos'),
        ),
        SizedBox(
          height: 10.0,
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cédula de Identidad'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(
          height: 10.0,
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Descripción del Robo'),
          maxLines: 5,
        ),
      ],
    ),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          primary: Theme.of(context).primaryColor,
        ),
        child: const Text('Registrar'),
      ),
    ],
  );
}
