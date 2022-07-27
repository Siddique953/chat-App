import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TextEditingController textData = TextEditingController();

bool emojiShowing = false;

_onEmojiSelected(Emoji emoji) {
  textData
    ..text += emoji.emoji
    ..selection =
        TextSelection.fromPosition(TextPosition(offset: textData.text.length));
}

_onBackspacePressed() {
  textData
    ..text = textData.text.characters.skipLast(1).toString()
    ..selection =
        TextSelection.fromPosition(TextPosition(offset: textData.text.length));
}

String? recId;
DateTime? d;

final List<Map<String, dynamic>> lastMsg = [];

class ChatScreen extends StatefulWidget {
  final int index;
  final String profile;
  final String name;
  final String rid;
  const ChatScreen({
    Key? key,
    required this.index,
    required this.profile,
    required this.name,
    required this.rid,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var loginKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    recId = widget.rid;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .where("userid", isNotEqualTo: uId)
            .snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.teal,
              leadingWidth: 90, //MediaQuery.of(context).size.width,
              leading: Row(children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xff101010),
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.profile),
                )
              ]),
              title: Text(widget.name),
            ),
            body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                color: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("chat")
                            .where("senderId", whereIn: [uId, recId])
                            // .where('receiverId', whereIn: [uId, recId])
                            .orderBy('sendTime', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          var msg = snapshot.data!.docs;

                          return Expanded(
                            child: ListView.builder(
                                reverse: true,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                // physics: const BouncingScrollPhysics(),
                                itemCount: msg.length,
                                itemBuilder: (context, index) {
                                  Timestamp t = msg[index]['sendTime'];
                                  d = t.toDate();
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  if ((msg[index]['receiverId'] == uId ||
                                          msg[index]['senderId'] == uId) &&
                                      (msg[index]['receiverId'] == recId ||
                                          msg[index]['senderId'] == recId)) {
                                    if (uId == msg[index]['receiverId']) {
                                      FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(msg[index]['msgId'])
                                          .update({'isRead': true});
                                    }
                                    return Align(
                                      alignment: (msg[index]["senderId"] == uId
                                          ? Alignment.topRight
                                          : Alignment.topLeft),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                45,
                                            minWidth: 115),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          color: (msg[index]["senderId"] == uId
                                              ? Colors.green[200]
                                              : Colors.grey.shade200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 30,
                                                  top: 5,
                                                  bottom: 20,
                                                ),
                                                child: Text(
                                                  msg[index]["message"],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 4,
                                                right: 10,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      DateFormat('h:mm a')
                                                          .format(d!)
                                                          .toLowerCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    msg[index]["senderId"] ==
                                                            uId
                                                        ? Icon(
                                                            Icons.done_all,
                                                            color: msg[index]
                                                                    ["isRead"]
                                                                ? Colors.blue
                                                                : Colors.grey,
                                                            size: 20,
                                                          )
                                                        : const SizedBox()
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return const SizedBox();
                                }),
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.793,
                          child: TextFormField(
                            onTap: () {
                              setState(() {
                                emojiShowing = false;
                              });
                            },
                            autofocus: false,
                            controller: textData,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0, color: Colors.white)),
                              prefixIcon: InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  await Future.delayed(
                                      const Duration(milliseconds: 99));

                                  setState(() {
                                    emojiShowing = !emojiShowing;
                                  });
                                },
                                child: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Message',
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                          // color: Colors.teal,
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FloatingActionButton(
                            backgroundColor: Colors.teal,
                            onPressed: () {
                              if (textData.text.isNotEmpty) {
                                sendMessage();
                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(uId)
                                    .collection('Last')
                                    .doc(recId)
                                    .set({'lastMessage': textData.text});
                                textData.clear();
                              }
                            },
                            child: const Icon(Icons.send),
                          ),
                        )
                      ],
                    ),
                    Offstage(
                      offstage: !emojiShowing,
                      child: SizedBox(
                        height: 250,
                        child: EmojiPicker(
                            onEmojiSelected: (Category category, Emoji emoji) {
                              _onEmojiSelected(emoji);
                            },
                            onBackspacePressed: _onBackspacePressed,
                            config: const Config(
                                columns: 7,
                                // Issue: https://github.com/flutter/flutter/issues/28894
                                emojiSizeMax: 32 * 1.0,
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                gridPadding: EdgeInsets.zero,
                                initCategory: Category.RECENT,
                                bgColor: Color(0xFFF2F2F2),
                                indicatorColor: Colors.teal,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.black,
                                progressIndicatorColor: Colors.grey,
                                backspaceColor: Colors.grey,
                                skinToneDialogBgColor: Colors.white,
                                skinToneIndicatorColor: Colors.grey,
                                enableSkinTones: true,
                                showRecentsTab: true,
                                recentsLimit: 28,
                                replaceEmojiOnLimitExceed: false,
                                noRecents: Text(
                                  'No Recent',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  textAlign: TextAlign.center,
                                ),
                                tabIndicatorAnimDuration: kTabScrollDuration,
                                categoryIcons: CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  sendMessage() {
    FirebaseFirestore.instance.collection('chat').add({
      'message': textData.text,
      'senderId': uId,
      'receiverId': widget.rid,
      'isRead': false,
      'sendTime': DateTime.now(),
    }).then((value) {
      value.update({'msgId': value.id});
    });
  }
}
