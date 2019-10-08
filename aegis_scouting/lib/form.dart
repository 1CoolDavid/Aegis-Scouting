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

class MyFormPage extends State<MyForm> {
  final formKey = new GlobalKey<FormState>();

  String _author, _teamNum, _round, _colorTracker = "Red";
  bool _color; //blue is true

  int position; 

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new FancyBottomNavigation(
        activeIconColor: Color.fromRGBO(15, 221, 231, 1.0),
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
          _color = _colorTracker == "Blue";
          if(position == 0) {
            setState(() {
              display = Display.Stats;
            });
          } else if(position == 1) {
            setState(() {
              display = Display.Form;
            });
          } else if(position == 2) {
            setState(() {
              display = Display.Management;
            });
          } else {
            print(position);
          }
        },
      ),
      body: new Container(
        padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
        child: new Form(
          key: formKey,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                flex: 0,
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new TextFormField(
                    textAlign: TextAlign.left,
                    onSaved: (value) =>_author = value,
                    validator: (value) => !new RegExp(r'[%0-9!@#$^&*()_\_\\|\[\]{};:.,?~=+"/]').hasMatch(value) ? null : "Invalid name",
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
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _teamNum = value,
                    validator: (value) => int.parse(value) > 0 && int.parse(value)<18000 ? null : "Please enter a valid team #", 
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
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _round = value,
                    validator: (value) => int.parse(value) < 0 || int.parse(value) > 100 ? "Invalid round #" :null,
                    decoration: new InputDecoration(
                      labelText: "Round",
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
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        groupValue: _colorTracker,
                        value: "Red",
                        activeColor: Colors.red,
                        onChanged: (value) => value ? _colorTracker = "Red" : _colorTracker = "Blue",
                      ), 
                      new Radio(
                        groupValue: _colorTracker,
                        value: "Blue",
                        activeColor: Colors.blue,
                        onChanged: (value) => value ? _colorTracker = "Blue" : _colorTracker = "Red",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
