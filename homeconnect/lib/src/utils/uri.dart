import 'dart:core';

extension JoinUri on Uri {
  Uri join(String path) {
    return resolve(path);
  }
}
