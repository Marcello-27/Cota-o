import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request =
    "https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,BTC-BRL";

void main() async {
  runApp(
    MaterialApp(
      home: Home(), debugShowCheckedModeBanner: false,
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _State();
}

class _State extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Cotação"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando Dados...',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar Dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  var data = snapshot.data!;
                  dolar = double.parse(data["USDBRL"]["bid"]);
                  euro = double.parse(data["EURBRL"]["bid"]);

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 120.0,
                          color: Colors.amber,
                        ),
                        SizedBox(height: 20.0,),
                        buildTextField(
                            "Real", "R\$", realController, _realChanged),
                        SizedBox(height: 20.0),
                        buildTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                        SizedBox(height: 20.0),
                        buildTextField(
                            "Euro", "€", euroController, _euroChanged),
                        SizedBox(height: 30.0,),
                        ElevatedButton(
                          onPressed: () {
                            _clearAll();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                          ),
                          child: Text(
                            'Limpar Tudo',
                            style: TextStyle(color: Colors.black),
                          ),
                        )

                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function(String) f) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Container(
      padding: EdgeInsets.only(left: 15.0),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.amber,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          prefixText: prefix,
          contentPadding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
        ),
        onChanged: f,
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
