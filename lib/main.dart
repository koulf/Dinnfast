import 'package:DinnFast/dish.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



Box box;

void main() async {
  await Hive.initFlutter();
  // Hive.registerAdapter(adapter);
  box = await Hive.openBox('testBox');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinnfast',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Dinnfast'),
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Dish> dishes = List();


  void _newDish() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New dish'),
          actions: [
            FlatButton(
              onPressed: () {
                box.add(Dish(name: "Eggs", image: "", served: false));
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('OK')
            )
          ]
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    print('building');
    print('box: ${box.length}');
    dishes = List<Dish>.from(box.values);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions : [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              box.clear();

              print("Box cleaned");
              setState(() {});
            }
          )
        ]
      ),
      body: dishes.length > 0
      ? ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          return Text(dishes[index].name);
        }
      )
      : Center(
        child: Text('No saved dishes')
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newDish,
        tooltip: 'Nuevo platillo',
        child: Icon(Icons.add)
      )
    );
  }
}
