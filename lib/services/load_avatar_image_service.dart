import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider loadAvatarImage(String? avatarUrl) {
  if (avatarUrl!.isEmpty) {
    return const AssetImage(
        'assets/images/cute_cat.jpg');
  } else if (avatarUrl.startsWith('file:///')) {
    return FileImage(File(avatarUrl.replaceFirst('file:///', '')));
  } else {
    return NetworkImage(avatarUrl);
  }
}
