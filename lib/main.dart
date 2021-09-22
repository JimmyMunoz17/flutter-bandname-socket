import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/pages/home.dart';
import 'package:band_names/pages/status.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MultiProvider: inyecta una gran cantidad de información para anidarse
    return MultiProvider(
      providers: [
        // instancias de los modelos
        ChangeNotifierProvider(
            create: (_) =>
                SocketService()) //instancia del socket service "llama socket_service"
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        // redirección a la página con la cual inicia  (initialRoute)
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(), 
          'status': (_) => StatusPage()
          
        },
      ),
    );
  }
}
