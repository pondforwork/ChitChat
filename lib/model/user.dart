class UserInstance {
  String id;
  String username;
  List<String> friends;
  List<String> chats;
  String userId;
  String? photoUrl;
  String email; // New non-nullable email field

  UserInstance({
    required this.id,
    required this.username,
    required this.friends,
    required this.chats,
    required this.userId,
    required this.email, // Added as required
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
      email: map['email'] ?? '', // Ensure a default value if missing
      photoUrl: map['photoUrl'], // Handle null case automatically
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'friends': friends,
      'chats': chats,
      'userId': userId,
      'photoUrl': photoUrl,
      'email': email, // Added to the map
    };
  }
}
