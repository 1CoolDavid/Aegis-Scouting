import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Util/sort.dart';
import 'package:aegis_scouting/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyData extends StatefulWidget {
  MyData({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyDataPage createState() => MyDataPage();
}

enum MemoryDataState{
  Round,
  Number,
  Recent,
}

class MyDataPage extends State<MyData> {
  Sort _sorter = new Sort();
  LinkedHashMap<String, TeamEntry> entryMap = new LinkedHashMap();
  bool _inverted = false;
  MemoryDataState _memState = MemoryDataState.Round;

  Future<void> loadAllData() async {
    LinkedHashMap<String, TeamEntry> map = new LinkedHashMap();
    SharedPreferences sp = await SharedPreferences.getInstance();
    List nums = sp.getKeys().toList();
    for(String team in nums) {
      List<String> jsonList = sp.getStringList(team);
      for(String jsonEntry in jsonList) {
        Map<String, dynamic> jsonObject = jsonDecode(jsonEntry);
        TeamEntry entry = TeamEntry.fromJson(jsonObject);
        map.putIfAbsent(entry.getNumber().toString()+"-"+entry.getRound().toString(), ()=> entry);
      }     
    }
    switch(_memState) {
      case MemoryDataState.Number:
        map = _sorter.sortEntryMapByTeam(map);
        break;
      case MemoryDataState.Recent:
        map = _sorter.sortEntryMapByTime(map);
        break;
      case MemoryDataState.Round:
        map = _sorter.sortEntryMapByRound(map);
        break;
      default:
        break;
    }
    setState(() {
      entryMap = map;
    });
  }

  Future<void> loadTeamData(int team) async {
    LinkedHashMap<String, TeamEntry> map = new LinkedHashMap();
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> jsonList = sp.getStringList(team.toString());
    for(String jsonEntry in jsonList) {
      Map<String, dynamic> jsonObject = jsonDecode(jsonEntry);
      TeamEntry entry = TeamEntry.fromJson(jsonObject);
      map.putIfAbsent(entry.getNumber().toString()+"-"+entry.getRound().toString(), () => entry);
    }
  }
  
  @override
  Widget build(BuildContext context) {  
    if(display == Display.Form) {
      currentEntry = null;
    }  
    if(entryMap.isEmpty || entryMap == null) {
      loadAllData();
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: MyApp.coolBlue,
          title: new Text("Saved Entries"),
          actions: <Widget>[
            new Container(
              alignment: Alignment.centerRight,
              child: new IconButton(
                color: Colors.white,
                icon: new Icon(Icons.filter_list),
                onPressed: () => null
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              color: Colors.white,
              child: new IconButton(
                color: Colors.white,
                icon: new Icon(Icons.more_horiz),
                onPressed: () => null
              ),
            )
          ],
        ),
        body: new Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            new Container(
              alignment: Alignment.center,
              child: new CupertinoActivityIndicator(
                animating: true,
                radius: MediaQuery.of(context).size.width*.15,
              ),
            )
          ],
        ),
      );
    } else {
      return new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          title: new Text("Saved Entries"),
          actions: <Widget>[
            new Container(
              alignment: Alignment.centerRight,
              child: new Transform.rotate(
                angle: _inverted ? pi: 0,
                child: new IconButton(
                  color: Colors.white,
                  icon: new Icon(Icons.filter_list),
                  onPressed: () {
                    setState(() {
                      _inverted = !_inverted;
                    });
                  }
                ),
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              child: new PopupMenuButton(
                icon: Icon(Icons.more_horiz),
                onSelected: (MemoryDataState mem) {
                  setState(() {
                    if(mem == _memState) {
                      return;
                    }
                    _memState = mem;
                    loadAllData(); 
                  });
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<MemoryDataState>>[
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Round,
                      child: Text('Round'),
                    ),
                    const PopupMenuDivider(height: 20,),
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Number,
                      child: Text('Team Number'),
                    ),
                    const PopupMenuDivider(height: 20,),
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Recent,
                      child: Text('Order Entered')
                    )
                  ];
                },
              ),
            )
          ],
        ),
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: !_inverted ? entryMap.values.toList().map((t) => 
            new GestureDetector(
              child: t.toWidget(context), 
              onDoubleTap: () {
                Future<void> showSheet = showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => EntryPanel(t)
                );
                showSheet.whenComplete(() async {
                  if(t.getStones() == -1) {
                    t.delete().whenComplete( () {
                      loadAllData();
                    });
                  } else {
                    t.submit().whenComplete( () {
                      loadAllData();
                    });
                  }
                });
              },
            )).toList() : entryMap.values.toList().map((t) => 
            new GestureDetector(
              child: t.toWidget(context),
              onDoubleTap: () {
                Future<void> showSheet = showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => EntryPanel(t)
                );
                showSheet.whenComplete(() async {
                  if(t.getStones() == -1) {
                    t.delete().whenComplete( () {
                      loadAllData();
                    });
                  } else {
                    t.submit().whenComplete( () {
                      loadAllData();
                    });
                  }
                });
              },
            )).toList().reversed.toList()
          ),
        ),
      );
    }
  }
}

class EntryPanel extends StatefulWidget {
  TeamEntry entry;
  EntryPanel(TeamEntry t) {
    entry = t;
  }

  @override
  _MyEntryPanel createState() => new _MyEntryPanel(entry);
}

class _MyEntryPanel extends State<EntryPanel> {
  TeamEntry teamEntry;
  double position = 0;
  StreamController<double> controller;
  _MyEntryPanel(TeamEntry entry) {
    teamEntry = entry;
    controller = StreamController.broadcast();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream,
      builder:(context,snapshot) {
        return new Container(
          color: Colors.transparent,
          height: snapshot.hasData ? snapshot.data : MediaQuery.of(context).size.height*.35,
          width: MediaQuery.of(context).size.width,
          child: new Scaffold(
            resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            body: Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0)
                )
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details){
                        position = MediaQuery.of(context).size.height-details.globalPosition.dy;
                        position < MediaQuery.of(context).size.height*.2?Navigator.pop(context):
                        position <= MediaQuery.of(context).size.height*.5?controller.add(position): controller.add(MediaQuery.of(context).size.height*.5);
                      },
                      child: new Icon(
                        Icons.drag_handle,
                        size: MediaQuery.of(context).size.width*.05
                      ),
                    ),
                  ),
                  new Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        new Container(
                          padding: EdgeInsets.only(right: 15),
                          child: new Text(
                            teamEntry.getNumber().toString() +", Round #" + teamEntry.getRound().toString(),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height*.02
                            ),
                          ), 
                        ),
                        new Container(
                          padding: EdgeInsets.only(left: 10),
                          child: new GestureDetector(
                            onTap: () {
                              setState(() {
                                teamEntry.setColor(!teamEntry.getColor());
                              });
                            },
                            child: new Container(
                              height: MediaQuery.of(context).size.height*.02,
                              width: MediaQuery.of(context).size.height*.02,
                              color: teamEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                            ),
                          ) 
                        ),
                      ],
                    )
                  ),
                  new Divider(
                    thickness: 1,
                  ),
                  new ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.all(15),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                new Container(
                                  child: new Container(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget> [
                                        new Container(
                                          child: new Text(
                                            "Stones: ",
                                            style: new TextStyle(
                                              fontSize: MediaQuery.of(context).size.height*.02,
                                              fontWeight: FontWeight.w600
                                            ),
                                          )
                                        ),
                                        new Container(
                                          child: new CupertinoButton(
                                            child: Icon(
                                              Icons.expand_more, 
                                              size: MediaQuery.of(context).size.height*.04,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                teamEntry.setStones(teamEntry.getStones()-1);
                                              });
                                            },
                                          ),
                                        ),
                                        new Container(
                                          child: new Text(
                                            teamEntry.getStones().toString(),
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery.of(context).size.height*.02
                                            ),
                                          ),
                                        ), 
                                        new Container(
                                          child: new CupertinoButton(
                                            child: Icon(
                                              Icons.expand_less,
                                              size: MediaQuery.of(context).size.height*.04,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                teamEntry.setStones(teamEntry.getStones()+1);
                                              });
                                            },
                                          ),
                                        )
                                      ]
                                    ),
                                  ),
                                ),
                                new Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget> [
                                      new Container(
                                        child: new Text(
                                          "SkyStones: ",
                                          style: new TextStyle(
                                            fontSize: MediaQuery.of(context).size.height*.02,
                                            fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ),
                                      new Container(
                                        child: new CupertinoButton(
                                          child: Icon(
                                            Icons.expand_more, 
                                            size: MediaQuery.of(context).size.height*.04,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              switch (teamEntry.getSkyStones()) {
                                                case 1:
                                                  teamEntry.setSkyStones(0);
                                                  break;
                                                case 2:
                                                  teamEntry.setSkyStones(1);
                                                  break;
                                                default:
                                                  teamEntry.setSkyStones(2);
                                                  break;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      new Container(
                                        child: new Text(
                                          teamEntry.getSkyStones().toString(),
                                          style: new TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context).size.height*.02
                                          ),
                                        ),
                                      ), 
                                      new Container(
                                        child: new CupertinoButton(
                                          child: Icon(
                                            Icons.expand_less,
                                            size: MediaQuery.of(context).size.height*.04,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              switch (teamEntry.getSkyStones()) {
                                                case 1:
                                                  teamEntry.setSkyStones(2);
                                                  break;
                                                case 2:
                                                  teamEntry.setSkyStones(0);
                                                  break;
                                                default:
                                                  teamEntry.setSkyStones(1);
                                                  break;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ]
                                  ),
                                ),
                              ],
                            ),
                            new Container(
                              alignment: Alignment.center,
                              child: new RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                color: Colors.red,
                                child: new Text(
                                  "DELETE ENTRY",
                                  style: new TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    teamEntry.setStones(-1);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      ),
                    ],
                  )
                ],
              ),
            )
          ),  
        );
      },
    );
  }
}