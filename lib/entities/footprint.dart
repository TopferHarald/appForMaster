import 'package:json_annotation/json_annotation.dart';

part 'footprint.g.dart';


@JsonSerializable()
class Footprint {

  int choiceSaison;
  int choiceMilk;
  int choiceEggs;
  int choiceMeat;
  int choiceFair;
  int choiceTrash;

  int choiceCar;
  int choiceFuel;
  int choiceFuelUse;
  int choiceOffi;
  int choicePlane;
  int choiceCruise;

  int choiceHeiz;
  int choiceBaujahr;
  int choiceLivingarea;
  int choicePersons;
  int choiceTemperature;
  int choiceType;
  int choiceClass;
  int choiceCool;
  int choiceWash;
  int choiceDry;

  int choiceKleider;
  int choiceHobbies;
  int choiceDevices;
  int choiceEat;

  String userid;

  factory Footprint.fromJson(Map<String, dynamic> data) => _$FootprintFromJson(data);

  Map<String,dynamic> toJson() => _$FootprintToJson(this);

  Footprint(
      this.choiceSaison,
      this.choiceMilk,
      this.choiceEggs,
      this.choiceMeat,
      this.choiceFair,
      this.choiceTrash,
      this.choiceCar,
      this.choiceFuel,
      this.choiceFuelUse,
      this.choiceOffi,
      this.choicePlane,
      this.choiceCruise,
      this.choiceHeiz,
      this.choiceBaujahr,
      this.choiceLivingarea,
      this.choicePersons,
      this.choiceTemperature,
      this.choiceType,
      this.choiceClass,
      this.choiceCool,
      this.choiceWash,
      this.choiceDry,
      this.choiceKleider,
      this.choiceHobbies,
      this.choiceDevices,
      this.choiceEat,
      this.userid);
}