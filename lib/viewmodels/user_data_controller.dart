import 'package:rxdart/rxdart.dart';

import '../models/user_profile.dart';

//현재 스트림을 3개 관리 중
//그 중 첫 번째가 User Data Stream(내가 지은 이름)!
class UserDataController {
  final allOfUserDataController = BehaviorSubject<UserProfile>.seeded(
    UserProfile(
      age: '0',
      avatar: '',
      dateOfBirth: '',
      displayName: '',
      encodedId: '',
      fullName: '',
      gender: '',
      memberSince: '',
    ),
  );
}

final userDataController = UserDataController();
