import 'dart:core';

extension JoinUri on Uri {
  Uri join(String path) {
    return resolve(path.endsWith('/') ? path.substring(0, path.length - 1) : path);
  }
}
