class Person {
  String id;
  String username;
  String email;
  // ignore: non_constant_identifier_names
  String profile_picture;

  Person(this.username, this.email, this.profile_picture) : id = '';
  Person.withId(this.id, this.username, this.email, this.profile_picture);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['profile_picture'] = profile_picture;

    return map;
  }

  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person.withId(
      id,
      map['username'],
      map['email'],
      map['profile_picture'],
    );
  }
}
