import 'package:flutter/material.dart';
import 'package:project1/models/group_data_model.dart';
import 'package:project1/models/user.dart';
import 'package:project1/services/database.dart';
import 'package:project1/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:project1/models/user_data_model.dart';


//
// START StackOverflow Code

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues}) : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    if (_selectedValues != null) {
      Navigator.pop(context, _selectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Employees'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}

//END StackOverflow Code











//
class TaskAddForm extends StatefulWidget {
  //final String groupName;
  //TaskAddForm(GroupDataModel currentGroupData, {Key key, this.groupName, this.groupData}) : super(key: key);
  final GroupDataModel groupData;
  String groupName;
  final String task;
 // final String groupName;

  //TaskAddForm({Key key, @required this.groupName}) : super(key: key);
  @override
  TaskAddForm(this.groupData, this.groupName, this.task);


  _TaskAddFormState createState() => _TaskAddFormState(groupData, groupName, task);
}

class _TaskAddFormState extends State<TaskAddForm> {
  TextEditingController _controller;


 // Map data = {};

  final GroupDataModel groupData;
  final String groupName;
  String task;
  _TaskAddFormState(this.groupData, this.groupName, this.task);
  final _formkey = GlobalKey<FormState>();
  //final List<String> sugars = ['0','1','2','3','4'];

  // form values
  String _currentTitle;
  String _currentDescription;
  List<String> _currentUsers;
  DateTime _currentDeadline;
//
//MULTI SELECT FUNCTION

  List <MultiSelectDialogItem<String>>  multiItem = List();



  void populateMultiSelect(Map<String, String> valuesToPopulate){
    for(String v in valuesToPopulate.keys){
      multiItem.add(MultiSelectDialogItem(v, valuesToPopulate[v]));
    }
  }



  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    Map<String, String> valuesToPopulate =  {};
    Provider.of<List<UserDataModel>>(context).where((user) => widget.groupData.users.contains(user.uid)).forEach((user) { // have to add a method later to only let admins assign to all users
      valuesToPopulate.putIfAbsent(user.uid, () => user.firstName + " " + user.lastName);
    });
    populateMultiSelect(valuesToPopulate);
    final items = multiItem;

    final selectedValues = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: _currentUsers != null? _currentUsers.toSet() : null , // initially select users from state
        );
      },
    );
    if (selectedValues != null && selectedValues.length != 0) {
      setState(() {
        _currentUsers = selectedValues.toList();
      });
    }
    print("selectedValues: $selectedValues");
    //getvaluefromkey(selectedValues);
  }

  /*void getvaluefromkey(Set selection){
    if (selection != null){
      for(String x in selection.toList()){
        print(valuesToPopulate[x]);
      }
    }
  }*/

  //MULTI SELECT FUNCTION





  //
  @override
  Widget build(BuildContext context) {
    print(groupName);
    print(task);
    if (groupName == "none" || task == "none") {
      //print(groupData);
      //  print(groupData.name);
      // print(groupData.uid);
      //print(groupData.uid);
      // print(groupData.uid);
      //print(_formkey);
      // data from alan!
      // data = ModalRoute.of(context).settings.arguments;
      //print(widget.groupData);

      final user = Provider.of<User>(context);
      return SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                Text(
                  "Create Task",
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: "Title"),
                  validator: (val) => val.isEmpty ? "Please enter title" : null,
                  onChanged: (val) => setState(() => _currentTitle = val),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                      hintText: "Description"),
                  validator: (val) =>
                  val.isEmpty
                      ? "Please enter description"
                      : null,
                  onChanged: (val) => setState(() => _currentDescription = val),
                ),
                SizedBox(
                  height: 20.0,
                ),
                // (Ben) replace that TextFormField below with a dropdown list of strings
                // Theres also dropdown menu code that is commented out further below. Its from the tutorials, perhaps you can look at it for reference
                RaisedButton(
                  child: Text("Select Employees"),
                  onPressed: () => _showMultiSelect(context),
                ),
                SizedBox(
                  height: 10.0,
                ),

                // (Ava) (Parul) add a date picker below (ignore all the commented code, its old stuff from the tutorials)
                Text(_currentDeadline == null
                    ? 'No date has been picked yet'
                    : _currentDeadline.toString()),
                RaisedButton(
                  child: Text('Pick a date'),
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: _currentDeadline == null ? DateTime.now() :
                        _currentDeadline,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030)
                    ).then((date) {
                      setState(() {
                        _currentDeadline = date;
                      });
                    });
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                // dropdown menu
                // not in use anymore
                /*DropdownButtonFormField(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? currentUser.sugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text("$sugar sugars"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val),
                  ),*/
                // slider
                // also not in use anymore
                /*Slider(
                  value: (_currentStrength ?? currentUser.strength).toDouble(),
                  activeColor: Colors.brown[_currentStrength ?? currentUser.strength],
                  inactiveColor: Colors.brown[_currentStrength ?? currentUser.strength],
                  min: 100,
                  max: 900,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),*/

                RaisedButton(
                  color: Colors.pink[400],
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      await DatabaseService(userUid: user.uid).createTask(
                        _currentTitle,
                        _currentDescription,
                        groupData.uid,
                        user.uid,
                        _currentUsers,
                        _currentDeadline,
                        false,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // alternate AddTask if GIVEN: GROUP or TASK via --> AlanVoice
      final user = Provider.of<User>(context);
      return SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                Text(
                  "Create Task",
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  initialValue: task,

                  //decoration: textInputDecoration.copyWith(hintText: task),
                  validator: (val) {
                    if(val.isEmpty){
                      return "Please enter title";
                    }else{
                      _currentTitle = val;
                    }
                    return null;

                    },
                  //onChanged: (val) => setState(() => _currentTitle =  val),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  initialValue: task,

                  //decoration: textInputDecoration.copyWith(hintText: task),
                  validator: (val) {
                    if(val.isEmpty){
                      return "Please enter description";
                    }else{
                      _currentDescription = val;
                    }
                    return null;

                  },
                ),
                SizedBox(
                  height: 20.0,

                ),
                // (Ben) replace that TextFormField below with a dropdown list of strings
                // Theres also dropdown menu code that is commented out further below. Its from the tutorials, perhaps you can look at it for reference
                RaisedButton(
                  child: Text("Select Employees"),
                  onPressed: () => _showMultiSelect(context),
                ),
                SizedBox(
                  height: 10.0,
                ),

                // (Ava) (Parul) add a date picker below (ignore all the commented code, its old stuff from the tutorials)
                Text(_currentDeadline == null
                    ? 'No date has been picked yet'
                    : _currentDeadline.toString()),
                RaisedButton(
                  child: Text('Pick a date'),
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: _currentDeadline == null ? DateTime.now() :
                        _currentDeadline,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030)
                    ).then((date) {
                      setState(() {
                        _currentDeadline = date;
                      });
                    });
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                // dropdown menu
                // not in use anymore
                /*DropdownButtonFormField(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? currentUser.sugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text("$sugar sugars"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val),
                  ),*/
                // slider
                // also not in use anymore
                /*Slider(
                  value: (_currentStrength ?? currentUser.strength).toDouble(),
                  activeColor: Colors.brown[_currentStrength ?? currentUser.strength],
                  inactiveColor: Colors.brown[_currentStrength ?? currentUser.strength],
                  min: 100,
                  max: 900,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),*/

                RaisedButton(
                  color: Colors.pink[400],
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      await DatabaseService(userUid: user.uid).createTask(
                        _currentTitle,
                        _currentDescription,
                        groupData.uid,
                        user.uid,
                        _currentUsers,
                        _currentDeadline,
                        false,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  } // Widget (exterior)
  } // end of entire (2nd) class w/state

