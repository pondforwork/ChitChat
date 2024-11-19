class Friend {
  late String id;
  String? lastMessage; // Nullable
  DateTime? lastMessageTime; // Nullable
  late String photoURL;
  late String status;
  late String userId;
  late String username;
  late String email;

  // Constructor to initialize the properties
  Friend({
    required this.id,
    this.lastMessage,
    this.lastMessageTime,
    required this.photoURL,
    required this.status,
    required this.userId,
    required this.username,
    required this.email,
  });

  // From map constructor for creating a Friends object from a Map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['_id'] ?? '',
      lastMessage: map['lastMessage'], // Nullable
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null, // Nullable DateTime
      photoURL: map['photoUrl'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '', email: '',
    );
  }

  // Optional: To Map method to convert Friends object back to Map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'lastMessage': lastMessage, // Nullable
      'lastMessageTime':
          lastMessageTime?.toIso8601String(), // Nullable DateTime
      'photoUrl': photoURL,
      'status': status,
      'userId': userId,
      'username': username,
    };
  }
}
