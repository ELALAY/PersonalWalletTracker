class GoalModel {
  String id;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime endDate;
  String uid;
  String goalIcon;


  GoalModel({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.endDate,
    required this.uid,
    required this.goalIcon
  }): id = '';

  GoalModel.withId({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.endDate,
    required this.uid,
    required this.goalIcon
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'endDate': endDate.toIso8601String(),
      'uid': uid,
      'goalIcon': goalIcon,

    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalModel.withId(
      id: id,
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      endDate: DateTime.parse(map['endDate']),
      uid: map['uid'],
      goalIcon: map['goalIcon'],
    );
  }
}
