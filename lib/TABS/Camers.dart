import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PageCam extends StatefulWidget {
  const PageCam({Key? key}) : super(key: key);

  @override
  State<PageCam> createState() => _PageCamState();
}

class _PageCamState extends State<PageCam> {
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
    openCam();
    super.initState();
  }

  @override
  void dispose() {
    statusList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(userData);
    return Scaffold(
      body: Container(
        child: image == null
            ? const SizedBox()
            : Image.file(
                image!,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
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
                        // uploadToStorage();
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

  void pickFile() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      imagePath = file.path;
      setState(() {});
    }
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

  //SNACKBAR
  showsnackbar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
