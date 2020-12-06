import 'package:hive/hive.dart';


@HiveType(typeId: 1, adapterName: "Dish")
class Dish {

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String image;
  @HiveField(3)
  bool served;

  Dish({this.name, this.image, this.served});
}
