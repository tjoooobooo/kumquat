import 'dart:html';
import 'dart:typed_data';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api/firebase_api.dart';
import 'widget/button_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Alex stinkts Datenbank Uploader',
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
  final marktIdController = TextEditingController();
  final artikelController = TextEditingController();
  final preisController = TextEditingController();
  final preisPfandController = TextEditingController();
  final preisEinheitController = TextEditingController();
  final mengeEinheitController = TextEditingController();
  final artikelPositionController = TextEditingController();
  bool istAbholbar = false;

  List<String> spinnerItemsEinheiten = ['kg', 'g', 'ml', 'l'];
  String dropdownValueEinheiten = 'kg';

  List<String> spinnerItemsFilialen = ['Memo', 'Thomas', 'Alex'];
  String dropdownValueFilialen = 'Memo';

  Map storeMap = HashMap<String, String>();
  int artikelId = 0;

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  UploadTask task;
  String fileName;
  Uint8List  imageValue;

  /// Selects a file for upload
  Future selectFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile selectedImage = result.files.first;

      setState(() {
        fileName = selectedImage.name;
        imageValue = selectedImage.bytes;
      });

    } else {
      return;
    }

    // for windows app
//    final uploadFile = OpenFilePicker()
//      ..filterSpecification = {
//        'All Files': '*.*',
//      }
//      ..defaultFilterIndex = 0
//      ..defaultExtension = 'png'
//      ..title = 'Select an image';
//
//    final result = uploadFile.getFile();
//    if (result == null) return;
//    final path = result.path;
//
//    setState(() => file = result);
  }

//  Widget buildUploadStatus(UploadTask task) =>
//      StreamBuilder<TaskSnapshot>(
//          stream: task.snapshotEvents,
//          builder: (context, snapshot) {
//            if (snapshot.hasData) {
//              final snap = snapshot.data;
//              final progress = snap.bytesTransferred / snap.totalBytes;
//              final percentage = (progress * 100).toStringAsFixed(2);
//
//              return Text(
//                '$percentage %',
//                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//              );
//            } else {
//              return Container();
//            }
//          }
//      );

  double parseStringToDouble(String number) {
    if (number == "") {
      return 0.0;
    } else {
      return double.parse(number.replaceAll(",", "."));
    }
  }

  int parseStringToInt(String number) {
    if (number == "") {
      return 0;
    } else {
      return int.parse(number);
    }
  }


  Future<void> _uploadData() async {
    if (_formKey.currentState.validate()) {
      Fluttertoast.showToast(
        msg: 'Formular ist gültig und kann verarbeitet werden',
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.black,
        fontSize: 16,
        backgroundColor: Colors.grey[200],
      );
      CollectionReference stores = _fireStore
          .collection('stores')
          .doc(dropdownValueFilialen)
          .collection("articles")
      ;

      // return if no image selected
      if (imageValue == null) return;

      var timestamp = DateTime.now().millisecondsSinceEpoch;
      final destination = 'articleImages/$timestamp-$fileName';
      task = FirebaseApi.uploadBytes(destination, imageValue);

      // return if image upload fails
      if (task == null) return;

      final snapshot = await task.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Call the user's CollectionReference to add a new user
      return stores
          .add({
        'name': artikelController.text,
        'articleId': artikelId,
        'price': parseStringToDouble(preisController.text),
        'deposit': parseStringToDouble(preisPfandController.text),
        'unit': dropdownValueEinheiten,
        'unitPrice': parseStringToDouble(preisEinheitController.text),
        'unitQuantity': parseStringToInt(mengeEinheitController.text),
        'articlePosition': artikelPositionController.text,
        'isCollectible': istAbholbar,
        'articleImage': imageUrl
      })
          .then((value) => {
            setState(() {
              Fluttertoast.showToast(
                msg: 'Artikel Hinzugefügt',
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.black,
                fontSize: 16,
                backgroundColor: Colors.grey[200],
              );
              artikelController.text = "";
              preisController.text = "";
              preisPfandController.text = "";
              preisEinheitController.text = "";
              mengeEinheitController.text = "";
              artikelPositionController.text = "";
              istAbholbar = false;
              imageValue = null;
              fileName = null;
            })
          })
          .catchError((error) => {
            Fluttertoast.showToast(
              msg: "Artikel konnte nicht hinzugefuegt werden: $error",
              toastLength: Toast.LENGTH_SHORT,
              textColor: Colors.black,
              fontSize: 16,
              backgroundColor: Colors.grey[200],
            )
          });
    } else {
      Fluttertoast.showToast(
        msg: "Formular ist nicht gültig",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.black,
        fontSize: 16,
        backgroundColor: Colors.grey[200],
      );
      return null;
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

    if (fileName == null) {
      fileName = 'No Image Selected';
    }

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.black;
      }
      return Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Form(
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
                    if (value != null && value.isEmpty) {
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
                    if (value != null && value.isEmpty) {
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
                            if (value != null && value.isEmpty) {
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
                            if (value != null && value.isEmpty) {
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
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  controller: artikelPositionController,
                  decoration: InputDecoration(
                    labelText: 'Artikel Position',
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Bitte eine Position eintragen';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        "Ist abholbar",
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    SizedBox(width: 30),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: istAbholbar,
                      onChanged: (bool value) {
                        setState(() {
                          istAbholbar = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: 'Select Article Image',
                  icon: Icons.attach_file,
                  onClicked: selectFile,
                ),
                SizedBox(height: 8),
                Center(
                  child: (imageValue != null) ?
                  Container(
                    child: Image.memory(imageValue),
                    width: 300,
                    height: 300
                    ,
                  ) : null,
                ),
                Text(
                  fileName,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
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

