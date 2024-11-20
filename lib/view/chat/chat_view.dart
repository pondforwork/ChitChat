import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // Controller instances
  ChatDbController chatDbController = Get.put(ChatDbController());
  UserController userController = Get.put(UserController());
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  @override
  void initState() {
    super.initState();
    chatDbController.watchDatabaseChanges("chats");

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDDAE),
        title: Obx(() {
          return Text(
            chatDbController.currentChatDuoName.value,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
      body: Column(
        children: [
          // List of chat messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: chatDbController.messageList.length,
                itemBuilder: (context, index) {
                  final message = chatDbController.messageList[index];

                  return ListTile(
                    title: Align(
                      alignment: message.senderId ==
                              userController.userUid.value
                          ? Alignment
                              .centerRight // Align right if it's the current user's message
                          : Alignment
                              .centerLeft, // Align left if it's another user's message
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: message.senderId ==
                                  userController.userUid.value
                              ? Colors.blueAccent.withOpacity(0.2)
                              : Colors.grey[
                                  300], // Different background color for your message vs others
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    5.0), // Spacing between text and timestamp
                            Text(
                              chatDbController
                                  .formatTimestamp(message.timeStamp),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Text input and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text Field for input
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    chatDbController.sendMessage(
                        chatId: chatDbController.currentChatId.value,
                        senderId: userController.userUid.value,
                        text: messageController.text);
                    messageController.text = "";
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
