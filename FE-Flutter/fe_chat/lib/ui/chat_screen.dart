import 'package:fe_chat/controller/chat_controller.dart';
import 'package:fe_chat/model/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = const Color(0xFF6c5ce7);
  Color black = Colors.black;
  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
        'https://af4e-125-164-97-216.ngrok-free.app',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  final String imageUrl =
      'https://images.pexels.com/photos/270557/pexels-photo-270557.jpeg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24, // Adjust the radius as needed
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Group Informatika",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Obx(
                          () => Text(
                            "User Connect ${chatController.connectedUser}",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessage.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessage[index];
                    return MessageItem(
                      sendByMe: currentItem.sendByMe == socket.id,
                      message: currentItem.message,
                      dateTime: currentItem.dateTime,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onSubmitted: (String value) {
                    sendMessage(msgInputController.text);
                    msgInputController.text = "";
                  },
                  cursorColor: purple,
                  style: const TextStyle(color: Colors.white),
                  controller: msgInputController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: purple),
                      child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.text = "";
                        },
                        icon: const Icon(Icons.send),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    var dateTime = await getCurrentTime();
    var messageJson = {
      "message": text,
      "sendByMe": socket.id,
      "dateTime": dateTime
    };
    socket.emit('message', messageJson);
    chatController.chatMessage.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      chatController.chatMessage.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      chatController.connectedUser.value = data;
    });
  }

  getCurrentTime() async {
    // Get the current time
    DateTime now = DateTime.now();

    // Format the time using intl package
    String formattedTime = DateFormat.Hm().format(now).toString();
    print(formattedTime);
    return formattedTime;
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem(
      {super.key,
      required this.sendByMe,
      required this.message,
      required this.dateTime});
  final bool sendByMe;
  final String message;
  final String dateTime;
  @override
  Widget build(BuildContext context) {
    Color purple = const Color(0xFF6c5ce7);
    Color white = Colors.white;
    return Align(
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sendByMe ? purple : white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: sendByMe ? white : purple,
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              dateTime,
              style: TextStyle(
                fontSize: 10,
                color: (sendByMe ? white : purple).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
