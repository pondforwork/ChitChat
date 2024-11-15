import 'package:chit_chat/view/chat/chat_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         databaseURL:
  //             "https://chat-21b30-default-sdffsdfsdb.asia-southeast1.firebasedatabase.app",
  //         apiKey: 'AIzaSyC9ylZriuemZ-M2lANhjEeF5qbGbCr1-rg',
  //         appId: '1:307112280698:android:1be5f7c039ecdb7331b1c3',
  //         projectId: 'chat-21b30',
  //         messagingSenderId: ''));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(home: ChatView());
  }
}
