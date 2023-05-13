import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class QuestDetailWidget extends StatefulWidget {
  final String txt;
  final String questKey;
  const QuestDetailWidget({Key? key, required this.txt, required this.questKey}) : super(key: key);

  @override
  _QuestDetailWidgetState createState() => _QuestDetailWidgetState();
}
class _QuestDetailWidgetState extends State<QuestDetailWidget> {
  late String improvement;
  late String questInfo;

  @override
  void initState()  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getImprovement(),
        builder: (context,snap){
          if(snap.hasData) {
            String? result = snap.data?.toStringAsFixed(2);
            return Center(
                child: Scaffold(
                    appBar: AppBar(title: const Text('Aufgabendetails')),
                    body: Container(
                      padding: const EdgeInsets.only(top: 30),
                      alignment: Alignment.center,
                      child: Card(
                          color: const Color(0xB7C2C2C2),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: SingleChildScrollView(child: Column(
                            children: [
                              Padding(padding: const EdgeInsets.all(20),
                                  child: Text(
                                      widget.txt, style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))
                              ),
                              Padding(padding: EdgeInsets.all(20),
                                  child: Text(
                                      questInfo,
                                      style: const TextStyle(fontSize: 16))
                              ),
                              const Padding(padding: EdgeInsets.all(20),
                                  child: Text(
                                      'Auswirkung auf deinen Fußabdruck:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))
                              ),
                              Text('-${result}t CO2e',
                                  style: const TextStyle(fontStyle: FontStyle.italic,
                                      fontSize: 16, color: Color(0xFF1E5400))),
                              ElevatedButton(
                                child: const Text('Abgeschlossen!'),
                                onPressed: () {
                                  questDone();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          MyHomePage(
                                            title: "oekoApp",
                                          )
                                      )
                                  );
                                },
                              )
                            ],
                          ))
                      ),
                    ))
                );
          }else{
            return const Center(child: CircularProgressIndicator());
          }});
  }

  void questDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString("userid") ?? "nouid";

    await http.post(
        //Uri.parse('http://masterbackend.fly.dev/api/quest/done'),
        Uri.parse('http://10.0.2.2:8080/api/quest/done'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'uid': userid,
          'key': widget.questKey
        })
    );
  }

  Future<double> getImprovement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString("userid") ?? "nouid";

    try {
      final response = await http.post(
        //Uri.parse('https://masterbackend.fly.dev/api/quest/improved'),
        Uri.parse('http://10.0.2.2:8080/api/quest/improved'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'uid': userid,
          'key': widget.questKey
        }),
      );

      if (response.statusCode == 200) {
        double yld = double.parse(response.body);
        return yld;
      } else {
        throw Exception('Failed to get improvement.');
      }
    } on TimeoutException {
      return 2.0;
    }
  }

  Future<double> _getImprovement() async {
    questInfo = await getQuestInfo();
    try {
      final doubleValue = await getImprovement();
      return doubleValue;
    } catch (e) {
      print('Error fetching double value: $e');
    }
    return 0.0;
  }

  Future<String> getQuestInfo() async {
    try {

      var url = 'http://10.0.2.2:8080/api/quest/info/${widget.questKey}';
      //var url = 'http://masterbackend.fly.dev/api/quest/info/$userid';
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        return res.body;
      }
      return "";
    }on TimeoutException {
      return "Example Info Text";
    }
  }

}