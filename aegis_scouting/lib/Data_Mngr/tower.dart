class Tower{
  int _height;
  bool _marker;

  Tower(int height) {
    _height = height;
  }

  void setHeight(int h) => _height = h;

  void setMarker(bool m) => _marker = m;

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