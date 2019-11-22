// To parse this JSON data, do
//
//     final meal = mealFromJson(jsonString);

import 'dart:convert';

Meal mealFromJson(String str) => Meal.fromJson(json.decode(str));

String mealToJson(Meal data) => json.encode(data.toJson());

class Meal {
  String desc;
  String directions;
  String ingredients;
  String title;

  Meal({
    this.desc,
    this.directions,
    this.ingredients,
    this.title,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    desc: json["desc"],
    directions: json["directions"],
    ingredients: json["ingredients"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "desc": desc,
    "directions": directions,
    "ingredients": ingredients,
    "title": title,
  };
}
