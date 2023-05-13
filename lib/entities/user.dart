import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {

  String id;
  String name;
  double score;

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String,dynamic> toJson() => _$UserToJson(this);

  User(
      this.id,
      this.name,
      this.score
      );

}