class UserModel {
  final String name;
  final String mobile;
  final String state;
  final String joined;
  final String language;

  UserModel({
    required this.name,
    required this.mobile,
    this.state = '',
    this.joined = '',
    this.language = 'hi',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'state': state,
    'joined': joined,
    'language': language,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] ?? '',
    mobile: json['mobile'] ?? '',
    state: json['state'] ?? '',
    joined: json['joined'] ?? '',
    language: json['language'] ?? 'hi',
  );
}
