class UserInstance {
  String id;
  String username;
  List<String> friends;
  List<String> chats;
  String userId;
  String? photoUrl;

  UserInstance({
    required this.id,
    required this.username,
    required this.friends,
    required this.chats,
    required this.userId,
    this.photoUrl,
  });

  factory UserInstance.fromMap(Map<String, dynamic> map) {
    return UserInstance(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      friends: map['friends'] != null
          ? List<String>.from(map['friends'] as List<dynamic>)
          : [],
      chats: map['chats'] != null
          ? List<String>.from(map['chats'] as List<dynamic>)
          : [],
      userId: map['userId'] ?? '',
      photoUrl: map['photoUrl'], // Handle null case automatically
    );
  }

  // Updated toMap method
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'friends': friends,
      'chats': chats,
      'userId': userId,
      'photoUrl': photoUrl,
    };
  }
}
