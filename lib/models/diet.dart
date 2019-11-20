import 'dart:convert';

Diet dietFromJson(String str) => Diet.fromJson(json.decode(str));

String dietToJson(Diet data) => json.encode(data.toJson());

class Diet {
  String directions;
  String desc;
  String title;
  String ingredients;

  Diet({
    this.directions,
    this.desc,
    this.title,
    this.ingredients,
  });

  factory Diet.fromJson(Map<String, dynamic> json) => Diet(
    directions: json["directions"],
    desc: json["desc"],
    title: json["title"],
    ingredients: json["ingredients"],
  );

  Map<String, dynamic> toJson() => {
    "directions": directions,
    "desc": desc,
    "title": title,
    "ingredients": ingredients,
  };
}