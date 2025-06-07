class Person {
  String id;
  String username;
  String email;
  // ignore: non_constant_identifier_names
  String profile_picture;
  // ignore: non_constant_identifier_names
  String default_currency;

  Person(this.username, this.email, this.profile_picture) : id = '', default_currency = 'USD';
  Person.withId(this.id, this.username, this.email, this.profile_picture, this.default_currency);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['profile_picture'] = profile_picture;
    map['default_currency'] = default_currency;

    return map;
  }

  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person.withId(
      id,
      map['username'],
      map['email'],
      map['profile_picture'],
      map['default_currency'] ?? 'USD',
    );
  }
}
