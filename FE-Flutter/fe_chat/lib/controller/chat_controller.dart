import 'package:fe_chat/model/message.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chatMessage = <Message>[].obs;
  var connectedUser = 0.obs;
}