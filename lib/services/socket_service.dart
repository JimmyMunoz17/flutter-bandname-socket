// Script de conexión con el servidor
import 'package:flutter/material.dart';
// conexión con el servidor socket cliente
import 'package:socket_io_client/socket_io_client.dart' as IO;

// variables para la conexión con servidor Estados
enum ServerStatus { Online, Offline, Connecting }

// clase que conecta con el SocketService y los cambios de de notificaciones de conexión y refrescar algún cambio en UI
class SocketService with ChangeNotifier {
  
  // esta conecta al iniciar
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket; // componente de acceso al socket universal

  // controla la conexión con el service status
  ServerStatus get serverStatus => this._serverStatus;
  
  
  IO.Socket get socket => this._socket; // retorna lo que tiene el socket
  Function get emit => this._socket.emit; // función para emitir de forma universal
  

  SocketService() {
    this._initConfig();
  }
  // configuración y conección del servidor socket IO
  void _initConfig() {
    // Documentación de conexión con socket https://pub.dev/packages/socket_io_client
    // Dart client "http://192.168.0.105:3000 ó http://192.168.0.104:3000"
    // http://10.0.2.2:3000
    this._socket = IO.io('http://192.168.0.104:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });
    // cuando esta conectado el servidor -- connect
    this._socket.on('connect', (_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners(); // notifica el estado
    });
    // cuando esta desconectado el servidor -- disconnect
    this._socket.on('disconnect', (_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners(); // notifica el estado
    });
    
    
    //socket.connect();
    // Recibe un mensaje
    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje:');
    //   // recibir los mensajes que están en un mapa
    //   print('nombre:' + payload['nombre']);
    //   print('mensaje:' + payload['mensaje']);
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay mensaje'); //payload.containskey (usado para comparar si esta el objeto del mensaje 2)
    // });
  }
}
