import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _formKey = new GlobalKey<FormState>();


  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  String _height;
  String _weight;

  String _errorMessage;
  bool _isLoading;

  String _selectedGender;
  String _selectedGoal;
  List<String> _goals = ['Weight loss', 'Build muscle'];
  List<String> _gender = ['Male', 'Female'];

  //bool _isEmailVerified = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  updateTodo(Todo todo) {
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            String userId = _todoList[index].userId;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteTodo(todoId, index);
              },
              child: ListTile(
                title: Text(
                  subject,
                  style: TextStyle(fontSize: 20.0),
                ),
                trailing: IconButton(
                    icon: (completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
                    onPressed: () {
                      updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  Widget getInformation() {
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF55D735), Color(0xFF00AFF5)],
                begin: FractionalOffset(0.6, 0.6),
                end: FractionalOffset(0.5, 0.3),
                stops: [0.0, 0.6],
                tileMode: TileMode.clamp)),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Pleas provide the next information",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              showAge(),
              showHeight(),
              showWeight(),
              showGender(),
              Divider(
                color: Colors.white,
                thickness: 3.0,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "What is your goal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              showGoal(),
              showPrimaryButton()
            ],
          ),
        ));
  }

  Widget showHeight() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: new TextFormField(
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Height',
            icon: new Icon(
              Icons.accessibility,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? 'Please provide a valid value can\'t be empty'
            : null,
        onSaved: (value) => _height = value.trim(),
      ),
    );
  }

  Widget showAge() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: new TextFormField(
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Age',
            icon: new Icon(
              Icons.calendar_today,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? 'Please provide a valid value can\'t be empty'
            : null,
        onSaved: (value) => _height = value.trim(),
      ),
    );
  }

  Widget showWeight() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: new TextFormField(
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Weight',
            icon: new Icon(
              Icons.multiline_chart,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? 'Please provide a valid value can\'t be empty'
            : null,
        onSaved: (value) => _weight = value,
      ),
    );
  }

  Widget showGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(55.0, 0, 0, 0),
            child: DropdownButton(
              hint: Text("Select gender"),
              value: _selectedGender,
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              items: _gender.map((g) {
                return DropdownMenuItem(
                  child: new Text(g),
                  value: g,
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget showGoal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(55.0, 0.0, 0.0, 0.0),
            child: DropdownButton(
              hint: Text("Select yout goal"),
              value: _selectedGoal,
              onChanged: (newValue) {
                setState(() {
                  _selectedGoal = newValue;
                });
              },
              items: _goals.map((go) {
                return DropdownMenuItem(
                  child: new Text(go),
                  value: go,
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget showPrimaryButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(15.0),
            child: SizedBox(
              height: 40.0,
              child: new RaisedButton(
                  onPressed: generateDiet,
                  elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.green,
                  child: new Text('Generate',
                      style:
                          new TextStyle(fontSize: 20.0, color: Colors.white))),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Healt Coach'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: getInformation());
  }

  // Getting data from the API
  void generateDiet() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    if(validateAndSave()){
      print(_weight);
      print(_selectedGender);
      print(_selectedGoal);
    }else{
      print("Error");
    }
  }
}
