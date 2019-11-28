import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Data_Mngr/tower.dart';
import 'package:aegis_scouting/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _fadeController.dispose();
    _towerScroller.dispose();
    super.dispose();
  }

  ScrollController _towerScroller;

  final formKey = new GlobalKey<FormState>();

  AnimationController _fadeController;


  String _author, _teamNum, _round;
  bool _color = false; //blue is true

  Widget formBuilder(context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
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
        color: Colors.white,
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
                    initialValue: currentEntry != null ? currentEntry.getAuthor() : "",
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
                    initialValue: currentEntry != null ? currentEntry.getNumber().toString() : "",
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
                    initialValue: currentEntry != null ? currentEntry.getRound().toString() : "",
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _round = value,
                    validator: (value) => value.isEmpty || (int.parse(value) <= 0 || int.parse(value) > 100) ? "Invalid round #" :null,
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
                          if(currentEntry == null) {
                            currentEntry = new TeamEntry(int.parse(_teamNum), int.parse(_round), _color, _author);
                            if(prevDisplay != PreviousDisplay.Record) {
                              currentEntry.getFoundation().towers.add(new Tower(context, _color));
                            }
                          } else {
                            currentEntry.setColor(_color);
                            currentEntry.setNumber(int.parse(_teamNum));
                            currentEntry.setRound(int.parse(_round));
                            currentEntry.setAuthor(_author);
                          }
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
      constraints: t.getHeight() <= 7 ? BoxConstraints.tightFor(height: MediaQuery.of(context).size.height*.27, width: MediaQuery.of(context).size.width*MyApp.towerWidth)
        : BoxConstraints.tightFor(height: MediaQuery.of(context).size.height*.35, width: MediaQuery.of(context).size.width*MyApp.towerWidth),
      duration: new Duration(seconds: 1),
      child: new Card(
        shape: new RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
        ),
        child: new Container(
          margin: EdgeInsets.all(5),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(bottom: .5),
                    child: new IconButton(
                      icon: new Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          t.setHeight(t.getHeight()+1);
                          if(t.getMarker()) {
                            currentEntry.setMarkerHeight(t.getHeight());
                          }
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
                          if(t.getMarker()) {
                            currentEntry.setMarkerHeight(0);
                          }
                          currentEntry.getFoundation().towers.remove(t);
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
                          if(t.getMarker()) {
                            currentEntry.setMarkerHeight(t.getHeight());
                          }
                          if(t.getHeight() == 0) {
                            currentEntry.getFoundation().towers.remove(t);
                          }
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
                          if(currentEntry.hasMarker() && !t.getMarker()) {
                            for(Tower t in currentEntry.getFoundation().towers) {
                              t.setMarker(false);
                              currentEntry.setMarkerHeight(0);
                            }
                          }
                          t.setMarker(!t.getMarker());
                          currentEntry.setMarker(true);
                          currentEntry.setMarkerHeight(t.getHeight());
                        });
                      },
                    )
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: new Text(
                      "("+t.getHeight().toString()+")",
                      style: TextStyle(
                        color: t.getHeight() <= 10 ? Colors.black : Color.fromRGBO(227, 18, 18, 1.0), //ten is the limit
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
      backgroundColor: Colors.white,
      bottomNavigationBar:new Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height*.08,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ 
            new Container(
              height: MediaQuery.of(context).size.height*.1,
              padding: EdgeInsets.only(bottom: 15),
              child: new RaisedButton(
                color: Colors.greenAccent[400],
                shape: new CircleBorder(),
                elevation: 5,
                child: new Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () {
                  currentEntry.submit();
                  setState(() {
                    display =Display.Form;
                    prevDisplay=PreviousDisplay.Record;
                    currentEntry=null;
                  });
                },
              ),   
            )
          ]
        )
      ),    
      appBar: new AppBar(
        backgroundColor: currentEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
        title: new Text(
          "Team "+currentEntry.getNumber().toString() + ", Round " + currentEntry.getRound().toString(),
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _color = currentEntry.getColor(); //Easier than directly editing the AppBar
              display = Display.Form;
              prevDisplay = PreviousDisplay.Record;
            });
          },
        ),
      ),
      body: new Container(
        color: Colors.white,
        child: new SingleChildScrollView(
          padding: EdgeInsets.all(5),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Card(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Total Stones",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height*.02
                      ),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(
                            Icons.arrow_downward, 
                            color: Color.fromRGBO(111, 165, 217, 1), //reddit joke
                          ),
                          highlightColor: Color.fromRGBO(149, 186, 245, 1.0),
                          iconSize: (MediaQuery.of(context).size.width*.10),
                          onPressed: () {
                            if(currentEntry.getStones() != 0) {
                              setState(() {
                                currentEntry.setStones(currentEntry.getStones()-1);
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
                              width: MediaQuery.of(context).size.width*.1,
                            ),
                            new Text(
                              currentEntry.getStones().toString(),
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height*.03
                              ),
                            )
                          ],
                        ),
                        new IconButton(
                          icon: new Icon(
                            Icons.arrow_upward,
                            color: Color.fromRGBO(255,69,0,1), //reddit joke
                          ),
                          highlightColor: Color.fromRGBO(250, 119, 70, 0),
                          iconSize: (MediaQuery.of(context).size.width*.10),
                          onPressed: () {
                            if(currentEntry.getStones() < 60) {
                              setState(() {
                                currentEntry.setStones(currentEntry.getStones()+1);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                )
                
              ),
              new Card(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget> [
                    new Text(
                      "SkyStones",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height*.02,
                      ),
                    ),
                    new FlatButton(
                      child: new Image(
                        image: currentEntry.getSkyStones() == 0 ? AssetImage('assets/images/noskystone.png') : currentEntry.getSkyStones() == 1 ?
                        AssetImage('assets/images/skystone.png') : AssetImage('assets/images/skystones.png'),
                        height: MediaQuery.of(context).size.height*.08,
                        width: MediaQuery.of(context).size.width*.25,
                      ),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          if(currentEntry.getSkyStones() == 1) {
                            currentEntry.setSkyStones(2);
                          } else if(currentEntry.getSkyStones() == 2) {
                            currentEntry.setSkyStones(0);
                          } else {
                            currentEntry.setSkyStones(1);
                          }
                        });
                      },
                    )
                  ]
                ),
              ), 
              new Card(
                child: new Padding(
                  padding: EdgeInsets.all(5),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new ChoiceChip(
                        elevation: currentEntry.hasPlatformIn() ? 5 : 2,
                        label: new Text(
                          "Foundation In",
                          style: currentEntry.hasPlatformIn() ? new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height*.015,
                          ) : new TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height*.015,
                          )
                        ),
                        selectedColor: currentEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                        onSelected: (bool value) { 
                          setState(() {
                            currentEntry.setPlatformIn(value);
                          }); 
                        },
                        selected: currentEntry.hasPlatformIn(),
                        backgroundColor: Colors.white,
                      ),
                      new ChoiceChip(
                        label: new Text(
                          "Foundation Out",
                          style: currentEntry.hasPlatformOut() ? new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height*.015
                          ) : new TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height*.015,
                          )
                        ),
                        selectedColor: currentEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                        onSelected: (bool value) { 
                          setState(() {
                            currentEntry.setPlatformOut(value);
                          }); 
                        },
                        elevation: currentEntry.hasPlatformOut() ? 5 : 2,
                        selected: currentEntry.hasPlatformOut(),
                        backgroundColor: Colors.white,
                      ),
                      new ChoiceChip(
                        elevation: currentEntry.hasParked() ? 5 : 2,
                        label: new Text(
                          "Parked",
                          style: currentEntry.hasParked() ? new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height*.015,
                          ) : new TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height*.015,
                          )
                        ),
                        selectedColor: currentEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                        onSelected: (bool value) { 
                          setState(() {
                            currentEntry.setParking(value);
                          }); 
                        },
                        selected: currentEntry.hasParked(),
                        backgroundColor: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
              new SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _towerScroller,
                child: currentEntry.getFoundation().towers.length != 0 ? new Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: currentEntry.getFoundation().towers.map((t) => towerToWidget(t)).toList() + [
                    new Padding(
                      padding: EdgeInsets.fromLTRB(5, MediaQuery.of(context).size.height*.1, 5, MediaQuery.of(context).size.height*.1),
                      child: new IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            currentEntry.getFoundation().towers.add(new Tower(context, currentEntry.getColor())); 
                          });
                        _towerScroller.animateTo((MediaQuery.of(context).size.width*MyApp.towerWidth)*(currentEntry.getFoundation().towers.length-1), curve: Curves.easeIn, duration: new Duration(seconds: 2));
                        },
                      ),
                    ),
                  ],
                ) : new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: new Text(
                        "Add A Tower",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height*.03
                        ),
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(5, MediaQuery.of(context).size.height*.10, 5, MediaQuery.of(context).size.height*.10),
                      child: new RaisedButton(
                        child: new Icon(
                          Icons.add
                        ), 
                        onPressed: () {
                          setState(() {
                            currentEntry.getFoundation().towers.add(new Tower(context, currentEntry.getColor())); 
                          });
                          _towerScroller.animateTo((MediaQuery.of(context).size.width*MyApp.towerWidth)*(currentEntry.getFoundation().towers.length-1), curve: Curves.easeIn, duration: new Duration(seconds: 2));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(200),
                          side: new BorderSide(color: Colors.black)
                        )       
                      ),
                    ),
                  ],
                )
              ),
              new Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width*.65,
                child: new RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: Colors.orange[500],
                  child: new Text(
                    "Penalties",
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.height*.02
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
              new Container(
                width: MediaQuery.of(context).size.width*.90,
                child: new TextFormField(
                  onChanged: (String value)=> currentEntry.setDescription(value),
                  textAlign: TextAlign.left,
                  decoration: new InputDecoration(
                    labelText: "Description", 
                  ),
                  initialValue: currentEntry.getDescription() == null ? "" : currentEntry.getDescription(),
                )
              ),  
            ],    
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context, [TeamEntry teamEntry]) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    if(display == Display.Form) {
      return formBuilder(context);
    } else if(display == Display.Record) {
      if(prevDisplay == PreviousDisplay.Form) {
        prevDisplay = PreviousDisplay.None;
        currentEntry.getFoundation().towers.forEach((t) => t.setColor(currentEntry.getColor()));
        return new Container(
          child: new FadeTransition(
            child: recordBuilder(context),
            opacity: _fadeController,
          )
        );
      }
      return recordBuilder(context);
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
  Widget build(BuildContext context) {
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
            value: currentEntry.hasAutonPenalty(),
            activeColor: Colors.yellow[700],
            onChanged: (bool value) {
              setState(() {
                currentEntry.setAutonPenalty(value); 
              });
            },
          ), 
          new CheckboxListTile(
            title: new Text(
              "Invalid Possession",
              textAlign: TextAlign.center,
            ),
            value: currentEntry.hasPossessionPenalty(),
            activeColor: Colors.yellow[700],
            onChanged: (bool value) {
              setState(() {
                currentEntry.setPossessionPenalty(value); 
              });
            },
          ),
          new CheckboxListTile(
            title: new Text(
              "SkyBridge Penalty",
              textAlign: TextAlign.center,
            ),
            value: currentEntry.hasBridgePenalty(),
            activeColor: Colors.yellow[700],
            onChanged: (bool value) {
              setState(() {
                currentEntry.setBridgePenalty(value); 
              });
            },
          ),
          new CheckboxListTile(
            title: new Text(
              "Red Card",
              textAlign: TextAlign.center,
            ),
            value: currentEntry.hasRedCard(),
            activeColor: Colors.yellow[700],
            onChanged: (bool value) {
              setState(() {
                currentEntry.setRedCard(value); 
              });
            },
          ),  
          new CheckboxListTile(
            title: new Text(
              "Yellow Card",
              textAlign: TextAlign.center,
            ),
            value: currentEntry.hasYellowCard(),
            activeColor: Colors.yellow[700],
            onChanged: (bool value) {
              setState(() {
                currentEntry.setYellowCard(value);
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