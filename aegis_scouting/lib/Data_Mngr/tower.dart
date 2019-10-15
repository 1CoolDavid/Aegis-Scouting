import 'package:flutter/material.dart';

class Tower{
  int _height;
  bool _marker;
  bool _color;

  List<Widget> _images = new List();

  Image _stone, _flag; 
  Widget _coveredStone;

  BuildContext _context;

  Tower(BuildContext context, bool color) {
    _height = 1;
    _marker = false;
    _color = color;
    _context = context;
    _stone = new Image(
      image: new AssetImage('assets/images/stone_icon.png'),
      height: MediaQuery.of(_context).size.height*.05,
      width: MediaQuery.of(_context).size.height*.07,
    );
    _coveredStone = new Container(
      padding: EdgeInsets.only(bottom: 25),
      height: _stone.height*.65,
      width: _stone.width,
      child: new Row(),
      color: Color.fromRGBO(255, 200, 13, 1),
    );
    _flag = color ? new Image(
      image: new AssetImage('assets/images/blue_marked_stone_icon.png'),
      height: MediaQuery.of(_context).size.height*.05,
      width: MediaQuery.of(_context).size.height*.07,
    ) : new Image(
      image: new AssetImage('assets/images/red_marked_stone_icon.png'),
      height: MediaQuery.of(_context).size.height*.05,
      width: MediaQuery.of(_context).size.height*.07,
    );
    _images.add(_stone);
  }

  void setHeight(int h) {
    if(h<0 || h>56){
      return;
    }
    if(h == 0) {
      _images = new List();
    } else if(h == 1) {
      _images = new List();
      if(_marker) {
        _images.add(_flag);
      } else {
        _images.add(_stone);
      }
    } else if(h < _height) {
      for(int i = _height; i > h; i--) {
        _images.remove(_images.last);
      }
    } else {
      for(int i = _height; i<h; i++) {
        _images.add(_coveredStone);
      }
    }
    _height = h;
  }

  void setMarker(bool m) {
    _marker = m;
    _images.removeAt(0);
    if(m) {
      _images.insert(0, _flag);
    } else {
      _images.insert(0, _stone);
    }
  }

  void setColor(bool c) {
    _color = c;
    _flag = c ? new Image(
      image: new AssetImage('assets/images/blue_marked_stone_icon.png'),
      height: MediaQuery.of(_context).size.height*.05,
      width: MediaQuery.of(_context).size.height*.07,
    ) : new Image(
      image: new AssetImage('assets/images/red_marked_stone_icon.png'),
      height: MediaQuery.of(_context).size.height*.05,
      width: MediaQuery.of(_context).size.height*.07,
    );
    if(_marker) {
      _images.removeAt(0);
      _images.insert(0, _flag);
    }
  }

  bool getColor() => _color;

  List<Widget> getTower() => _images;

  int getHeight() => _height;

  bool getMarker() => _marker;
}

class Foundation{
  List<Tower> towers = new List();
  double _len = 0.0;

  void add(Tower t) {
    towers.add(t);
    _len++;
  }

  double getAvg() {
    int sum = 0;
    for(Tower t in towers) {
      sum+=t.getHeight();
    }
    return sum/_len;
  }
}