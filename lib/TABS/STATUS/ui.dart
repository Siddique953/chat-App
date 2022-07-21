import 'dart:io';

import 'package:badges/badges.dart';
import 'package:chat/TABS/STATUS/Status.dart';
import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List statusList = [];

  final ImagePicker _picker = ImagePicker();
  dynamic url;
  File? image;
  String? imagePath;

  getList() {
    FirebaseFirestore.instance
        .collection('status')
        .doc(uId)
        .snapshots()
        .listen((event) {
      statusList = event.get('status');
    });
  }

  @override
  void initState() {
    getList();
    super.initState();
  }

  @override
  void dispose() {
    statusList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: image == null
                ? const SizedBox()
                : Image.file(
                    image!,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
          ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          image == null
              ? FloatingActionButton(
                  onPressed: () {
                    openCam();
                  },
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.camera_alt_outlined),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          image = null;
                        });
                      },
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.delete_outline_outlined),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        uploadToStorage();
                      },
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.send),
                    ),
                  ],
                )
        ],
      ),
    );
  }

  //OPEN CAMERA TO TAKE PHOTO
  openCam() async {
    XFile? camImage = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      image = File(camImage!.path);
    });
  }

//UPLOADING TO FIRESTORAGE AND FIRESTORE
  uploadToStorage() {
    String fileName = DateTime.now().toString();

    var ref = FirebaseStorage.instance.ref().child('status/$fileName');
    UploadTask uploadTask = ref.putFile(File(image!.path));

    uploadTask.then((res) async {
      url = (await ref.getDownloadURL()).toString();
      statusList.add({
        'type': "image",
        'url': url,
        'sendTime': DateTime.now(),
      });
    }).then((value) =>
        FirebaseFirestore.instance.collection('status').doc(uId).set({
          'SenderName': userData.displayName,
          'senderId': uId,
          'viewed': [],
          'status': statusList
        }));
    setState(() {
      image = null;
    });
  }
}
