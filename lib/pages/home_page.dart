import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;
  Box? _box;
  _HomePageState();
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly!",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future:
          //Future.delayed(Duration(seconds: 2)),
          Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        //if (_snapshot.connectionState == ConnectionState.done) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _taskList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    //Adding task to Box
    // Task _newTask =
    //     Task(content: "Eat pizza", timestamp: DateTime.now(), done: false);
    // _box?.add(_newTask.toMap());

    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.timestamp.toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outline_blank_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            setState(() {
              task.done = !task.done;
              _box!.putAt(_index, task.toMap());
            });
          },
          onLongPress: () {
            _box!.deleteAt(_index);
            setState(() {});
          },
        );
      },
    );

    ListView(
      children: [
        ListTile(
          title: const Text(
            "Do Laundry!",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(DateTime.now().toString()),
          trailing: const Icon(
            Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
        ),
        ListTile(
          title: const Text(
            "Do Laundry!",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(DateTime.now().toString()),
          trailing: const Icon(
            Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add new Task!"),
          content: TextField(
            onSubmitted: (_value) {
              if (_newTaskContent != null) {
                var _task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(_task.toMap());
                setState(() {
                  _newTaskContent = null;
                  Navigator.pop(context);
                });
              }
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              });
            },
          ),
        );
      },
    );
  }
}
