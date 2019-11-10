import 'dart:collection';

import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';

class Sort{
  LinkedHashMap<String, TeamEntry> sortEntryMapByRound(LinkedHashMap<String, TeamEntry> map) {
    List<TeamEntry> values = map.values.toList();
    values = sortEntryListByRound(values, values.length);
    LinkedHashMap<String, TeamEntry> sortedMap = new LinkedHashMap();
    values.forEach((t) => sortedMap.putIfAbsent(t.getNumber().toString() + "-" + t.getRound().toString(), () => t));
    return sortedMap;
  }

  List<TeamEntry> sortEntryListByRound(List<TeamEntry> entries, int len) {
    if(len == 1) {
      return entries;
    }
    
    List<TeamEntry> left = new List();
    List<TeamEntry> right = new List();

    int middle = len~/2;

    for(int i = 0; i<middle; i++) {
      left.add(entries[i]);
    }

    for(int j = middle; j<len; j++) {
      right.add(entries[j]);
    }

    left = sortEntryListByRound(left, middle);
    right = sortEntryListByRound(right, len-middle); 

    return roundConcat(left, right);
  }

  List<TeamEntry> roundConcat(List<TeamEntry> left, List<TeamEntry> right) {
    List<TeamEntry> combo = new List(); 
    while(left.isNotEmpty && right.isNotEmpty) {
      if(left[0].getRound() < right[0].getRound()) {
        combo.add(left[0]);
        left.removeAt(0);
      } else if(left[0].getRound() > right[0].getRound()) {
        combo.add(right[0]);
        right.removeAt(0);
      } else {
        if(left[0].getNumber() < right[0].getNumber()) {
          combo.add(left[0]);
          left.removeAt(0);
        } else {
          combo.add(right[0]);
          right.removeAt(0);
        }
      }
    }

    while(left.isNotEmpty) {
      combo.add(left[0]);
      left.removeAt(0);
    }

    while(right.isNotEmpty) {
      combo.add(right[0]);
      right.removeAt(0);
    }

    return combo;
  }

  LinkedHashMap<String, TeamEntry> sortEntryMapByTeam(LinkedHashMap<String, TeamEntry> map) {
    List<TeamEntry> values = map.values.toList();
    values = sortEntryListByTeam(values, values.length);
    LinkedHashMap<String, TeamEntry> sortedMap = new LinkedHashMap();
    values.forEach((t) => sortedMap.putIfAbsent(t.getNumber().toString() + "-" + t.getRound().toString(), () => t));
    return sortedMap;
  }

  List<TeamEntry> sortEntryListByTeam(List<TeamEntry> entries, int len) {
    if(len == 1) {
      return entries;
    }
    
    List<TeamEntry> left = new List();
    List<TeamEntry> right = new List();

    int middle = len~/2;

    for(int i = 0; i<middle; i++) {
      left.add(entries[i]);
    }

    for(int j = middle; j<len; j++) {
      right.add(entries[j]);
    }

    left = sortEntryListByTeam(left, middle);
    right = sortEntryListByTeam(right, len-middle); 

    return teamConcat(left, right);
  }

  List<TeamEntry> teamConcat(List<TeamEntry> left, List<TeamEntry> right) {
    List<TeamEntry> combo = new List(); 
    while(left.isNotEmpty && right.isNotEmpty) {
      if(left[0].getNumber() < right[0].getNumber()) {
        combo.add(left[0]);
        left.removeAt(0);
      } else if(left[0].getNumber() > right[0].getNumber()){
        combo.add(right[0]);
        right.removeAt(0);
      } else {
        if(left[0].getRound() < right[0].getRound()) {
          combo.add(left[0]);
          left.removeAt(0);
        } else {
          combo.add(right[0]);
          right.removeAt(0);
        }
      }
    }

    while(left.isNotEmpty) {
      combo.add(left[0]);
      left.removeAt(0);
    }

    while(right.isNotEmpty) {
      combo.add(right[0]);
      right.removeAt(0);
    }

    return combo;
  }

  LinkedHashMap<String, TeamEntry> sortEntryMapByTime(LinkedHashMap<String, TeamEntry> map) {
    List<TeamEntry> values = map.values.toList();
    values = sortEntryListByTime(values, values.length);
    LinkedHashMap<String, TeamEntry> sortedMap = new LinkedHashMap();
    values.forEach((t) => sortedMap.putIfAbsent(t.getNumber().toString() + "-" + t.getRound().toString(), () => t));
    return sortedMap;
  }

  List<TeamEntry> sortEntryListByTime(List<TeamEntry> entries, int len) {
    if(len == 1) {
      return entries;
    }
    
    List<TeamEntry> left = new List();
    List<TeamEntry> right = new List();

    int middle = len~/2;

    for(int i = 0; i<middle; i++) {
      left.add(entries[i]);
    }

    for(int j = middle; j<len; j++) {
      right.add(entries[j]);
    }

    left = sortEntryListByTime(left, middle);
    right = sortEntryListByTime(right, len-middle); 

    return timeConcat(left, right);
  }

  List<TeamEntry> timeConcat(List<TeamEntry> left, List<TeamEntry> right) {
    List<TeamEntry> combo = new List(); 
    while(left.isNotEmpty && right.isNotEmpty) {
      if(left[0].getDate().isBefore(right[0].getDate())) {
        combo.add(left[0]);
        left.removeAt(0);
      } else {
        combo.add(right[0]);
        right.removeAt(0);
      }
    }

    while(left.isNotEmpty) {
      combo.add(left[0]);
      left.removeAt(0);
    }

    while(right.isNotEmpty) {
      combo.add(right[0]);
      right.removeAt(0);
    }

    return combo;
  }
}



