import 'package:DinnFast/dish.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



Box box;

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DishAdapt());
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


  void _clearDishes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are sure you want to clear dishes?'),
          actions: [
            FlatButton(
              onPressed: () async {
                await box.clear();
                for(Dish dish in dishes) {
                  dish.served = false;
                  box.add(dish);
                }
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Yes')
            ),
            FlatButton(
              onPressed: () { Navigator.of(context).pop(); },
              child: Text('Cancel')
            )
          ]
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {

    TextEditingController nameCtrl = TextEditingController();
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    double width = MediaQuery.of(context).size.width;
    print('box: ${box.length}');
    dishes = List<Dish>.from(box.values);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions : [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('New dish'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: 'Name'
                          )
                        )
                      ]
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().length > 0) {
                            box.add(Dish(name: nameCtrl.text.trim(), image: "", served: false));
                            setState(() {});
                            Navigator.of(context).pop();
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Please enter the name of the dish')
                            ));
                          }
                        },
                        child: Text('Create')
                      ),
                      FlatButton(
                        onPressed: () { Navigator.of(context).pop(); },
                        child: Text('Cancel')
                      )
                    ]
                  );
                }
              );
            }
          )
        ]
      ),
      body: dishes.length > 0
      ? ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            // color: Colors.grey[350],
            semanticContainer: true,
            margin: EdgeInsets.only(top: index == 0 ? width*0.1 : 0, bottom: width*0.1, left: width*0.05, right: width*0.05),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: width/16),
                  child: Text(dishes[index].name)
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red[900],
                  onPressed: () {
                    print('Deleting');
                  }
                )
              ]
            )
          );
        }
      )
      : Center(
        child: Text('No saved dishes')
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearDishes,
        tooltip: 'Nuevo platillo',
        child: Icon(Icons.replay_outlined)
      )
    );
  }
}
