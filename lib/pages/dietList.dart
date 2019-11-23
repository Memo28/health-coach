import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../services/flutter_paypal.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //
    FlutterPaypal.register(
      sandbox:
      "AR1XeeAf34xHEDv0lZskpH7vFyP-guZbzqw-wvbgpID9zi6ycNtVeaLAWGEC6W54FJtuhbqamcDKjfpc",
      production:
      "AS_cHzhWtzdQE1GFPjix2c_l8Ga7Jp_8BDhc0g5IsO8qvWobZkT_RXdtEmenZpN0PrXOwR0oJE5oSYh7",
    );
  }



  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPaypal.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  Future<List<Meal>> _getData() async {
    var uri = Uri.parse('https://api-health-coach.herokuapp.com/generate');
    uri = uri.replace(
        query:
            'age=${widget.age}&weight=${widget.weight}&height=${widget.height}&gender=${widget.gender}&goalType=${widget.goalType}');
    print(uri.toString());

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
    Widget showLogo() {
      return new Hero(
        tag: 'hero',
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 48.0,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      );
    }

    Widget showPrimaryButton() {
      return new Padding(
          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: SizedBox(
            height: 40.0,
            child: new RaisedButton(
              onPressed:(){
                FlutterPaypal.payment("100", "Health Coach Subscription").then((data){
                  print(data);
                });
              },
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: new Text('Unlock Premium',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            ),
          ));
    }

    return new Scaffold(
        appBar: new AppBar(title: Text('Diet plan')),
        body: Container(
          child: FutureBuilder(
            future: _getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text('Loading...'),
                  ),
                );
              } else {
                return Column(
                  children: <Widget>[
                    showLogo(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2.0,20.0,2.0,0.0),
                      child: Text('Get your FULL meal plan unlocking premium', textAlign : TextAlign.center, style: new TextStyle(fontSize: 20.0)),
                    ),
                    showPrimaryButton(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              title: Text(snapshot.data[index].title),
                              subtitle : Text(snapshot.data[index].desc)
                          );
                        },
                      ),
                    ),
                  ],
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
