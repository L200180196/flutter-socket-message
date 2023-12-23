class Message {
  String message;
  String sendByMe;
  String dateTime;

  Message({
    required this.message,
    required this.sendByMe,
    required this.dateTime
  });

  factory Message.fromJson(Map<String,dynamic> json) {
    return Message(message: json["message"], sendByMe: json["sendByMe"], dateTime: json["dateTime"]);
  }
}