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
        map = _sorter.sortEntryMapByTeam(map);
        break;
      case MemoryDataState.Round:
        map = _sorter.sortEntryMapByRound(map);
        break;
      default:
        break;
    }
    map = _sorter.sortEntryMapByRound(map);
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
                   _memState = mem; 
                  });
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<MemoryDataState>>[
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Round,
                      child: Text('Round'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Number,
                      child: Text('Team Number'),
                    ),
                    const PopupMenuDivider(),
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
        body: new ListView(
          children: !_inverted ? entryMap.values.toList().map((t) => t.toWidget(context)).toList() : entryMap.values.toList().map((t) => t.toWidget(context)).toList().reversed.toList()
        ),
      );
    }
  }
}