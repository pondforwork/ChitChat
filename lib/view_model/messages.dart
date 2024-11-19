enum ChatType {
  private,
  group,
}

class Messages {
  late String senderId;
  late String text;
  late DateTime timeStamp;

  Messages({
    required this.senderId,
    required this.text,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }

  factory Messages.fromMap(Map<String, dynamic> map) {
    return Messages(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timeStamp: DateTime.tryParse(map['timeStamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class Chat {
  late String id;
  late ChatType type;
  late List<String> participants;
  late List<Messages> messages;

  Chat({
    required this.id,
    required this.type,
    required this.participants,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name, // Convert enum to string
      'participants': participants,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      type: ChatType.values.byName(map['type'] ?? 'private'),
      participants: List<String>.from(map['participants'] ?? []),
      messages: (map['messages'] as List<dynamic>?)
              ?.map((msg) => Messages.fromMap(msg))
              .toList() ??
          [],
    );
  }
}
