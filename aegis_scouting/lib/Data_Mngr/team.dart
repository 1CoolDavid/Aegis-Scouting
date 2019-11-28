import 'dart:collection';
import 'dart:convert';
import 'dart:core';


import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Util/sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Team{
  int _number; //id
  List<TeamEntry> _entries = new List(); //Data
  List<int> _stones = new List();
  List<int> _skyStones = new List();
  List<int> _numberOfTowers = new List();
  List<int> _markerHeight = new List();
  List<String> _descriptions = new List();

  //Stats
  double _avgStones = 0, _avgSkyStones = 0, _avgHeight = 0, _avgNumberOfTowers = 0, _avgMarkerHeight = 0;
  int _maxStoneHeight = 0, _reds = 0, _yellows = 0, _bridges = 0, _autons = 0, _possessions = 0, _len = 0, _parking = 0, _foundationIn = 0, _foundationOut = 0, _marker = 0;
  
  Sort _sorter = new Sort();
  
  Team(int number) {
    _number = number;
    loadTeamData(_number).whenComplete(() {
      _len = _entries.length;
      fillData();
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

    map = _sorter.sortEntryMapByRound(map);

    _entries = map.values.toList();
  }
  
  void fillData() {
    double height = 0, hcount = 0;
    for(TeamEntry t in _entries) {
      if(t.getDescription()!="") {
        _descriptions.add("Round "+t.getRound().toString()+": "+t.getDescription());
      }
      _avgStones += t.getStones();
      _stones.add(t.getStones());
      _avgSkyStones += t.getSkyStones();
      _skyStones.add(t.getSkyStones());
      _markerHeight.add(t.getMarkerHeight());
      _avgMarkerHeight+=t.getMarkerHeight();
      t.getFoundation().towers.forEach(
        (tower) { 
          height+=tower.getHeight(); 
          hcount++;
        }
      );
      _maxStoneHeight = t.getMaxHeight() > _maxStoneHeight ? t.getMaxHeight() : _maxStoneHeight;
      _avgNumberOfTowers += t.getNumberOfTowers();
      _numberOfTowers.add(t.getNumberOfTowers());

      _parking = t.hasParked() ? _parking++ : _parking;
      _foundationIn = t.hasPlatformIn() ? _foundationIn++ : _foundationIn;
      _foundationOut = t.hasPlatformOut() ? _foundationOut++ : _foundationOut;
      _marker = t.hasMarker() ? _marker++ : _marker;
      _reds = t.hasRedCard() ? _reds++ : _reds;
      _yellows = t.hasYellowCard() ? _yellows++ : _yellows;
      _bridges = t.hasBridgePenalty() ? _bridges++ : _bridges;
      _autons = t.hasAutonPenalty() ? _autons++ : _autons;
      _possessions = t.hasPossessionPenalty() ? _possessions++ : _possessions;
    }
    _avgStones/=_len;
    _avgSkyStones/=_len;
    _avgHeight=height/hcount;
    _avgNumberOfTowers/=_len;
    _avgMarkerHeight/=_len;
  }

  void add(TeamEntry t) {
    if(t.getDescription() != "") {
      _descriptions.add("Round "+t.getRound().toString()+": "+t.getDescription());
    }
    _reds += t.hasRedCard() ? 1 : 0;
    _yellows += t.hasYellowCard() ? 1 : 0;
    _bridges += t.hasBridgePenalty() ? 1 : 0;
    _autons += t.hasAutonPenalty() ? 1 : 0;
    _avgNumberOfTowers = ((_avgNumberOfTowers*_len)+t.getNumberOfTowers())/(_len+1);
    _avgHeight = ((_avgHeight*_len)+t.getMaxHeight())/(_len+1);
    _avgSkyStones = ((_avgSkyStones*_len)+t.getSkyStones())/(_len+1);
    _avgStones = ((_avgStones*_len)+t.getStones())/(_len+1);
    _len++;
    _entries.add(t);
  }

  List<TeamEntry> getData() => _entries;

  List<int> getStoneData() => _stones;

  List<int> getSkyStoneData() => _skyStones;

  List<int> getTowerData() => _numberOfTowers;

  List<int> getMarkerData() => _markerHeight;

  List<String> getDescriptions() => _descriptions;

  double getAvgStones() => _avgStones;

  double getAvgSkyStones() => _avgSkyStones;

  double getAvgHeight() => _avgHeight;

  double getAvgNumberOfTowers() => _avgNumberOfTowers;

  double getAvgMarkerHeight() => _avgMarkerHeight;

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
    'avgStones':_avgStones,
    'avgSkyStones':_avgSkyStones,
    'avgHeight' : _avgHeight,
    'avgNumberOfTowers' : _avgNumberOfTowers,
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
    _avgStones=json['avgStones'];
    _avgSkyStones=json['avgSkyStones'];
    _avgHeight=json['avgHeight'];
    _avgNumberOfTowers=json['avgNumberOfTowers'];
    _maxStoneHeight=json['maxHeight'];
    _reds=json['reds'];
    _yellows=json['yellows'];
    _bridges=json['bridges'];
    _possessions=json['possessions'];
    _autons=json['autons'];
    _len=json['len'];
  }
}