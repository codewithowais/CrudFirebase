// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController taskController = TextEditingController();
  addData() async {
    await FirebaseFirestore.instance.collection('tasks').add({
      'task name': taskController.text,
      'date':
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'
    });
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Al-Ahmed CRUD"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              // decoration: BoxDecoration(border: Border.all()),
              child: Card(
                margin: EdgeInsets.all(14),
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.all(10),
                        child: TextField(
                          controller: taskController,
                        )),
                    ElevatedButton(
                        onPressed: () {
                          addData();
                        },
                        child: Text("Add Data")),
                  ],
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('tasks').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("ERROR");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['task name']),
                      subtitle: Text(data['date']),
                      trailing: Wrap(
                        spacing: 1,
                        children: [
                          IconButton(
                              onPressed: () {
                                document.reference.delete();
                              },
                              icon: Icon(Icons.delete)),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: Text('Update Task'),
                                          content: Column(
                                            children: [
                                              TextField(
                                                controller: taskEditcontrooler,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  document.reference.update({
                                                    'task name':
                                                        taskEditcontrooler.text
                                                  });
                                                  Navigator.pop(context);
                                                  taskEditcontrooler.clear();
                                                },
                                                child: Text("UPDATE"),
                                              )
                                            ],
                                          ));
                                    });
                              },
                              icon: Icon(Icons.edit))
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  TextEditingController taskEditcontrooler = TextEditingController();
}
