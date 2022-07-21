import 'package:chat/TABS/Calls.dart';
import 'package:chat/TABS/Camers.dart';
import 'package:chat/TABS/Chat/Front.dart';
import 'package:chat/TABS/STATUS/ui.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            actions: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search_rounded),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.more_vert_outlined),
              )
            ],
            toolbarHeight: 68,
            backgroundColor: Colors.teal,
            title: const Text(
              "whatsapp",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            bottom: TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.green,
                isScrollable: true,
                tabs: [
                  SizedBox(
                      width: w / 15,
                      child: const Tab(icon: Icon(Icons.camera_alt))),
                  SizedBox(width: w / 5, child: const Tab(text: "CHATS")),
                  SizedBox(width: w / 5, child: const Tab(text: "STATUS")),
                  SizedBox(width: w / 5, child: const Tab(text: "CALLS")),
                ]),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(children: [
              PageCam(),
              NameList(),
              StatusPage(),
              Calls(),
            ]),
          ),
        ),
      ),
    );
  }
}
