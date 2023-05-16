import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ResultWidget extends StatefulWidget {
  const ResultWidget({super.key});

  @override
  _ResultWidgetState createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Dein Resultat'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Widget>>(
        future: _getPairs(),
    builder: (context,snap){
    if(snap.hasData) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Column(
              children: snap.data!,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25, right: 25, bottom: 20),
              child: Text('Diese App wurde zu Forschungszwecken erstellt und erfordert daher deine ehrlichen Eingaben! '
                'Bitte versuche die App so ernsthaft wie möglich zu verwenden, ohne falsche Eingaben zu tätigen oder Aufgaben "abzuschließen" '
                'obwohl diese nicht wirklich gemacht wurden. Danke für deine Hilfe!'),
            ),
            ElevatedButton(
              child: Text('Los geht\'s!'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(
                      title: "oekoApp",
                    )
                    ));
              },
            ),
          ],

        ),
      );
      }else{
        return const Center(child: CircularProgressIndicator());
      }
    }));
  }

  Future<List<Widget>> _getPairs() async{
    var essenValue = await getEssen();
    var mobilValue = await getMobil();
    var wohnenValue = await getWohnen();
    var konsumValue = await getKonsum();
    var username = await getUsername();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    List<double> values = [double.parse(essenValue.toStringAsFixed(2)), 1.64, double.parse(mobilValue.toStringAsFixed(2)), 8.89, double.parse(wohnenValue.toStringAsFixed(2)), 1.07, double.parse(konsumValue.toStringAsFixed(2)), 2.64];
    List<Widget> pairs = [];
    pairs.add(Text('Dein zufällig erstellter Username: $username', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
    for (int i = 0; i < values.length; i += 2) {
      pairs.add(
        Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2), color: const Color(0xC0C0C0C5)
          ),
          child: Column(
            children: [
              Text(
                i == 0 ? 'Essen' : i == 2 ? 'Mobilität' : i == 4 ? 'Wohnen' : 'Konsum',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Dein Ergebnis',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        width: 50,
                        height: values[i].toDouble() * 2,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${values[i]}t CO2e',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Durchschnitt',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        width: 50,
                        height: values[i + 1].toDouble() * 2,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${values[i + 1]}t CO2e',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return pairs;
  }


  Future<double> getEssen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString("userid");

    var url = 'http://masterbackend.fly.dev/api/footprint/essen/$userid';
    //var url = 'http://10.0.2.2:8080/api/footprint/essen/$userid';
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      double yld = double.parse(res.body);
      return yld;
    }
    return 0;
  }

  Future<double> getMobil() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString("userid");

    var url = 'http://masterbackend.fly.dev/api/footprint/mobil/$userid';
    //var url = 'http://10.0.2.2:8080/api/footprint/mobil/$userid';
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      double yld = double.parse(res.body);
      return yld;
    }
    return 0;
  }

  Future<double> getWohnen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString("userid");

    var url = 'http://masterbackend.fly.dev/api/footprint/wohnen/$userid';
    //var url = 'http://10.0.2.2:8080/api/footprint/wohnen/$userid';
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      double yld = double.parse(res.body);
      return yld;
    }
    return 0;
  }

  Future<double> getKonsum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString("userid");

    var url = 'http://masterbackend.fly.dev/api/footprint/konsum/$userid';
    //var url = 'http://10.0.2.2:8080/api/footprint/konsum/$userid';
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      double yld = double.parse(res.body);
      return yld;
    }
    return 0;
  }

  Future<String> getUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      //var url = 'http://10.0.2.2:8080/api/username/$userid';
      var url = 'http://masterbackend.fly.dev/api/username/$userid';
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        return res.body;
      }
      return "";
    }on TimeoutException {
      return "TESTNAME";
    }
  }
}