import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatelessWidget {
  UserController userController = Get.put(UserController());
  UserDbController realtimeDbController = Get.put(UserDbController());
  ChatDbController chatDbController = ChatDbController();
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
          ),
          Center(
            child: Center(
              child: InkWell(
                onTap: () {
                  print("Login Clicked");
                  userController.signInWithGoogle();
                },
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.green,
                child: Ink(
                  width: 300,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFFFDDAE),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login),
                      SizedBox(
                        width: 15,
                      ),
                      Text("เข้าสู่ระบบด้วย Google",
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (() {
        // realtimeDbController.getAllUsers();
        // realtimeDbController.checkUserExists('LlpNuYsfdauPAhoyCqreYF6PBQhenD2');
        chatDbController.saveMockMessage();
      })),
    );
  }
}
