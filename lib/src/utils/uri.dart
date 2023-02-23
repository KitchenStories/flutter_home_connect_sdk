import 'dart:core';

extension JoinUri on Uri {
  join(String path) {
    return resolve(path);
  }
}
