import 'dart:collection';
import 'dart:convert';

import 'package:aegis_scouting/Data_Mngr/team.dart';
import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Util/sort.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _MyStatisticsPage createState() => new _MyStatisticsPage();
}

class _MyStatisticsPage extends State<StatisticsPage> {

  List<String> options = new List();
  String choice;
  String comment;
  Team team;
  bool empty = false;
  Sort _sorter = new Sort();

  Future<void> getOptions() async {
    List<String> tracker = new List();
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> jsonList = sp.getKeys().toList();
    for(String key in jsonList) {
      tracker.add(key);
    }
    List<int> holder = new List();
    holder = _sorter.sortTeamList(tracker.map((s) => int.parse(s)).toList(), tracker.length);
    tracker = holder.map((i) => i.toString()).toList();
    
    setState(() {
      options = tracker;
      choice = options[0];
      team = new Team(int.parse(choice));
    });
  }

  void wait(BuildContext c) async {
    Future.delayed(new Duration(seconds: 4)).whenComplete(() {
      if(options == null || options.isEmpty) {
        setState(() {
          empty = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(empty) {
      return new Scaffold(
        backgroundColor: Colors.white,
        body: new Container(
          child: new Center(
            child: new Text(
              "No Data Found",
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height*.03
              ),
            )
          ),
        ),
      );
    } else if(options == null || options.isEmpty) {
      getOptions();
      wait(context);
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueAccent,
          title: new Text("Team Analytics"),
          automaticallyImplyLeading: false,
        ),
        body: new Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            new Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: new Column(
                children: <Widget> [
                  new CupertinoActivityIndicator(
                    animating: true,
                    radius: MediaQuery.of(context).size.width*.15,
                  ),
                  new Text(
                    "Searching For Data Entries",
                    style: new TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: MediaQuery.of(context).size.height*.03
                    )
                  )
                ]
              )
            ),
          ],
        ),
      );
    } else if(team == null || team.getData().isEmpty) {
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueAccent,
          title: new Text("Team Analytics"),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            new DropdownButton(
              value: choice,
              items: options.map(
                (String option) => DropdownMenuItem(
                  value: option,
                  child: new Text(option)
                )
              ).toList(),
              onChanged: (String value) {
                setState(() {
                  choice = value;
                  team = new Team(int.parse(choice));
                });
              },
            )
          ],
        ),
        body: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: new Column(
                children: <Widget> [
                  new CupertinoActivityIndicator(
                    animating: true,
                    radius: MediaQuery.of(context).size.width*.15,
                  ),
                  new Text(
                    "Gathering Team Data",
                    style: new TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: MediaQuery.of(context).size.height*.03
                    )
                  )
                ]
              )
            ),
          ],
        ),
      );
    } else { //Everything is ready to be displayed!
      return new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          title: new Text("Team Analytics"),
          actions: <Widget>[
            new Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.blueAccent),
              child: new DropdownButton(
                value: choice,
                elevation: 5,
                underline: new Container(
                  height: 2,
                  color: Colors.white
                ),
                items: options.map(
                  (String option) => DropdownMenuItem(
                    value: option,
                    child: new Text(
                      option,
                      style: new TextStyle(
                        color: Colors.white
                      ),
                    ),
                  )
                ).toList(),
                onChanged: (String value) {
                  setState(() {
                    choice = value;
                    team = new Team(int.parse(choice));
                  });
                },
              ), 
            ),
          ],
        ),
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[ 
              new Column(
                children: <Widget> [
                  new Container(
                    height: MediaQuery.of(context).size.height*.25,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: 'Rounds Played',
                        )
                      ), 
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: 'Stones Placed',
                        )
                      ), 
                      title: new ChartTitle(text: "Stones per Round", alignment: ChartAlignment.center, textStyle: new ChartTextStyle(fontWeight: FontWeight.bold)),
                      series: <ColumnSeries<TeamEntry, int>>[ // Initialize line series.
                        ColumnSeries<TeamEntry, int>(
                          dataSource: team.getData(),
                          xValueMapper: (TeamEntry entry, _) => entry.getRound(),
                          yValueMapper: (TeamEntry entry, _) => entry.getStones(),
                          pointColorMapper: (TeamEntry entry, _) => entry.getColor() ? Colors.blueAccent : Colors.redAccent,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          xAxisName: "Rounds",
                          yAxisName: "Stones Placed",
                        )
                      ],
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Chip(
                          backgroundColor: Colors.white,
                          elevation: 5,
                          label: new Text(
                            "Avg Stones: "+team.getAvgStones().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        ),
                        new Chip(
                          elevation: 5,
                          backgroundColor: Colors.white,
                          label: new Text(
                            "Avg SkyStones: "+team.getAvgSkyStones().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    height: MediaQuery.of(context).size.height*.25,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: 'Rounds Played',
                        )
                      ), 
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: 'Number of Towers',
                        )
                      ), 
                      title: new ChartTitle(text: "Towers per Round", alignment: ChartAlignment.center, textStyle: new ChartTextStyle(fontWeight: FontWeight.bold)),
                      series: <ColumnSeries<TeamEntry, int>>[ // Initialize line series.
                        ColumnSeries<TeamEntry, int>(
                          dataSource: team.getData(),
                          xValueMapper: (TeamEntry entry, _) => entry.getRound(),
                          yValueMapper: (TeamEntry entry, _) => entry.getNumberOfTowers(),
                          pointColorMapper: (TeamEntry entry, _) => entry.getColor() ? Colors.blueAccent : Colors.redAccent,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          xAxisName: "Rounds",
                          yAxisName: "Stones Placed",
                        )
                      ],
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Chip(
                          backgroundColor: Colors.white,
                          elevation: 5,
                          label: new Text(
                            "Avg Height: "+team.getAvgHeight().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        ),
                        new Chip(
                          elevation: 5,
                          backgroundColor: Colors.white,
                          label: new Text(
                            "Avg Towers: "+team.getAvgNumberOfTowers().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        ),
                        new Chip(
                          elevation: 5,
                          backgroundColor: Colors.white,
                          label: new Text(
                            "Max Tower Height: "+team.getMaxStoneHeight().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    height: MediaQuery.of(context).size.height*.25,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(
                          text: 'Match',
                        )
                      ), 
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: 'Marker Height',
                        )
                      ), 
                      title: new ChartTitle(text: "Marker Height per Match", alignment: ChartAlignment.center, textStyle: new ChartTextStyle(fontWeight: FontWeight.bold)),
                      series: <LineSeries<TeamEntry, int>>[ // Initialize line series.
                        LineSeries<TeamEntry, int>(
                          dataSource: team.getData(),
                          xValueMapper: (TeamEntry entry, _) => entry.getRound(),
                          yValueMapper: (TeamEntry entry, _) => entry.getMarkerHeight(),
                          pointColorMapper: (TeamEntry entry, _) => entry.getColor() ? Colors.blueAccent : Colors.redAccent,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          xAxisName: "Rounds",
                          yAxisName: "Stones Placed",
                        )
                      ],
                    ),
                  ),
                  new Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Chip(
                          elevation: 5,
                           backgroundColor: Colors.white,
                          label: new Text(
                            "Avg Height: "+team.getAvgMarkerHeight().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        ),
                        new Chip(
                          elevation: 5,
                          backgroundColor: Colors.white,
                          label: new Text(
                            "Avg Towers: "+team.getAvgNumberOfTowers().toStringAsFixed(2),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*.015,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget> [
                  new Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: new Text(
                      "Descriptions",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height*.02
                      ),
                    ), 
                  ),
                ]+(team.getDescriptions().map(
                  (String d) => new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      new Text(
                        d,
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                          fontSize: MediaQuery.of(context).size.height*.02
                        ),
                      ),
                      new Divider()
                    ]
                  )
                ).toList())
              )
            ]
          )
        ),
      );
    }
  }

}