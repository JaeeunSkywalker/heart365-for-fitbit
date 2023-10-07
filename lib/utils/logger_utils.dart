import 'package:flutter/foundation.dart';

//print를 사용하지 않기 위해 만듦.
void safePrint(Object? object) {
  if (!kReleaseMode) {
    print(object);
  }
}
