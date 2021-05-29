import 'dart:collection';

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
      title: 'Datenbank Uploader',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Datenbank Uploader'),
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
  final artikelController = TextEditingController();
  final preisController = TextEditingController();
  final preisPfandController = TextEditingController();
  final preisEinheitController = TextEditingController();
  final mengeEinheitController = TextEditingController();

  List<String> spinnerItemsEinheiten = ['kg', 'g', 'ml', 'l'];
  String dropdownValueEinheiten = 'kg';

  List<String> spinnerItemsFilialen = ['Memo', 'Thomas', 'Alex'];
  String dropdownValueFilialen = 'Memo';

  Map storeMap = HashMap<String, String>();

  int artikelId = 0;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> _uploadData() {
    if (_formKey.currentState.validate()) {
      print("Formular ist gültig und kann verarbeitet werden");
      CollectionReference stores = _fireStore
          .collection('stores')
          .doc(dropdownValueFilialen)
          .collection("artikel");
      // Call the user's CollectionReference to add a new user

      return stores
          .add({
            'artikel': artikelController.text,
            'artikelId': artikelId,
            'preis': preisController.text,
            'pfand': preisPfandController.text,
            'einheit': dropdownValueEinheiten,
            'einheitPreis': preisEinheitController.text,
            'einheitMenge': mengeEinheitController.text

          })
          .then((value) => print("Artikel Hinzugefügt"))
          .catchError((error) =>
              print("Artikel konnte nicht hinzugefuegt werden: $error"));
    } else {
      print("Formular ist nicht gültig");
      return null;
    }
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
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text("Filiale:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 25)),
                  ),
                  SizedBox(width: 40),
                  DropdownButton<String>(
                    value: dropdownValueFilialen,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                    onChanged: (String data) {
                      setState(() {
                        dropdownValueFilialen = data;
                      });
                    },
                    items: spinnerItemsFilialen
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
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
              Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
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
                        }),
                  ),
                  SizedBox(width: 40),
                  Flexible(
                    child: TextFormField(
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        controller: mengeEinheitController,
                        decoration: InputDecoration(
                          labelText: 'Menge',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte Menge für den entprechenden Einheitspreis eintragen';
                          }
                          return null;
                        }),
                  ),
                  SizedBox(width: 40),
                  Column(
                    children: [
                      SizedBox(height: 18),
                      DropdownButton<String>(
                        value: dropdownValueEinheiten,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(fontSize: 18),
                        underline: Container(
                          height: 1,
                          color: Colors.black,
                        ),
                        onChanged: (String data) {
                          setState(() {
                            dropdownValueEinheiten = data;
                          });
                        },
                        items: spinnerItemsEinheiten
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: preisPfandController,
                decoration: InputDecoration(
                  labelText: 'Pfand (nur falls Vorhanden)',
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _uploadData,
        tooltip: 'Upload',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
