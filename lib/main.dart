import 'package:chat/TABS/Camers.dart';
import 'package:chat/TABS/STATUS/ui.dart';
import 'package:chat/TABS/Test.dart';
import 'package:chat/main.dart';
import 'package:chat/tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

String? uId;
var userData;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return const HomePage();
              } else {
                userData = snapshot.data!;
                uId = userData.uid;
                return const FirstPage();
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'CHATS',
      //     style: TextStyle(fontWeight: FontWeight.w600),
      //   ),
      //   backgroundColor: Colors.teal,
      // ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Hello,',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  Text(
                    'WELCOME',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  signInWithGoogle();
                },
                child: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    uId = userCredential.user?.uid;
    var username = userCredential.user?.displayName;
    var userimage = userCredential.user?.photoURL;
    var useremail = userCredential.user?.email;

    FirebaseFirestore.instance.collection('user').doc(uId).set({
      "userid": uId,
      "username": username,
      "useremail": useremail,
      "userimage": userimage,
    });
  }
}
