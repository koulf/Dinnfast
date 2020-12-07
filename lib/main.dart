import 'package:DinnFast/dish.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
                  await box.add(dish);
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
    dishes = List<Dish>.from(box.values);
    Color pickedColor = Colors.grey[350];


    print('box: ${box.length}');
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
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog(
                        title: Text('New dish'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: TextField(
                                controller: nameCtrl,
                                decoration: InputDecoration(
                                  filled: true,
                                  labelText: 'Name'
                                )
                              )
                            ),
                            FlatButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.all(0),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          showLabel: false,
                                          enableAlpha: false,
                                          pickerColor: pickedColor,
                                          onColorChanged: (newColor) {
                                            pickedColor = newColor;
                                          },
                                          colorPickerWidth: width/2
                                        )
                                      ),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Ok")
                                        )
                                      ]
                                    );
                                  }
                                );
                                setState(() { });
                              },
                              color: pickedColor,
                              child: Text('Color')
                            )
                          ]
                        ),
                        actions: [
                          FlatButton(
                            onPressed: () async {
                              if (nameCtrl.text.trim().length > 0) {
                                await box.add(Dish(name: nameCtrl.text.trim(), image: "", served: false, color: pickedColor.value));
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
            color: dishes[index].served ? Colors.grey[350] : Color(dishes[index].color),
            semanticContainer: true,
            margin: EdgeInsets.only(top: index == 0 ? width*0.1 : 0, bottom: width*0.1, left: width*0.05, right: width*0.05),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width*.9 - 96,
                  child: SingleChildScrollView (
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: width/16),
                      child: Text(
                        dishes[index].name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1
                      )
                    )
                  )
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon( dishes[index].served ? Icons.replay : Icons.check),
                      onPressed: () async {
                        dishes[index].served = !dishes[index].served;
                        await box.putAt(index, dishes[index]);
                        setState(() { });
                      }
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red[900],
                      onPressed: () async {
                        await box.deleteAt(index);
                        setState(() { });
                      }
                    )
                  ]
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
