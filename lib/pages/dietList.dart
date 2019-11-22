import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DietList extends StatefulWidget {
  final age;
  final weight;
  final height;
  final gender;
  final goalType;

  DietList(
      {@required this.age,
      @required this.weight,
      @required this.height,
      @required this.gender,
      @required this.goalType});

  @override
  _DietListState createState() => _DietListState();
}

class _DietListState extends State<DietList> {
  Future<List<Meal>> _getData() async {
    var queryParameters = {
      'age': widget.age,
      'weight': widget.weight,
      'height': widget.height,
      'gender': widget.gender,
      'goalType': widget.goalType == 'Weight loss' ? 0 : 1
    };

    var uri = Uri.https(
        'api-health-coach.herokuapp.com', '/generate', queryParameters);
    print(uri);

    var response = await http.post(uri, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    if (response.statusCode == 200) {
      print(response.body);
      var jsonData = json.decode(response.body);

      List<Meal> meals = [];
      for (var u in jsonData) {
        Meal m = Meal(u["desc"], u["directions"], u["ingredients"], u["title"]);
        meals.add(m);
      }
      print(meals.length);

      return meals;
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return new Scaffold(
        appBar: new AppBar(title: Text('Diet pla')),
        body: Container(
          child: FutureBuilder(
            future: _getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text('Loading...'),
                  ),
                );
              }else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(snapshot.data[index].title));
                  },
                );
              }
            },
          ),
        ));
  }
}

class Meal {
  String desc;
  String directions;
  String ingredients;
  String title;

  Meal(
    this.desc,
    this.directions,
    this.ingredients,
    this.title,
  );
}
