//수정할 거 없음. 검토 완료.

//핏빗 API에서 User Data request 했을 때 받는 정보

class UserProfile {
  final String? displayName;
  final String? fullName;

  //age는 int인데 flutter_secure_storage에 저장할 때 String으로만 저장이 되므로.
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

  //코드제너레이터 없이 하려니까 힘들다.
  UserProfile copyWith({String? displayName}) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? age,
      avatar: avatar ?? avatar,
      dateOfBirth: dateOfBirth ?? dateOfBirth,
      encodedId: encodedId ?? encodedId,
      fullName: fullName ?? fullName,
      gender: gender ?? gender,
      memberSince: memberSince ?? memberSince,
    );
  }

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
