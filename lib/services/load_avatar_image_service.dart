import 'dart:io';

import 'package:flutter/material.dart';

//수정할 거 없음. 검토 완료.

ImageProvider loadAvatarImage(String? avatarUrl) {
  if (avatarUrl!.isEmpty) {
    return const AssetImage('assets/images/cute_cat.jpg');
  } else if (avatarUrl.startsWith('file:///')) {
    return FileImage(File(avatarUrl.replaceFirst('file:///', '')));
  } else {
    return NetworkImage(avatarUrl);
  }
}
