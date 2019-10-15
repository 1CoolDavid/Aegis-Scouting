import 'dart:convert';

import 'package:aegis_scouting/Data_Mngr/tower.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamEntry{
  int _number, _round, _score, _skyStones, _stones=0, _maxHeight=0, _markerHeight=0, _numberOfTowers=0, _avgTowerHeight=0;
  bool _color=false, _autonInterfere=false, _invalidPossession=false, _skybridge=false, _red=false, _yellow=false, _platformIn=false, _platformOut=false, _parking=false, _marker=false;
  String _author="", _description="";
  DateTime _date;
  Foundation _foundation;
  
  TeamEntry(int number, int round, bool color, String author) {
    _number = number;
    _round = round;
    _color = color;
    _author = author;
  }

  void setNumber(int n) => _number = n;

  void setRound(int r) => _round = r;

  void setScore(int s) => _score = s;

  void setSkyStones(int s) => _skyStones = s;

  void setStones(int s) => _stones = s;

  void setMaxHeight(int h) => _maxHeight = h;

  void setMarkerHeight(int h) => _markerHeight = h;

  void setNumberOfTowers(int t) => _numberOfTowers = t;

  void setAvgTowerHeight(int a) => _avgTowerHeight = a;

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

  int getScore() => _score;

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
    'score' : _score,
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
    'date' : _date
  };

  TeamEntry.fromJson(Map<String, dynamic> json) {
    TeamEntry t = new TeamEntry(json['number'], json['round'], json['color'], json['author']);
    t.setScore(json['score']);
    t.setRound(json['points']);
    t.setSkyStones(json['skyStones']);
    t.setStones(json['stones']);
    t.setMaxHeight(json['maxHeight']);
    t.setNumberOfTowers(json['numberOfTowers']);
    t.setAutonPenalty(json['auton']);
    t.setPossessionPenalty(json['possession']);
    t.setBridgePenalty(json['bridge']);
    t.setRedCard(json['red']);
    t.setYellowCard(json['yellow']);
    t.setPlatformIn(json['platformIn']);
    t.setPlatformOut(json['platformOut']);
    t.setParking(json['parking']);
    t.setMarker(json['marker']);
    t.setDescription(json['description']);
    t.setDate(json['date']);
  }

  void submit() async {
    setDate(DateTime.now());
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<TeamEntry> entries = new List();
    if(sp.get(_number.toString()) == null) {
      entries.add(this);
      sp.setString(_number.toString(), json.encode(entries));
    } else {
      json.decode(sp.getString(_number.toString())).forEach(
        (map) => entries.add(new TeamEntry.fromJson(map))
      );
      entries.add(this);
      sp.setString(_number.toString(), json.encode(entries));
    }
  }
} 