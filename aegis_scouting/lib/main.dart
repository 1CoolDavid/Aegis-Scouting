import 'dart:io';

import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const Color columbiaBlue = const Color.fromRGBO(185, 217, 235, 1);
  static const Color niceBlue = const Color.fromRGBO(15, 221, 231, 1.0);
  static const Color coolBlue = const Color.fromRGBO(3, 169, 252,1);
  static double towerWidth = 0;
  static double towerHeight = 0;
  // This widget is the root of your application.

  static Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> localFile() async {
    final path = localPath();
    return File('$path/Entries.txt');
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Scouting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        '/manager': (BuildContext context) => MyManager(),      
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}


//Public resources
enum Display {
  Form,
  Record,
  Loading,
}

enum PreviousDisplay {
  Form,
  Record,
  Loading,
  None
}

Display display = Display.Loading; 
PreviousDisplay prevDisplay = PreviousDisplay.None;
TeamEntry currentEntry;

int navIndex = 1;

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  //Intro Code
  AnimationController _introController;
  Animation _introFade;

	@override
	void initState(){
	  super.initState();
    if(display == Display.Loading) {
      _introController = new AnimationController(
      duration: const Duration(milliseconds: 3700), 
      vsync: this,
      );
      _introFade = CurvedAnimation(parent:_introController, curve: Curves.fastOutSlowIn);
      _introController.forward();
    }
	}

  @override
	void dispose(){
    super.dispose();
    if(display == Display.Loading)
	    _introController.dispose();
	}

  @override
   void setState(fn) {
    if(this.mounted){
      super.setState(fn);
    } 
  }

  void transitioner(BuildContext c) async {
    Future.delayed(new Duration(seconds: 4)).whenComplete(() {
      setState(() {
        display = Display.Form;
        prevDisplay = PreviousDisplay.Loading;
        Navigator.of(context).pushNamed('/manager');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    if(MyApp.towerWidth == 0.0) {
      MyApp.towerWidth = MediaQuery.of(context).size.width <= 600 ? 0.35 : 0.25;
    }
    if(MyApp.towerHeight == 0) {
      MyApp.towerHeight = MediaQuery.of(context).size.height > 900 ? 0.27 : 0.3; 
    }
    if(display == Display.Loading) {
      transitioner(context);
      return new Scaffold(
        backgroundColor: MyApp.coolBlue,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child:new FadeTransition(
            child: new Image(
              image: new AssetImage("assets/images/WhiteGearCat.png"),
              width: MediaQuery.of(context).size.width*.9,
            ),
            opacity: _introFade,
          ) 
        ),
      );
    } else {
      return new Scaffold(
        backgroundColor: MyApp.coolBlue,
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: new Image(
            image: new AssetImage("assets/images/WhiteGearCat.png"),
            width: MediaQuery.of(context).size.width*.9,
          ),
        ),
      );
    }
  }
}
