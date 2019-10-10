import 'dart:convert';


import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Team{
  int _number; //id
  List<TeamEntry> _entries = new List(); //Data
  List<int> _stones = new List();
  List<int> _skyStones = new List();
  List<int> _numberOfTowers = new List();
  List<int> _scores = new List();

  //Stats
  double _avgStones, _avgSkyStones, _avgHeight, _avgScore, _avgNumberOfTowers;
  int _maxStoneHeight, _reds, _yellows, _bridges, _autons, _possessions, _len;
  
  Team(int number) {
    _number = number;
    loadData().whenComplete(() {
      _len = _entries.length;
      fillData();
    });
  }

  Future loadData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    json.decode(sp.getString(_number.toString())).forEach(
      (map) => _entries.add(TeamEntry.fromJson(map))
    );
  }
  
  void fillData() {
    double stone, sky, height, hcount, allPoints, towers;
    int maxHeight, red, yellow, bridge, auton, possession;
    for(TeamEntry t in _entries) {
      stone += t.getStones();
      _stones.add(t.getStones());
      sky += t.getSkyStones();
      _skyStones.add(t.getSkyStones());
      t.getFoundation().towers.forEach(
        (tower) { 
          height+=tower.getHeight(); 
          hcount++;
        }
      );
      maxHeight = t.getMaxHeight() > maxHeight ? t.getMaxHeight() : maxHeight;
      allPoints += t.getScore();
      _scores.add(t.getScore());
      towers += t.getNumberOfTowers();
      _numberOfTowers.add(t.getNumberOfTowers());
      red = t.hasRedCard() ? red++ : red;
      yellow = t.hasYellowCard() ? yellow++ : yellow;
      bridge = t.hasBridgePenalty() ? bridge++ : bridge;
      auton = t.hasAutonPenalty() ? auton++ : auton;
      possession = t.hasPossessionPenalty() ? possession++ : possession;
    }
    _avgStones = stone/_len;
    _avgSkyStones = sky/_len;
    _avgHeight = height/hcount;
    _avgScore = allPoints/_len;
    _avgNumberOfTowers = towers/_len;
    _reds = red;
    _yellows = yellow;
    _bridges = bridge;
    _autons = auton;
    _possessions = possession;
  }

  void add(TeamEntry t) {
    _reds += t.hasRedCard() ? 1 : 0;
    _yellows += t.hasYellowCard() ? 1 : 0;
    _bridges += t.hasBridgePenalty() ? 1 : 0;
    _autons += t.hasAutonPenalty() ? 1 : 0;
    _avgNumberOfTowers = ((_avgNumberOfTowers*_len)+t.getNumberOfTowers())/(_len+1);
    _avgScore = ((_avgScore*_len)+t.getScore())/(_len+1);
    _avgHeight = ((_avgHeight*_len)+t.getMaxHeight())/(_len+1);
    _avgSkyStones = ((_avgSkyStones*_len)+t.getSkyStones())/(_len+1);
    _avgStones = ((_avgStones*_len)+t.getStones())/(_len+1);
    _len++;
    _entries.add(t);
  }

  List<TeamEntry> getData() => _entries;

  double getAvgStones() => _avgStones;

  double getAvgSkyStones() => _avgSkyStones;

  double getAvgHeight() => _avgHeight;

  double getAvgAlliancePoints() => _avgScore;

  double getAvgNumberOfTowers() => _avgNumberOfTowers;

  int getMaxStoneHeight() => _maxStoneHeight;

  int getReds() => _reds;

  int getYellows() => _yellows;

  int getBridges() => _bridges;

  int getAutons() => _autons;

  int getPossessions() => _possessions;

  int getLen() => _len;

  Map<String, dynamic> toJson() => {
    'entries':_entries,
    'stones':_stones,
    'skyStones':_skyStones,
    'towers':_numberOfTowers,
    'scores':_scores,
    'avgStones':_avgStones,
    'avgSkyStones':_avgSkyStones,
    'avgHeight' : _avgHeight,
    'avgNumberOfTowers' : _avgNumberOfTowers,
    'avgScore' : _avgScore,
    'maxHeight': _maxStoneHeight,
    'reds' : _reds,
    'yellows':_yellows,
    'bridges':_bridges,
    'possessions':_possessions,
    'autons':_autons,
    'len':_len,
  };

  Team.fromJson(Map<String, dynamic> json) {
    _entries=json['entries'];
    _stones=json['stones'];
    _skyStones=json['skyStones'];
    _numberOfTowers=json['towers'];
    _scores=json['scores'];
    _avgStones=json['avgStones'];
    _avgSkyStones=json['avgSkyStones'];
    _avgHeight=json['avgHeight'];
    _avgNumberOfTowers=json['avgNumberOfTowers'];
    _avgScore=json['avgScore'];
    _maxStoneHeight=json['maxHeight'];
    _reds=json['reds'];
    _yellows=json['yellows'];
    _bridges=json['bridges'];
    _possessions=json['possessions'];
    _autons=json['autons'];
    _len=json['len'];
  }
}