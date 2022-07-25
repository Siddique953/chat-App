import 'dart:io';
import 'package:intl/intl.dart';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/TABS/STATUS/Status.dart';
import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:status_view/status_view.dart';
import 'package:video_player/video_player.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  DateTime? d;

  List statusList = [];
  VideoPlayerController? _controller;
  final ImagePicker _picker = ImagePicker();
  dynamic url;
  File? image;
  String? imagePath;
  bool isVideo = false;
  String? type;

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
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('status')
                        .where('senderId', isEqualTo: uId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      var data = snapshot.data?.docs;
                      var statlen;
                      if (statusList.isNotEmpty) {
                        statlen = data![0]['status'].length;
                        Timestamp t =
                            data[0]['status'][statlen! - 1]['sendTime'];
                        d = t.toDate();
                      }
                      return InkWell(
                          onTap: () {
                            statusList.isNotEmpty
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewStatus(
                                        id: uId.toString(),
                                      ),
                                    ))
                                : pickFile(ImageSource.camera);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                statusList.isNotEmpty
                                    ? StatusView(
                                        radius: 30,
                                        spacing: 15,
                                        strokeWidth: 2,
                                        indexOfSeenStatus: 0,
                                        numberOfStatus: statlen,
                                        padding: 4,
                                        centerImageUrl: data![0]['status']
                                            [statlen - 1]['url'],
                                        seenColor: Colors.grey,
                                        unSeenColor: Colors.teal,
                                      )
                                    : Badge(
                                        toAnimate: false,
                                        position: const BadgePosition(
                                            bottom: 1, start: 30),
                                        badgeColor: const Color(0xff168670),
                                        badgeContent: const Icon(
                                          Icons.add,
                                          size: 13,
                                        ),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  userData.photoURL),
                                        ),
                                      ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "My status",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      statusList.isNotEmpty
                                          ? DateFormat('h:mm a')
                                              .format(d!)
                                              .toLowerCase()
                                          : 'Tap to add Status status',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ));
                    }),
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
                      var data = snapshot.data!.docs;
                      return Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              var count = data[index]['status'].length;

                              Timestamp t =
                                  data[index]['status'][count - 1]['sendTime'];
                              d = t.toDate();
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
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, top: 10, left: 8),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        StatusView(
                                          radius: 30,
                                          spacing: 15,
                                          strokeWidth: 2,
                                          indexOfSeenStatus: 0,
                                          numberOfStatus: count,
                                          padding: 4,
                                          centerImageUrl: data[index]['status']
                                              [count - 1]['url'],
                                          seenColor: Colors.grey,
                                          unSeenColor: Colors.teal,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data[index]['SenderName'],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              DateFormat('h:mm a')
                                                  .format(d!)
                                                  .toLowerCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    })
              ],
            ),
          ),
          Positioned(
            child: image == null
                ? const SizedBox()
                : isVideo
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: VideoPlayer(_controller!))
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Image.file(
                          image!,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          image == null
              ? Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        isVideo = true;
                        type = 'video';
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Alert'),
                                  content: const Text('Choose a option'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);

                                          setState(() {
                                            pickFile(ImageSource.camera);
                                          });
                                        },
                                        child: const Text('Camera')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            pickFile(ImageSource.gallery);
                                          });
                                        },
                                        child: const Text('Gallery'))
                                  ],
                                ));
                      },
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.video_collection_outlined),
                    ),
                    const SizedBox(height: 5),
                    FloatingActionButton(
                      onPressed: () {
                        isVideo = false;
                        type = 'image';
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Alert'),
                                  content: const Text('Choose a option'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);

                                          setState(() {
                                            pickFile(ImageSource.camera);
                                          });
                                        },
                                        child: const Text('Camera')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            pickFile(ImageSource.gallery);
                                          });
                                        },
                                        child: const Text('Gallery'))
                                  ],
                                ));
                      },
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.camera_alt_outlined),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          image = null;
                          _controller = null;
                        });
                      },
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.delete_outline_outlined),
                    ),
                    const SizedBox(width: 10),
                    isVideo
                        ? FloatingActionButton(
                            onPressed: () {
                              if (_controller!.value.isPlaying) {
                                setState(() {
                                  _controller?.pause();
                                });
                              } else {
                                setState(() {
                                  _controller?.play();
                                });
                              }
                            },
                            backgroundColor: Colors.teal,
                            child: Icon(_controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                          )
                        : const SizedBox(),
                    const SizedBox(width: 10),
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

  //OPEN iMAGE fILE
  pickFile(ImageSource filePath) async {
    if (isVideo) {
      XFile? file = await _picker.pickVideo(
        source: filePath,
      );
      if (file != null) {
        image = File(file.path);
        setState(() {
          _controller = VideoPlayerController.file(File(file.path));
          _controller?.initialize();
        });
      }
    } else {
      XFile? file = await _picker.pickImage(source: filePath);
      if (file != null) {
        image = File(file.path);
        setState(() {});
      }
    }
  }

//UPLOADING TO FIRESTORAGE AND FIRESTORE
  uploadToStorage() {
    String fileName = DateTime.now().toString();

    var ref = FirebaseStorage.instance.ref().child('status/$fileName');
    UploadTask uploadTask = ref.putFile(File(image!.path));

    uploadTask.then((res) async {
      url = (await ref.getDownloadURL()).toString();
      statusList.add({
        'type': type,
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
