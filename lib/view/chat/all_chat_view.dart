import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllChatView extends StatefulWidget {
  const AllChatView({super.key});

  @override
  State<AllChatView> createState() => _AllChatViewState();
}

class _AllChatViewState extends State<AllChatView> {
  ChatDbController chatDbController = Get.put(ChatDbController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                //Mockup Function

                chatDbController.startPrivateChat(
                    "HQkGkOzTDiX0WglqaysNzcgr1O33",
                    "LlpNuYauPAhoyCqreYF6PBQhenD2");
              },
              child: Icon(Icons.add))
        ],
      ),
    );
  }
}
