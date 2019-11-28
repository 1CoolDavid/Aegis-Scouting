import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:aegis_scouting/Data_Mngr/teamEntry.dart';
import 'package:aegis_scouting/Util/sort.dart';
import 'package:aegis_scouting/main.dart';
import 'package:archive/archive.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  Delete,
}

class MyDataPage extends State<MyData> {
  bool empty = false;
  Sort _sorter = new Sort();
  GlobalKey globalKey = new GlobalKey();
  LinkedHashMap<String, TeamEntry> entryMap = new LinkedHashMap();
  bool _inverted = false;
  bool _sharing = false;
  String shareData = "";
  List<String> _shareData = new List();
  List<QrImage> _shareCodes = new List();
  int qrIndex = 0;
  MemoryDataState _memState = MemoryDataState.Round;

  Future<void> loadAllData() async {
    List<String> compressedStrings = new List();
    List<QrImage> codes = new List();
    LinkedHashMap<String, TeamEntry> map = new LinkedHashMap();
    SharedPreferences sp = await SharedPreferences.getInstance();
    List nums = sp.getKeys().toList();
    for(String team in nums) {
      List<String> jsonList = sp.getStringList(team);
      for(String jsonEntry in jsonList) {
        Map<String, dynamic> jsonObject = jsonDecode(jsonEntry);
        TeamEntry entry = TeamEntry.fromJson(jsonObject);
        compressedStrings.add(entry.toCompressed());
        map.putIfAbsent(entry.getNumber().toString()+"-"+entry.getRound().toString(), ()=> entry);
      }     
    }
    String concat = "";
    for(int i = 0; i<compressedStrings.length; i++) {
      if(i!=0 && i%39==0) {
        codes.add(
          new QrImage(
            data: concat,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            size: MediaQuery.of(context).size.height*.45,
            version: 40,
            gapless: true, //default is true
            errorStateBuilder: (cxt, err) {
              return Container(
                child: Center(
                  child: Text(
                    "Uh oh! Something went wrong...",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          )
        );
        concat="";
      }
      concat+=compressedStrings[i];
    }

    if(concat != "") {
      codes.add(
        new QrImage(
          data: concat,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          size: MediaQuery.of(context).size.height*.45,
          version: 40,
          gapless: true, //default is true
          errorStateBuilder: (cxt, err) {
            return Container(
              child: Center(
                child: Text(
                  "Uh oh! Something went wrong...",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        )
      );
    }
    if(map.isNotEmpty) {
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
    }
    setState(() {
      _shareData = compressedStrings;
      _shareCodes = codes;
      entryMap = map;
    });
  }

  processQRCode(String barcode) async {
    List<String> results = new List();
    while(barcode.length != 0) {
        results.add(barcode.substring(0, barcode.indexOf('|')+1));
        barcode = barcode.substring(barcode.indexOf('|')+1);
      }

      for(String entry in results) {
        TeamEntry teamEntry = TeamEntry.fromCompressed(entry, context);
        if((teamEntry.getNumber() == 0 || teamEntry.getNumber() == null) || teamEntry.getRound() == null) {} else {
          teamEntry.submit();
        }
      }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);

      processQRCode(barcode);
      
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(barcode),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("No Data Collected"),
      ));
    }
  }

  void wait(BuildContext c) async {
    Future.delayed(new Duration(seconds: 4)).whenComplete(() {
      if(entryMap == null || entryMap.isEmpty) {
        setState(() {
          empty = true;
        });
      }
    });
  }

  Future deleteAll() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    loadAllData();
  }
  
  @override
  Widget build(BuildContext context) {  
    if(display == Display.Form) {
      currentEntry = null;
    }  
    if(empty) {
      return new Scaffold(
        backgroundColor: Colors.white,
        body: new Container(
          child: new Column(
            children: <Widget> [
              Center(
                child: new Text(
                  "No Data Found",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*.03
                  ),
                ),
              ),
              new Container(
                padding: EdgeInsets.all(5),
                child: new RaisedButton(
                  child: new Text("Scan For Data", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height*.02),),
                  onPressed: scan,
                ),
              )
            ],
          ),
        ),
      );
    }

    if(entryMap.isEmpty || entryMap == null) {
      wait(context);
      loadAllData();
      return new Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: new Scaffold(
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
                color: Colors.white,
                alignment: Alignment.center,
                child: new CupertinoActivityIndicator(
                  animating: true,
                  radius: MediaQuery.of(context).size.width*.15,
                ),
              )
            ],
          ),
        )
      );
    } else if(_sharing) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width*.95,
        height: MediaQuery.of(context).size.height*.5,
        alignment: Alignment.center,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                alignment: Alignment.center,
                child: new Text(
                  "Code "+(qrIndex+1).toString()+"/"+_shareCodes.length.toString(),
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*.02
                  ),
                ),
              ),
              RepaintBoundary(
                key: globalKey,
                child: _shareCodes[qrIndex]
              ),
              new Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.height*.05),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.arrow_back_ios),
                      splashColor: Colors.blueAccent[100],
                      onPressed: qrIndex == 0 ? null : () {
                        setState(() {
                          qrIndex--;
                        });
                      },
                      disabledColor: Colors.grey,
                      color: Colors.blue,
                    ),
                    new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _sharing = false;
                        });
                      },
                      splashColor: Colors.red[100],
                      color: Colors.red,
                    ),
                    new IconButton(
                      icon: new Icon(Icons.arrow_forward_ios),
                      onPressed: qrIndex == _shareCodes.length-1 ? null : () {
                        setState(() {
                          qrIndex++;
                        });
                      },
                      splashColor: Colors.blueAccent[100],
                      disabledColor: Colors.grey,
                      color: Colors.blue,
                    ),
                  ],
                ),
              )
            ],
          )  
        ),              
      );
    } else {
      return new Scaffold(
        resizeToAvoidBottomPadding: false ,
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
              child: new IconButton(
                color: Colors.white,
                icon: new Icon(Icons.share),
                onPressed: () {
                  setState(() {
                    _sharing = !_sharing;
                  });
                }
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              child: new IconButton(
                color: Colors.white,
                icon: new Icon(Icons.file_download),
                onPressed: scan
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              child: new PopupMenuButton(
                icon: Icon(Icons.more_horiz),
                onSelected: (MemoryDataState mem) {
                  if(mem == MemoryDataState.Delete) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text("Confirm Deletion"),
                          content: new Text("*WARNING* All data will be totally delete if confirmed"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Cancel", style: new TextStyle(color: Colors.blue),),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            new FlatButton(
                              child: new Text("Delete", style: new TextStyle(color: Colors.red),),
                              onPressed: () {
                                deleteAll().whenComplete(() {
                                  setState(() {
                                    //reload
                                  });
                                });                            
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                    );
                    return;
                  }
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
                    ),
                    const PopupMenuDivider(height: 20,),
                    const PopupMenuItem<MemoryDataState>(
                      value: MemoryDataState.Delete,
                      child: Text('DELETE', style: TextStyle(color: Colors.red)),
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
            )).toList().reversed.toList(),
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
                            new Row( //new Addition
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new ChoiceChip(
                                  elevation: teamEntry.hasPlatformIn() ? 5 : 2,
                                  label: new Text(
                                    "Foundation In",
                                    style: teamEntry.hasPlatformIn() ? new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height*.015,
                                    ) : new TextStyle(
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.height*.015,
                                    )
                                  ),
                                  selectedColor: teamEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                                  onSelected: (bool value) { 
                                    setState(() {
                                      teamEntry.setPlatformIn(value);
                                    }); 
                                  },
                                  selected: teamEntry.hasPlatformIn(),
                                  backgroundColor: Colors.white,
                                ),
                                new ChoiceChip(
                                  label: new Text(
                                    "Foundation Out",
                                    style: teamEntry.hasPlatformOut() ? new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height*.015
                                    ) : new TextStyle(
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.height*.015,
                                    )
                                  ),
                                  selectedColor: teamEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                                  onSelected: (bool value) { 
                                    setState(() {
                                      teamEntry.setPlatformOut(value);
                                    }); 
                                  },
                                  elevation: teamEntry.hasPlatformOut() ? 5 : 2,
                                  selected: teamEntry.hasPlatformOut(),
                                  backgroundColor: Colors.white,
                                ),
                                new ChoiceChip(
                                  elevation: teamEntry.hasParked() ? 5 : 2,
                                  label: new Text(
                                    "Parked",
                                    style: teamEntry.hasParked() ? new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.height*.015,
                                    ) : new TextStyle(
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context).size.height*.015,
                                    )
                                  ),
                                  selectedColor: teamEntry.getColor() ? Colors.blueAccent : Colors.redAccent,
                                  onSelected: (bool value) { 
                                    setState(() {
                                      teamEntry.setParking(value);
                                    }); 
                                  },
                                  selected: teamEntry.hasParked(),
                                  backgroundColor: Colors.white,
                                )
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