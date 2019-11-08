import 'package:flutter/material.dart';
import './form.dart' as formPage;
import './main.dart';
import './data.dart' as dataPage;

class MyManager extends StatefulWidget {
  @override 
  MyManagerState createState() => new MyManagerState();
}

class MyManagerState extends State<MyManager> with SingleTickerProviderStateMixin {

  TabController controller; 

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2, initialIndex: 1);  
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new Material(
        color: MyApp.coolBlue,
          child: new TabBar(
          controller: controller,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            new Tab(icon: new Icon(Icons.add)),
            new Tab(icon: new Icon(Icons.storage)),
          ],
        ),
      ),

      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new formPage.MyForm(),
          new dataPage.MyData()
        ],
      )
    );
  }
}