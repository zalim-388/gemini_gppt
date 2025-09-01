class Model {
  final String url;

  Model({required this.url});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(url: json['url'] ?? '');
  }
}
