import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/TABS/Chat/Chat.dart';
import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NameList extends StatefulWidget {
  const NameList({Key? key}) : super(key: key);

  @override
  State<NameList> createState() => _NameListState();
}

class _NameListState extends State<NameList> {
  int? lastMsg;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where("userid", isNotEqualTo: uId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              var data = snapshot.data?.docs;
              return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ChatScreen(
                              index: index,
                              profile: data[index]['userimage'],
                              name: data[index]['username'],
                              rid: data[index]['userid']);
                        }));
                      },
                      child: Card(
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      data[index]['userimage']),
                                  radius: 35,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.69,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data[index]['username'],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const Text('Time')
                                      ],
                                    ),

                                    Row(
                                      children: const [
                                        Text('Last Message'),
                                      ],
                                    )

                                    //Text(las[index]['lastMessage']),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }
}
