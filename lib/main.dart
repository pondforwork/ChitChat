import 'package:chit_chat/view/chat/chat_view.dart';
import 'package:chit_chat/view/home/home_view.dart';
import 'package:chit_chat/view/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final FirebaseApp app;
  late final FirebaseAuth auth;

  // await Firebase.initializeApp();

  app = await Firebase.initializeApp();
  auth = FirebaseAuth.instanceFor(app: app);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: LoginView());
  }
}
