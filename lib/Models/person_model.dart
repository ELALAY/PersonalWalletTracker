class Person {
  String id;
  String username;
  String email;

  Person(this.username, this.email) : id = '';
  Person.withId(this.id, this.username, this.email);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['username'] = username;
    map['email'] = email;

    return map;
  }

  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person.withId(
      id,
      map['username'],
      map['email'],
    );
  }
}
