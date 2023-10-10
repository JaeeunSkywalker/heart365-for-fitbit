import 'package:flutter/foundation.dart';

//수정할 거 없음. 검토 완료.

//print를 사용하지 않기 위해 만듦.
void safePrint(Object? object) {
  if (!kReleaseMode) {
    print(object);
  }
}
