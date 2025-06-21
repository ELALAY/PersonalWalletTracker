class Person {
  String id;
  String username;
  String email;
  // ignore: non_constant_identifier_names
  String profile_picture;
  // ignore: non_constant_identifier_names
  String default_currency;
  bool enableNotifications;
  bool transactionsAlert;
  bool budgetLimitAlert;
  bool goalProgressApdates;
  bool sharedActivitiesActivities;

  Person(
    this.username,
    this.email,
    this.profile_picture,
    this.enableNotifications,
    this.transactionsAlert,
    this.budgetLimitAlert,
    this.goalProgressApdates,
    this.sharedActivitiesActivities,
  ) : id = '',
      default_currency = 'USD';
  Person.withId(
    this.id,
    this.username,
    this.email,
    this.profile_picture,
    this.default_currency,
    this.enableNotifications,
    this.transactionsAlert,
    this.budgetLimitAlert,
    this.goalProgressApdates,
    this.sharedActivitiesActivities,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['profile_picture'] = profile_picture;
    map['default_currency'] = default_currency;
    map['enableNotifications'] = enableNotifications;
    map['transactionsAlert'] = transactionsAlert;
    map['budgetLimitAlert'] = budgetLimitAlert;
    map['goalProgressApdates'] = goalProgressApdates;
    map['sharedActivitiesActivities'] = sharedActivitiesActivities;

    return map;
  }

  factory Person.fromMap(Map<String, dynamic> map, String id) {
    return Person.withId(
      id,
      map['username'],
      map['email'],
      map['profile_picture'],
      map['default_currency'] ?? 'USD',
      map['enableNotifications'] ?? true,
      map['transactionsAlert'] ?? true,
      map['budgetLimitAlert'] ?? true,
      map['goalProgressApdates'] ?? true,
      map['sharedActivitiesActivities'] ?? true,
    );
  }
}
