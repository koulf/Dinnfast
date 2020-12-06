import 'package:hive/hive.dart';


@HiveType(typeId: 1, adapterName: "Dish")
class Dish {

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String image;
  @HiveField(2)
  bool served;

  Dish({this.name, this.image, this.served});
}

class DishAdapt extends TypeAdapter<Dish> {
  @override
  final int typeId = 1;

  @override
  Dish read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dish(
      name: fields[0] as String,
      image: fields[1] as String,
      served: fields[2] as bool
    );
  }

  @override
  void write(BinaryWriter writer, Dish obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.served);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DishAdapt &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
