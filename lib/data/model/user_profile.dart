import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? 'User',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'username': username, 'photoUrl': photoUrl};
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? username,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [uid, email, username, photoUrl];
}
