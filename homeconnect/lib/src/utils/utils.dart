/// Returns a copy of the map with all null values removed.
Map<String, dynamic> compact(Map<String, dynamic> map) {
  var copy = Map<String, dynamic>.from(map);
  return copy..removeWhere((key, value) => value == null);
}
