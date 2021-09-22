import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  __HomePageState createState() => __HomePageState();
}

class __HomePageState extends State<HomePage> {
  List<Band> bands = [
    // new Band(id: '1', name: 'Metallica', vote: 5),
    // new Band(id: '2', name: 'Queen', vote: 3),
    // new Band(id: '3', name: 'Banda', vote: 9),
    // new Band(id: '4', name: 'Tbt', vote: 2),
  ];

  // initState Called when this object is inserted into the tree.
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context,
        listen:
            false); // acceso al socket server, listen: false "no se necesita redibujar"

    socketService.socket.on('active-bands', _handActiveBands);
    super.initState();
  }

  //Método que actualiza información desde el servidor
  _handActiveBands(dynamic payload) {
    //print(payload);
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  //Destruir home cuando no se está escuchando se hace una limpieza.
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context,
        listen:
            false); // acceso al socket server, listen: false "no se necesita redibujar"
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService =
        Provider.of<SocketService>(context); // acceso al socket server

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandName',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          //Estado de conexión con el servidor desde el ServerStatus
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          (bands.isNotEmpty) ? 
          _showGraph(): 
          Text(
             'No hay bandas',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          // expande toma todo el tamaño de la columna.
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), elevation: 1, onPressed: addNewBand),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      // animación para eliminar hacia un costado los elementos de la lista
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      //Llama el borrado en el servidor 'Server'
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          )),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.vote}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    // forma que se va a mostrar en android
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller:
                      textController, // variable que almacena el texto del text field
                ),
                actions: <Widget>[
                  MaterialButton(
                      child: Text('Add'),
                      elevation: 5, // eleva la franga del texto del text field
                      textColor: Colors.blue,
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    }
    // forma en que se va a mostar en IOS
    showCupertinoDialog(
        context: context,
        // la raya abajo es usado para no usar una propiedad (_)
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  // Método del textfield

  void addBandToList(String name) {
    if (name.length > 1) {
      // Agregar nueva banda

      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});

      // Agregar nuevas bandas sin el servidor
      //this.bands.add(new Band(id: DateTime.now().toString(), name: name, vote: 0));
      //setState(() {});
    }

    Navigator.pop(context);
  }

  // widget para gráficar
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.vote.toDouble());
    });
    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.red[50],
      Colors.red[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];

    return Container(
        padding: EdgeInsets.only(top: 20),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 25,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
        ));
  }
}
