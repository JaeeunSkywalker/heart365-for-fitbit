import 'dart:async';

import 'package:rxdart/rxdart.dart';

//수정할 거 없음. 검토 완료.

//현재 스트림을 3개 관리 중.
//그 중 세 번째가 Page Data Stream(내가 지은 이름)!
class PageDataController {
  final ecgPageDataController = BehaviorSubject<List<int>>.seeded([]);

  static StreamController<List<int>> _createPageDataController() {
    return StreamController<List<int>>.broadcast();
  }
}

final pageDataController = PageDataController();
