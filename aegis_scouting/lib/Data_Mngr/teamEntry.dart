import 'dart:convert';

import 'package:aegis_scouting/Data_Mngr/tower.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamEntry{
  int _number, _round, _skyStones=0, _stones=0, _maxHeight=0, _markerHeight=0, _numberOfTowers=0;
  bool _color=false, _autonInterfere=false, _invalidPossession=false, _skybridge=false, _red=false, _yellow=false, _platformIn=false, _platformOut=false, _parking=false, _marker=false;
  String _author="", _description="";
  DateTime _date;
  Foundation _foundation;
  
  TeamEntry(int number, int round, bool color, String author) {
    _number = number;
    _round = round;
    _color = color;
    _author = author;
    _foundation = new Foundation();
  }

  void setNumber(int n) => _number = n;

  void setRound(int r) => _round = r;

  void setSkyStones(int s) => _skyStones = s;

  void setStones(int s) => _stones = s;

  void setMaxHeight(int h) => _maxHeight = h;

  void setMarkerHeight(int h) => _markerHeight = h;

  void setNumberOfTowers(int t) => _numberOfTowers = t;

  void setColor(bool c) => _color = c;

  void setAutonPenalty(bool a) => _autonInterfere = a;

  void setPossessionPenalty(bool p) => _invalidPossession = p;

  void setBridgePenalty(bool b) => _skybridge = b;

  void setRedCard(bool r) => _red = r;

  void setYellowCard(bool y) => _yellow = y;

  void setPlatformIn(bool p) => _platformIn = p;

  void setPlatformOut(bool p) => _platformOut = p;

  void setParking(bool p) => _parking = p;

  void setMarker(bool m) => _marker = m;

  void setAuthor(String a) => _author = a;

  void setDescription(String d) => _description = d;

  void setDate(DateTime dt) => _date = dt;

  int getNumber() => _number;

  int getRound() => _round;

  int getSkyStones() => _skyStones;

  int getStones() => _stones;

  int getMaxHeight() => _maxHeight;

  int getMarkerHeight() => _markerHeight;

  int getNumberOfTowers() => _numberOfTowers;

  bool getColor() => _color;

  bool hasAutonPenalty() => _autonInterfere;

  bool hasPossessionPenalty() => _invalidPossession;

  bool hasBridgePenalty() => _skybridge;

  bool hasRedCard() => _red;

  bool hasYellowCard() => _yellow;

  bool hasPlatformIn() => _platformIn;

  bool hasPlatformOut() => _platformOut;

  bool hasMarker() => _marker;

  bool hasParked() => _parking;

  String getAuthor() => _author;

  String getDescription() => _description;

  Foundation getFoundation() => _foundation;

  DateTime getDate() => _date;

  String toString() {
    return "Team-"+_number.toString()+"_Round-"+_round.toString();
  }

  bool equals(TeamEntry t) => t.getNumber() == _number && t.getRound() == _round;

  //-1, you go before. 1, you go after. 0, equal
  int compareTo(TeamEntry t) {
    if(t.getNumber() > _number) {
      return -1;
    } else if(t.getNumber() < _number) {
      return 1;
    } else {
      if(t.getRound() > _round) {
        return -1;
      } else if(t.getRound() < _round) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'number' : _number,
    'round' : _round,
    'skyStones' : _skyStones,
    'stones' : _stones,
    'maxHeight' : _maxHeight,
    'markerHeight' : _markerHeight,
    'numberOfTowers' : _numberOfTowers,
    'color' : _color,
    'auton' : _autonInterfere,
    'possession' : _invalidPossession,
    'bridge' : _skybridge,
    'red' : _red,
    'yellow' : _yellow,
    'platformIn' : _platformIn,
    'platformOut' : _platformOut,
    'parking' : _parking,
    'marker' : _marker,
    'author' : _author,
    'description' : _description,
    'foundation' : _foundation.toJson(),
    'date' : _date.toString()
  };

  TeamEntry.fromJson(Map<String, dynamic> json) {
    _number = json['number'];
    _round = json['round'];
    _color = json['color'];
    _author = json['author'];
    _skyStones = json['skyStones'];
    _stones = json['stones'];
    _maxHeight = json['maxHeight'];
    _numberOfTowers = json['numberOfTowers'];
    _autonInterfere = json['auton'];
    _invalidPossession = json['possession'];
    _skybridge = json['bridge'];
    _red = json['red'];
    _yellow = json['yellow'];
    _platformIn = json['platformIn'];
    _platformOut = json['platformOut'];
    _parking = json['parking'];
    _marker = json['marker'];
    _description = json['description'];
    _date = DateTime.parse(json['date']);
    _foundation = new Foundation();
    _foundation.towers = json['foundation'] != null ? Foundation.fromJson(List.from(json['foundation'])).towers : new List();
  }

  Widget toWidget(BuildContext context) {
    return new Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child:  new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Container(
                color: _color ? Colors.blueAccent : Colors.redAccent,
                height: MediaQuery.of(context).size.height*.01,
                width: MediaQuery.of(context).size.height*.01,
              ),
              new Container(
                child: new Text("Team " +_number.toString() +", Round #"+_round.toString()),
                padding: EdgeInsets.only(left: 15),
              ),
            ],
          ),
          new Text("Stones: "+_stones.toString()),
          new Text("SkyStones: "+_skyStones.toString()),
          new Text("Towers: " +_numberOfTowers.toString()),
        ],
      ),
    );
  }

  Future<void> submit() async {
    setDate(DateTime.now());
    setNumberOfTowers(_foundation.towers.length);
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> entries = new List();
    if(sp.get(_number.toString()) == null) {
      entries.add(json.encode(this));
      sp.setStringList(_number.toString(), entries);
    } else {
      entries = sp.getStringList(_number.toString());
      for(String jsonEntries in entries.toList()) {
        if(TeamEntry.fromJson(jsonDecode(jsonEntries)).getRound() == _round) {
          entries.remove(jsonEntries);
        }
      }
      entries.add(json.encode(this));
      sp.setStringList(_number.toString(), entries);
    } 
  }

  Future<void> delete() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> entries = new List();
    entries = sp.getStringList(_number.toString());
    for(String jsonEntries in entries.toList()) {
      if(TeamEntry.fromJson(jsonDecode(jsonEntries)).getRound() == _round) {
        entries.remove(jsonEntries);
      }
      sp.setStringList(_number.toString(), entries);
    }
  }
} 