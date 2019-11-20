import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/diet.dart';
import 'package:http/http.dart' as http;
import 'dart:io';


class DietList extends StatefulWidget {

  final age;
  final weight;
  final height;
  final gender;
  final goalType;



  DietList({@required this.age, @required this.weight, @required this.height, @required this.gender, @required this.goalType});
  @override
  _DietListState createState() => _DietListState();
}


class _DietListState extends State<DietList> {

  Future<Diet> foods;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.age);
    foods = getData();
  }


  @override
  Widget build(BuildContext context) {

    // Use the Todo to create the UI.
    return FutureBuilder<Diet>(
      future: foods,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Text("${snapshot.data}");
        }else if(snapshot.hasError){
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();

      },
    );
  }


  Future<Diet> getData() async {
    var queryParameters = {
      'food_type': 'meal',
      'current_calories': '100',
      'max_calories': '2000'
    };

    var uri = Uri.https(
        'api-health-coach.herokuapp.com', '/generate', queryParameters);

    print(uri);

    var response = await http.post(
        uri, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    }
    );
    if(response.statusCode == 200){
      print(response.body);
      return Diet.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to load');
    }
  }

}