class CurrentChat {
  late String message; // Message content
  late String senderId; // Sender's identifier
  late DateTime timeStamp; // Timestamp of the message

  // Constructor
  CurrentChat({
    required this.message,
    required this.senderId,
    required this.timeStamp,
  });

  // Factory method to create a CurrentChat object from a Map
  factory CurrentChat.fromMap(Map<String, dynamic> map) {
    return CurrentChat(
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      timeStamp: map['timeStamp'] != null
          ? DateTime.parse(map['timeStamp'])
          : DateTime.now(),
    );
  }

  // Method to convert a CurrentChat object to a Map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }
}
