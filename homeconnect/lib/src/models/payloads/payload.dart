class Payload<T> {
  final Map<String, dynamic> data;

  Payload(this.data);

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(json);
  }

  Map<String, dynamic> toJson() {
    return data;
  }
}
