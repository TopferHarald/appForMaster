import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/questDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'entities/user.dart';
import 'noti.dart';
import 'setupScreen.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;

import 'package:google_fonts/google_fonts.dart';

int? initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt('initScreen');
  print(prefs.getString('userid'));
  NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'oekoApp',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        textTheme: GoogleFonts.robotoSlabTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: initScreen == 1 ? "/" : "setup",
      routes: {
        '/': (context) => MyHomePage(
          title: "oekoApp",
        ),
        "setup": (context) => const FootprintWidget(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<User> _players;
  int _selectedIndex = 0;
  late Map _quests;
  List<String> questTxt = [];
  List<Widget> pairs = [];
  List values = [];
  String username = "";

  @override
  void initState() {
    super.initState();
  }

  Future<List<Widget>> _getWidgetOptions () async {
    try {
      _players = await getLeaderboard();
      _quests = await getQuests();
      for (var entry in _quests.entries) {
        questTxt.add(entry.value);
      }
    } catch (e) {
      print('Error fetching value: $e');
    }

    values = await getAllFootprint();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    pairs = [];
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
                i == 0 ? 'Dein gesamter Fußabdruck' : i == 2 ? 'Essen' : i == 4 ? 'Mobilität' : i == 6 ? 'Wohnen' : 'Konsum',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Aktueller Wert',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        width: 50,
                        height: values[i].toDouble() * 2,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${double.parse('${values[i]}').toStringAsFixed(2)}t CO2e',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Dein Startwert',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        width: 50,
                        height: values[i + 1].toDouble() * 2,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${double.parse('${values[i + 1]}').toStringAsFixed(2)}t CO2e',
                        style: const TextStyle(fontSize: 18),
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

    var widgets = [
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Column(
              children: pairs,
            )
          ],
        ),
      ),
      ListView.builder(
        itemCount: _quests.length,
        itemBuilder: (BuildContext context, int index) {
          String key = _quests.keys.elementAt(index);
          return ListTile(
              title: Text(_quests[key]),
              leading: const Icon(Icons.star_border_outlined),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuestDetailWidget(questKey: key, txt: _quests[key],)));
            },
          );
        },
      ),
      ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          final rank = index + 1;
          return ListTile(
            leading: Text(
              '$rank',
              style: GoogleFonts.roboto(
                fontWeight: player.name == username ? FontWeight.bold : FontWeight.normal,
                fontSize: 20,
              ),
            ),
            title: Text(
              player.name,
              style: GoogleFonts.roboto(
                fontWeight: player.name == username ? FontWeight.bold : FontWeight.normal,
                fontSize: 20,
              ),
            ),
            trailing: Text(
              '${player.score.toStringAsFixed(2)}t CO2e',
              style: GoogleFonts.roboto(
                fontWeight: player.name == username ? FontWeight.bold : FontWeight.normal,
                fontSize: 20,
              ),
            ),
          );
        },
      )
    ];
    return widgets;
  }

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Hallo $username'),
          actions: <Widget>[
            IconButton(icon: const Icon(
              Icons.question_mark_rounded,
              color: Colors.black,
            ),
          onPressed: () {
            _showInfoDialog();
          })],
          automaticallyImplyLeading: false
        ),
        body: FutureBuilder(
          future: _getWidgetOptions(),
          builder: (context,snap){
            if(snap.hasData) {
              return Center(
                child: snap.data?.elementAt(_selectedIndex)
              );
            }else{
              return const Center(child: CircularProgressIndicator());
            }
        }),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Aufgaben',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
    }


    Future<List<User>> getLeaderboard() async {
      try {
        //var url = 'http://10.0.2.2:8080/api/leaderboard/all';
        var url = 'http://masterbackend.fly.dev/api/leaderboard/all';
        var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          Iterable l = json.decode(res.body);
          List<User> users = List<User>.from(
              l.map((model) => User.fromJson(model)));
          return users;
        }
        return [];
      }on TimeoutException {
        User u1 = User("1", "Max", 100);
        User u2 = User("2", "Julia", 200);
        User u3 = User("3", "Peter", 300);
        return [u1, u2, u3];
      }
    }

  Future<Map> getQuests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      //var url = 'http://10.0.2.2:8080/api/quest/new/$userid';
      var url = 'http://masterbackend.fly.dev/api/quest/new/$userid';
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        return result;
      }
      return {};
    } on TimeoutException{
      Map quests = {
        "test0": "Complete your profile by filling in all the required information",
        "test1": "Search for a product or service you're interested in and save it to your wishlist",
        "test2": "Leave a review for a product or service you've purchased",
        "test3": "Refer a friend to the app and get a discount on your next purchase",
        "test4": "Complete a purchase using a promo code",
        "test5": "Complete a quiz to earn points or rewards",
        "test6": "Share a product or service on social media",
        "test7": "Write a blog post or article about your experience with the app",
        "test8": "Attend a virtual event or webinar hosted by the app",
        "test9": "Give feedback on a new feature or update"
      };
      return quests;
    }
  }

  Future<List> getAllFootprint() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      //var url = 'http://10.0.2.2:8080/api/footprint/all/$userid';
      var url = 'http://masterbackend.fly.dev/api/footprint/all/$userid';
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        var x = res.body;
        return jsonDecode(x);
      }
      return [];
    }on TimeoutException {
      return [10, 20, 30, 40, 50, 60, 70, 80];
    }
  }

  Future<void> _showInfoDialog() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Bedienungsanleitung'),
            children: <Widget>[
              Padding(padding: const EdgeInsets.all(20), child:
                RichText(text: TextSpan(style:
                const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontFamily: 'Montserrat'),
                  children: <TextSpan> [
                    TextSpan(text: 'Home: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: 'Hier sieht man deinen aktuellen Fussabdruck, verglichen mit deinem Startwert. Je weniger CO2e du verursachst, desto besser.')]),
                )),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.all(20), child:
                RichText(text: TextSpan(style:
                const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
                    children: <TextSpan> [
                      TextSpan(text: 'Aufgaben: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'Hier hast du deine aktuellen Aufgaben. Du bekommst Aufgaben zu den Kategorien in denen du am schlechtesten abschneidest. Sobald du die Aufgaben erledigt hast, wird sich dein CO2e Score verbessern und du bekommst neue Aufgaben.')]),
                )),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.all(20), child:
                RichText(text: TextSpan(style:
                const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
                    children: <TextSpan> [
                      TextSpan(text: 'Leaderboard: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'Hier kannst du sehen wo du gerade im Vergleich zu den anderen Usern stehst. Versuche dich so weit wie moeglich an die Spitze der Rangliste zu arbeiten, indem du Aufgaben erledigst.')]),
                ))
            ],
          );
        });
  }
}
