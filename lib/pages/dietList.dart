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


  Future<List<Diet>> getData() async {
    var queryParameters = {
      'age': widget.age,
      'weight': widget.weight,
      'height': widget.height,
      'gender': widget.gender,
      'goalType' : widget.goalType  == 'Weight loss' ? 0 : 1
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
      var jsonData = json.decode(response.body);

      List<Diet> meals = [];
      for(var u in jsonData){
        Diet d = Diet
      }

    }else{
      throw Exception('Failed to load');
    }
  }


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

}