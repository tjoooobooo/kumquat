import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final marktIdController = TextEditingController();
  final artiktelIdController = TextEditingController();
  final artikelController = TextEditingController();
  final preisController = TextEditingController();
  final preisPfandController = TextEditingController();
  final preisEinheitController = TextEditingController();

  void _incrementCounter() {
    if (_formKey.currentState.validate()) {
      print("Formular ist gültig und kann verarbeitet werden");
      // Hier können wir mit den geprüften Daten aus dem Formular etwas machen.
      print(marktIdController.text);
    } else {
      print("Formular ist nicht gültig");
    }
    setState(() async {
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          print(doc["name"]);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: marktIdController,
                decoration: InputDecoration(
                  labelText: 'Filiale',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte die entsprechende Filiale eintragen';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: artiktelIdController,
                decoration: InputDecoration(
                  labelText: 'Artikel-Nr',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte eine ArtikelNr eintragen';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: artikelController,
                decoration: InputDecoration(
                  labelText: 'Artikel',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte einen Artikel eintragen';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: preisController,
                decoration: InputDecoration(
                  labelText: 'Preis',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte einen Preis eintragen';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: preisEinheitController,
                decoration: InputDecoration(
                  labelText: 'Einheitspreis',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte den Preis pro entprechender Einheit eintragen';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: preisEinheitController,
                decoration: InputDecoration(
                  labelText: 'Pfand (nur falls Vorhanden)',
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
