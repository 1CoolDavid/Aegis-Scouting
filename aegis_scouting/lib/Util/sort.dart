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
    if(len <= 1) {
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
    if(len <= 1) {
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
    if(len <= 1) {
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

  int getMax(List<int> l, int n) { 
    int max = l[0]; 
    for (int i = 1; i < n; i++) 
      if (l[i] > max) 
          max = l[i]; 
    return max; 
  } 

  void countSort(List<int> nums, int len, int place) {
    List<int> out = new List.filled(len, 0);
    List<int> cnt = new List.filled(10, 0);
    int i;

    for(i = 0; i<len; i++) {
      cnt[(nums[i]~/place)%10]++;
    }

    for(i = 1; i<10; i++) {
      cnt[i] += cnt[i-1];
    }

    for(i= len-1; i>= 0; i--){
      out[cnt[(nums[i]~/place)%10]-1] = nums[i];
      cnt[(nums[i]~/place)%10]--;
    }

    for(i = 0; i<len; i++) {
      nums[i] = out[i];
    }
  }

  List<int> sortTeamList(List<int> nums, int length) {
    int max = getMax(nums, length);

    for(int place = 1; max~/place > 0; place *= 10) {
      countSort(nums, length, place);
    }
    print(nums);
    return nums;
  }
}



