import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Data_Mngr/tower.dart';
import 'package:aegis_scouting/main.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/gestures.dart';
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
bool autonPenalty = false, possessionPenalty = false, skybridge = false, red = false, yellow = false;

class MyFormPage extends State<MyForm> with SingleTickerProviderStateMixin{

  List<Tower> _towers = new List();
  ScrollController _towerScroller;
  String _description ="";

  

  @override
  initState() {
    super.initState();
    _fadeController = new AnimationController(
      duration: const Duration(milliseconds: 2000), 
      vsync: this,
    );
   
    _fadeController.forward();
    _towerScroller = new ScrollController();
  }

  final formKey = new GlobalKey<FormState>();

  AnimationController _fadeController;


  String _author, _teamNum, _round;
  bool _color = false; //blue is true
  bool _marked = false;
  int _stones = 0;

  TeamEntry _currentEntry;

  Widget formBuilder(context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      bottomNavigationBar: new FancyBottomNavigation(
        activeIconColor: Color.fromRGBO(255, 255, 255, 1.0),
        inactiveIconColor: MyApp.coolBlue, //sligthly darker than this: 11, 166, 173 or try black
        circleColor: MyApp.coolBlue,
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
              prevDisplay = PreviousDisplay.Form;
              display = Display.Stats;
            });
          } else if(position == 1) {
            //Nothing should happen
          } else if(position == 2) {
            setState(() {
              prevDisplay = PreviousDisplay.Form;
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
                  image: new AssetImage("assets/images/BlueGearCat.png"),
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
                          prevDisplay = PreviousDisplay.Form;
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

  Widget towerToWidget(Tower t) {
    return new AnimatedContainer(
      constraints: t.getHeight() <= 7 ? BoxConstraints.tightFor(height: MediaQuery.of(context).size.height*.27, width: MediaQuery.of(context).size.width*.25)
        : BoxConstraints.tightFor(height: MediaQuery.of(context).size.height*.35, width: MediaQuery.of(context).size.width*.25),
      duration: new Duration(seconds: 1),
      child: new Card(
        shape: new RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
        ),
        child: new Container(
          margin: EdgeInsets.all(10),
          child: new Row(
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                alignment: Alignment.bottomCenter,
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: new Column(
                    children: t.getTower(),
                  ),
                ),
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new IconButton(
                      icon: new Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          t.setHeight(t.getHeight()+1);
                        });
                      },
                      
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new IconButton(
                      icon: new Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          _towers.remove(t);
                        });
                      },
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new IconButton(
                      icon: new Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          t.setHeight(t.getHeight()-1); 
                        });
                      },
                    ), 
                  ),
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new IconButton(
                      icon: t.getMarker() ? Icon(Icons.flag) : Icon(Icons.outlined_flag),
                      onPressed: () {
                        setState(() {
                          if(_marked && !t.getMarker()) {
                            for(Tower t in _towers) {
                              t.setMarker(false);
                            }
                          }
                          t.setMarker(!t.getMarker());
                          _marked = true;
                        });
                      },
                    )
                  ),
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new Text(
                      "("+t.getHeight().toString()+")",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget recordBuilder(context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      bottomNavigationBar: new FancyBottomNavigation(
        activeIconColor: Color.fromRGBO(255, 255, 255, 1.0),
        inactiveIconColor: MyApp.columbiaBlue, //sligthly darker than this: 11, 166, 173 or try black
        circleColor: MyApp.coolBlue,
        initialSelection: display == Display.Form || display == Display.Record ? 1 : 
          display == Display.Stats ? 0 : 2, 
        tabs: [
          new TabData(
            iconData: Icons.show_chart, //insert chart
            title: "Statistics", 
          ),
          new TabData(
            iconData: Icons.check, //add box
            title: "Submit"
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
              prevDisplay = PreviousDisplay.Record;
            });
          },
        ),
      ),
      body: new Container(
        padding: EdgeInsets.all(5),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Card(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.arrow_downward),
                    iconSize: (MediaQuery.of(context).size.width*.10),
                    onPressed: () {
                      if(_currentEntry.getStones() != 0) {
                        setState(() {
                          _currentEntry.setStones(_currentEntry.getStones()-1);
                          _stones--;
                        });
                      }
                    },
                  ),
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Image(
                        image: AssetImage('assets/images/stone.png'),
                        width: MediaQuery.of(context).size.width*.15,
                      ),
                      new Text(
                        _currentEntry.getStones().toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height*.03
                        ),
                      )
                    ],
                  ),
                  new IconButton(
                    icon: new Icon(Icons.arrow_upward),
                    iconSize: (MediaQuery.of(context).size.width*.10),
                    onPressed: () {
                      if(_currentEntry.getStones() < 60) {
                        setState(() {
                          _currentEntry.setStones(_currentEntry.getStones()+1);
                          _stones++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            new SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _towerScroller,
              child: new Row(
                children: _towers.map((t) => towerToWidget(t)).toList() + [
                  new Padding(
                    padding: EdgeInsets.all(5),
                    child: new IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _towers.add(new Tower(context, _currentEntry.getColor())); 
                        });
                      _towerScroller.animateTo((MediaQuery.of(context).size.width*.3)*(_towers.length-1), curve: Curves.easeIn, duration: new Duration(seconds: 2));
                      },
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width*.65,
              child: new RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: new Text(
                  "Penalties",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return PenaltyDialog();
                    }
                  );    
                },
              ),
            ),
            //TODO: 
            new Container(
              width: MediaQuery.of(context).size.width*.90,
              child: new TextFormField(
                
                onChanged: (String value)=> _description = value,
                textAlign: TextAlign.left,
                decoration: new InputDecoration(
                  labelText: "Description", 
                ),
                initialValue: _description,
              )
            ),  
          ],    
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(display == Display.Form) {
      if(prevDisplay == PreviousDisplay.Loading) {
        return new Container(
          child: new FadeTransition(
            child: formBuilder(context),
            opacity: _fadeController,
          )
        );
      }
      return formBuilder(context);
    } else if(display == Display.Record) {
      if(prevDisplay == PreviousDisplay.Form) {
        _towers.forEach((t) => t.setColor(_currentEntry.getColor()));
        if(_stones > 0) {
          _currentEntry.setStones(_stones);
        }
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

class PenaltyDialog extends StatefulWidget {
  _PenaltyDialogState createState() => new _PenaltyDialogState();
}

class _PenaltyDialogState extends State<PenaltyDialog> {
  
  @override
  Widget build(BuildContext context, {Widget content, List<Widget> choices, Widget title, EdgeInsetsGeometry padding, Color color}) {
    return AlertDialog(
      content:new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new CheckboxListTile(
            title: new Text(
              "Auton Interference",
              textAlign: TextAlign.center,
            ),
            value: autonPenalty,
            activeColor: MyApp.coolBlue,
            onChanged: (bool value) {
              setState(() {
                autonPenalty = value; 
              });
            },
          ), 
          new CheckboxListTile(
            title: new Text(
              "Invalid Possession",
              textAlign: TextAlign.center,
            ),
            value: possessionPenalty,
            activeColor: MyApp.coolBlue,
            onChanged: (bool value) {
              setState(() {
                possessionPenalty = value; 
              });
            },
          ),
          new CheckboxListTile(
            title: new Text(
              "SkyBridge Penalty",
              textAlign: TextAlign.center,
            ),
            value: skybridge,
            activeColor: MyApp.coolBlue,
            onChanged: (bool value) {
              setState(() {
                skybridge = value; 
              });
            },
          ),
          new CheckboxListTile(
            title: new Text(
              "Red Card",
              textAlign: TextAlign.center,
            ),
            value: red,
            activeColor: MyApp.coolBlue,
            onChanged: (bool value) {
              setState(() {
                red = value; 
              });
            },
          ),  
          new CheckboxListTile(
            title: new Text(
              "Yellow Card",
              textAlign: TextAlign.center,
            ),
            value: yellow,
            activeColor: MyApp.coolBlue,
            onChanged: (bool value) {
              setState(() {
                yellow = value; 
              });
            },
          ),
        ],
      ),
                          
      actions: <Widget>[
        new FlatButton(
          child: new Text("Done"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      title: new Text("Select Penalties"),
    );
  }
}
