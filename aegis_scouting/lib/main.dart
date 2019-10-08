import 'package:aegis_scouting/form.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        '/main': (BuildContext context) => MyForm(),      
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
  Stats,
  Loading,
  Management
}

Display display = Display.Loading; 


class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  //Intro Code
  AnimationController _introController;
  Animation _introFade;

	@override
	void initState(){
	  super.initState();
    if(display == Display.Loading) {
      _introController = new AnimationController(
      duration: const Duration(milliseconds: 2000), 
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

  void transitioner(BuildContext c) {
    Future.delayed(new Duration(seconds: 2)).whenComplete(() {
      setState(() {
        display = Display.Form;
        Navigator.of(context).pushNamed('/main');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(display == Display.Loading) {
      transitioner(context);
      return new Scaffold(
        backgroundColor: Color.fromRGBO(15, 221, 231, 1.0),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child:new FadeTransition(
            child: new Image(
              image: new AssetImage("assets/images/WhiteGearCat.png"),
            ),
            opacity: _introFade,
          ) 
        ),
      );
    } else {
      return new Scaffold(
        backgroundColor: Color.fromRGBO(15, 221, 231, 1.0),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: new Image(
            image: new AssetImage("assets/images/WhiteGearCat.png"),
          ),
        ),
      );
    }
  }
}
