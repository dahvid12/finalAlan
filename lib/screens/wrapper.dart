import "package:flutter/material.dart";
import 'package:project1/models/group_data_model.dart';
import 'package:project1/models/user.dart';
import 'package:project1/screens/authenticate/authenticate.dart';
import 'package:project1/screens/home/group_data_screen.dart';
import 'package:project1/screens/home/group_data_tile.dart';
import 'package:project1/screens/home/groups_list.dart';
import 'package:project1/screens/home/home.dart';
import 'package:project1/screens/home/task_add_form.dart';
import 'package:project1/screens/home/task_data_tile.dart';
import 'package:project1/screens/home/tasks_data_list.dart';
import 'package:provider/provider.dart';
import 'package:alan_voice/alan_voice.dart';

// for new data just add keys here
final Map<String, Key> keys = {
  "groupsDataKey" : groupsDataKey,
  "groupDataScreenKey" : groupDataScreenKey,
  "tasksDataKey": tasksDataKey
};
// work on voice date picker and getting other scripts to work.
final groupsDataKey = GlobalKey<GroupsListState>();
final groupDataScreenKey = GlobalKey<GroupDataScreenState>();
final tasksDataKey = GlobalKey<TasksDataListState>();

//var currentGroupData = groupsDataKey.currentState;

class Wrapper extends StatefulWidget {


 // final GroupDataModel groupData;
  final GlobalKey<TasksDataListState> tasksDataKey;
  final String state;

  Wrapper({Key key,  this.tasksDataKey, this.state}) : super(key: key);


  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  List<GroupDataModel> groupsOfCurrentUser;

  GroupDataModel currentGroupData;
  String groupName;
  bool _enabled = false;
  String state;

  String _handleReadGroups() {
    String result = "";
    groupsDataKey.currentState.groupsOfCurrentUser.forEach((group) => {
      result += group.name + ", ",
    });
    return result;
    }

  String _handleReadTasks(String groupName) {
    if (groupName != null) {
      _handleEnterGroup(groupName);
    }
    if (tasksDataKey.currentState == null) {
      return null;
    }
    else {
      String result = "";
      tasksDataKey.currentState.currentTasksData.forEach((task) => {
        result += task.title + ", ",
      });
      return result;
    }
  }

  void _handleEnterGroup(String groupName) {
    var groupData = groupsDataKey.currentState.groupsOfCurrentUser.singleWhere((group) => group.name.toLowerCase() == groupName.toLowerCase(), orElse: () => null);
    if (groupData != null) {
      // for now it generates widges one on top of the other regardless of cotext
      // this causes the widgets to pile up and its not good, but I didnt have time to fix it
      // will fix later

      // some context testing
      // print("context.widget.toStringShort:");
      // print("context.widget.toStringShort: ${context.widget.toStringShort()}");
      if (groupDataScreenKey.currentState == null){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return GroupDataScreen(groupDataScreenKey: groupDataScreenKey, groupData: groupData, tasksDataKey: tasksDataKey,);
          }),
        );
      } else {
        if (groupDataScreenKey.currentState.currentGroupData != groupData) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                return GroupDataScreen(groupDataScreenKey: groupDataScreenKey, groupData: groupData, tasksDataKey: tasksDataKey);
              })
          );
        }
      }
    } else return null;
  }
  void _exitOut(){
    // exits out
    print("signOut handler = works");
  }

  @override
  Widget build(BuildContext context) {

   // final groupsData = Provider.of<List<GroupDataModel>>(context) ?? [];
    //print(groupsData);
    //print(groupsDataKey);
   // print(groupDataScreenKey);
   // print(currentGroupData);
  // print(widget.groupData);

    final user = Provider.of<User>(context);
    /*Future<void>*/ void _handleCommand(Map<String, dynamic> command) /*async*/ {
      print("command: $command");
      switch(command["command"]) {
        case "readGroups":
          String _groups = _handleReadGroups();
          AlanVoice.playText("$_groups");
          break;
        case "enterGroup":
          _handleEnterGroup(command["groupName"]);
          break;
        case "readTasks":
          String _tasks = _handleReadTasks(command["groupName"]?? null);
          if (_tasks == null) AlanVoice.playText("could not read tasks");
          else AlanVoice.playText("$_tasks");
          break;

        case "signOut":
          AlanVoice.playText('Alan works on wrapper too');
        // signing out handler (works) DO THIS INSTEAD OF VISUAL STATES
        //print("Alan works on group page");

        _exitOut();


          break;
      }
    }

    void _initAlanButton() async {
      // init Alan with sample project id
      AlanVoice.addButton("db7b891a6e5f7daa61c56ee3d619bfeb2e956eca572e1d8b807a3e2338fdd0dc/stage");
      //AlanVoice.setVisualState({"screen": "groupScreen"}.toString());
      setState(() {
        _enabled = true;
      });

      AlanVoice.callbacks.add((command) => _handleCommand(command.data));
    }

    // return authenticate or home depending on user status
    // also remove or initialize alan button


    if (user == null) {
      setState(() {
        _enabled = false;
        //AlanVoice.clearCallbacks();
      });
      return Authenticate();
    } else {
      //if (!_enabled) setState(() {_initAlanButton();});
      return Provider<Map<String, Key>>.value(value: keys, child: Home(),);
      //return Home(groupsDataKey: groupsDataKey,);
    }
  }
}

/*class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return authenticate or home depending on user status
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}*/
