import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/models/group_data_model.dart';
import 'package:project1/models/user.dart';
import 'package:project1/screens/authenticate/authenticate.dart';
import 'package:project1/screens/home/task_add_form.dart';
import 'package:project1/screens/wrapper.dart';
import 'package:project1/services/database.dart';
import 'package:provider/provider.dart';
import 'package:project1/screens/home/tasks_data_list.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:project1/screens/home/home.dart';

import 'home.dart';

class GroupDataScreen extends StatefulWidget {
  final GroupDataModel groupData;
  final GlobalKey<TasksDataListState> tasksDataKey;
  final String state;
  final String task;
  //GroupDataScreen({this.groupData});
  GroupDataScreen({Key groupDataScreenKey, @required this.groupData, this.tasksDataKey, this.state, this.task}) : super(key: groupDataScreenKey);


  @override
  GroupDataScreenState createState() => GroupDataScreenState();
}

class GroupDataScreenState extends State<GroupDataScreen> {
  bool _enabled = false;

  GroupDataModel currentGroupData;

  void _taskAppender(String task, String groupName){

   // var groupData = groupsDataKey.currentState.groupsOfCurrentUser.singleWhere((group) => group.name.toLowerCase() == groupName.toLowerCase(), orElse: () => null);
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
        child: TaskAddForm(widget.groupData, groupName, task)

      );
    });

    String taskN = task;
    AlanVoice.playText("creating task"+ taskN);
    AlanVoice.clearCallbacks();
    AlanVoice.playText("group is: "+ groupName);
    AlanVoice.clearCallbacks();
    // currentGroupData.name = groupName;

  }


  @override
  Widget build(BuildContext context) {


/*Future<void>*/ void _handleCommand(Map<String, dynamic> command) /*async*/ {
      print("command: $command");
      switch(command["command"]) {


        case "createTask":


          _taskAppender(command["task"], command["groupName"]);
          AlanVoice.clearCallbacks();





          break;
        case "signOut":
        // signing out handler
          break;
        case "wrap":
          AlanVoice.playText("wrap command works");
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


    print("group name: "+widget.groupData.name);
    print("users: " + widget.groupData.users.toString());
    print(widget.groupData);
    print("id is: "+ widget.groupData.uid);
    print(widget.groupData);


   // print(groupDataScreenKey);
    //print(widget.state);

    // ignore: dead_code
    final user = Provider.of<User>(context);
    setState(() {
      currentGroupData = widget.groupData;//
    });
    _initAlanButton();
    void _showTaskAddPanel() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: TaskAddForm(currentGroupData, "none","none"),

        );
      });
    }
    return StreamProvider<List<TaskDataModel>>.value(
      // userUid is only specified if the user is not included in the admins list of the group, who should be able to see all tasks
        value: DatabaseService(groupUid: currentGroupData.uid/*widget.groupData.uid*/, userUid: (/*widget.groupData*/currentGroupData.admins.contains(user.uid) ? null : user.uid)).tasks,
        child: Scaffold(
          backgroundColor: Colors.brown[50],
          appBar: AppBar(
            title: Text(/*widget.groupData*/currentGroupData.name),
            backgroundColor: Colors.brown[400],
            elevation: 0.0,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add Task"),
                onPressed: () => _showTaskAddPanel(),
              ),
              FlatButton.icon(
                icon: Icon(Icons.share),
                label: Text('Join Code'),
                onPressed: () async {
                  String vCode = await DatabaseService().getGroupInvite(user.uid, /*widget.groupData*/currentGroupData.uid);

                  Alert(
                    context: context,
                    type: AlertType.success,
                    title: "$vCode",
                    desc: "Here is your verification code",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        width: 120,
                      )
                    ],
                  ).show();
                },
              )
            ],
          ),
          body:
          TasksDataList(tasksDataKey: widget.tasksDataKey /*Provider.of<Map<String, Key>>(context)["tasksDataKey"]*/),
        )
    );


  }

  }

