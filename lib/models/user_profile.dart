class UserProfile {

  final String? displayName;
  final String? fullName;
  //age는 int인데 flutter_secure_storage에 저장할 때 String으로만 저장이 되므로...
  final String? age;
  final String? dateOfBirth;
  final String? gender;
  final String? encodedId;
  final String? memberSince;
  final String? avatar;

  UserProfile({
    required this.displayName,
    required this.fullName,
    required this.age,
    required this.dateOfBirth,
    required this.gender,
    required this.encodedId,
    required this.memberSince,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['user']['displayName'],
      fullName: json['user']['fullName'],
      age: json['user']['age'].toString(),
      dateOfBirth: json['user']['dateOfBirth'],
      gender: json['user']['gender'],
      encodedId: json['user']['encodedId'],
      memberSince: json['user']['memberSince'],
      avatar: json['user']['avatar'],
    );
  }

  @override
  String toString() {
    return 'UserProfile(displayName: $displayName, fullName: $fullName, age: $age, dateOfBirth: $dateOfBirth, gender: $gender, encodedId: $encodedId, memberSince: $memberSince, avatar: $avatar)';
  }
}
