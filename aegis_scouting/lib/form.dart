import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/main.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  MyForm({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyFormPage createState() => MyFormPage();
}

class MyFormPage extends State<MyForm> with SingleTickerProviderStateMixin{
  final formKey = new GlobalKey<FormState>();

  AnimationController _fadeController;
  Animation _displayFade;
  bool switched = true;

  @override
  initState() {
    super.initState();
    _fadeController = new AnimationController(
      duration: const Duration(milliseconds: 2000), 
      vsync: this,
    );
    _displayFade = CurvedAnimation(parent:_fadeController, curve: Curves.easeInExpo);
    _fadeController.forward();
  }


  String _author, _teamNum, _round;
  bool _color = false; //blue is true

  TeamEntry _currentEntry;

  Widget formBuilder(context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      bottomNavigationBar: new FancyBottomNavigation(
        activeIconColor: Color.fromRGBO(255, 255, 255, 1.0),
        inactiveIconColor: Color.fromRGBO(13, 193, 202, 1.0), //sligthly darker than this: 11, 166, 173 or try black
        circleColor: Color.fromRGBO(15, 221, 231, 1.0),
        initialSelection: display == Display.Form || display == Display.Record ? 1 : 
          display == Display.Stats ? 0 : 2, 
        tabs: [
          new TabData(
            iconData: Icons.show_chart, //insert chart
            title: "Statistics", 
          ),
          new TabData(
            iconData: Icons.add, //add box
            title: "Add Entry"
          ),
          new TabData(
            iconData: Icons.storage,
            title: "Storage",
          )
        ],
        onTabChangedListener: (position) {
          formKey.currentState.save();
          if(position == 0) {
            setState(() {
              switched = true;
              display = Display.Stats;
            });
          } else if(position == 1) {
            if(display != Display.Form) {
              setState(() {
                switched = true;
                display = Display.Form;
              });
            }
          } else if(position == 2) {
            setState(() {
              switched = true;
              display = Display.Management;
            });
          } else {
            print(position);
          }
        },
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _color ? Colors.blueAccent : Colors.redAccent,
        title: new Text("FTC Scouting"),
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            child: new FlatButton(
              child: _color ? new Text(
                "Blue",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  decoration: TextDecoration.underline, 
                  decorationColor: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ) : new Text( 
                "Red",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  decoration: TextDecoration.underline, 
                  decorationColor: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                setState(() {
                  _color = !_color;
                });
              },
            ),
          )  
        ],
      ),
      body: new Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: new Form(
          key: formKey,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                flex: 0,
                child: new Image(
                  image: new AssetImage("assets/images/CarolinaGearCat.png"),
                  height: MediaQuery.of(context).size.height*.20,
                ),
              ),
              new Expanded(
                flex: 0,
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new TextFormField(
                    initialValue: _currentEntry != null ? _currentEntry.getAuthor() : "",
                    textAlign: TextAlign.left,
                    onSaved: (value) =>_author = value,
                    validator: (value) => !new RegExp(r'[%0-9!@#$^&*()_\_\\|\[\]{};:.,?~=+"/]').hasMatch(value) && value.isNotEmpty ? null : "Invalid name",
                    decoration: new InputDecoration(
                      labelText: "Your Name",
                      labelStyle: new TextStyle(fontStyle: FontStyle.italic),
                      contentPadding: new EdgeInsets.only(left: 5)
                    ),
                  ),
                ), 
              ),
              new Expanded(
                flex: 0,
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new TextFormField(
                    initialValue: _currentEntry != null ? _currentEntry.getNumber().toString() : "",
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _teamNum = value,
                    validator: (value) => value.isNotEmpty && (int.parse(value) > 0 && int.parse(value)<18000) ? null : "Please enter a valid team #", 
                    decoration: new InputDecoration(
                      labelText: "Team Number",
                      labelStyle: new TextStyle(fontStyle: FontStyle.italic),
                      contentPadding: new EdgeInsets.only(left: 5)
                    ),
                  ),
                ),
              ),
              new Expanded(
                flex: 0,
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new TextFormField(
                    initialValue: _currentEntry != null ? _currentEntry.getRound().toString() : "",
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _round = value,
                    validator: (value) => value.isEmpty || (int.parse(value) < 0 || int.parse(value) > 100) ? "Invalid round #" :null,
                    decoration: new InputDecoration(
                      labelText: "Round",
                      labelStyle: new TextStyle(fontStyle: FontStyle.italic),
                      contentPadding: new EdgeInsets.only(left: 5)
                    ),
                  ),
                ),
              ),
              new Expanded( //Select a color
                flex: 0,
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new RaisedButton(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Icon(Icons.assignment),
                        new Text("Begin Scouting")
                      ],
                    ),
                    onPressed: () {
                      if(formKey.currentState.validate()) {
                        formKey.currentState.save();
                        setState(() {
                          _currentEntry = new TeamEntry(int.parse(_teamNum), int.parse(_round), _color, _author);
                          display = Display.Record;
                        });
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget recordBuilder(context) {
    return new Scaffold(
      bottomNavigationBar: new FancyBottomNavigation(
        activeIconColor: Color.fromRGBO(255, 255, 255, 1.0),
        inactiveIconColor: Color.fromRGBO(13, 193, 202, 1.0), //sligthly darker than this: 11, 166, 173 or try black
        circleColor: Color.fromRGBO(15, 221, 231, 1.0),
        initialSelection: display == Display.Form || display == Display.Record ? 1 : 
          display == Display.Stats ? 0 : 2, 
        tabs: [
          new TabData(
            iconData: Icons.show_chart, //insert chart
            title: "Statistics", 
          ),
          new TabData(
            iconData: Icons.assignment, //add box
            title: "Scouting"
          ),
          new TabData(
            iconData: Icons.storage,
            title: "Storage",
          )
        ],
        onTabChangedListener: (position) {
          formKey.currentState.save();
          if(position == 0) {
            setState(() {
              display = Display.Stats;
            });
          } else if(position == 1) {
            //Do nothing
          } else if(position == 2) {
            setState(() {
              display = Display.Management;
            });
          } else {
            print(position);
          }
        },
      ),
      appBar: new AppBar(
        backgroundColor: _currentEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
        title: new Text(
          "Team "+_currentEntry.getNumber().toString() + ", Round " + _currentEntry.getRound().toString(),
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _color = _currentEntry.getColor(); //Easier than directly editing the AppBar
              display = Display.Form;
              switched = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(display == Display.Form) {
      if(switched) {
        switched = false;
        return new Container(
          child: new FadeTransition(
            child: formBuilder(context),
            opacity: _fadeController,
          )
        );
      }
      return formBuilder(context);
    } else if(display == Display.Record) {
      if(switched) {
        switched = false;
        return new Container(
          child: new FadeTransition(
            child: recordBuilder(context),
            opacity: _fadeController,
          )
        );
      }
      return recordBuilder(context);
    } else if(display == Display.Stats) {
      return new Container();
    } else if(display == Display.Management) {
      return new Container();
    } else {
      return new Container(); //Unreachable
    }
  }
}
