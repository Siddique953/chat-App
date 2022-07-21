import 'package:badges/badges.dart';
import 'package:chat/TABS/STATUS/Status.dart';
import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewStatus(
                      id: uId.toString(),
                    ),
                  ));
            },
            child: Row(
              children: [
                Badge(
                  toAnimate: false,
                  position: const BadgePosition(bottom: 1, start: 30),
                  badgeColor: const Color(0xff168670),
                  badgeContent: const Icon(
                    Icons.add,
                    size: 13,
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userData.photoURL),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "My status",
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Tap a add status update",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Recent updates",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('status')
                  .where("senderId", isNotEqualTo: uId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var data = snapshot.data?.docs;
                return Expanded(
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        var statlen = data[index]['status'].length;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewStatus(
                                    id: data[index]['senderId'],
                                  ),
                                ));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                // backgroundImage: NetworkImage(
                                //     data[index]['status'][statlen - 1]['url']),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data[index]['SenderName'],
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 17),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Tap a add status update",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                );
              })
        ],
      ),
    );
  }
}
