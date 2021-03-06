import 'package:flutter/material.dart';
import 'package:simple_todo_app/hive_helper.dart';
import 'package:simple_todo_app/models/task.dart';
import 'package:simple_todo_app/pages/task_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final List<Task> _items = []; //캐시에 저장. (앱 재부팅 시 내용 사라짐)

  Future<void> _showDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('할 일 추가'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '할 일을 입력하세요',
              ),
              onSubmitted: (String text) {
                setState(() {
                  HiveHelper().create(Task(title: text));
                  //_items.add(Task(title: text));
                });
                Navigator.of(context).pop(); //Navigator.pop() 비교
                //Navigator.pop()이 내부적으로 Navigator.of(context).pop()를 호출한다.
                //둘의 큰 차이점은 없으며, showDialog()를 사용하여 생성된 route는 root
                //navigator에 push 된다. 그래서 Navigator.of(context).pop()를 쓰는게 좋다.
              },
              textInputAction: TextInputAction.send,
            ),
          );
        });
  }

  Widget _taskList(List<Task> tasks) {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return TaskTile(task: tasks[index], onDeleted: () {});
      },
      children: <Widget>[
        for (int index = 0; index < tasks.length; index += 1)
          Padding(
            key: Key('${index}'),
            padding: const EdgeInsets.all(8.0),
            child: TaskTile(
              task: tasks[index],
              onDeleted: () {
                setState(() {
                  //tasks.removeAt(index);
                });
              },
            ),
          ),
      ],

      //위치를 변경해줄때마다 index도 제 위치로 변경
      onReorder: (int oldIndex, int newIndex) async{
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        await HiveHelper().reorder(oldIndex, newIndex);

        setState(() {
          //final Task item = tasks.removeAt(oldIndex);
          //hive에는 insert가 없다.
          //tasks.insert(newIndex, item);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: HiveHelper().read(),
      builder: (context, snapshot) {
        List<Task> tasks = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'To do List',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _showDialog();
            },
          ),
          body: _taskList(tasks),
        );
      }
    );
  }
}
