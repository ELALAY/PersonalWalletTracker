import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final String ownerId;

  CategoryModel({required this.name, required this.iconName, required this.ownerId}): id = '';
  CategoryModel.withId({required this.id, required this.name, required this.iconName, required this.ownerId});


  factory CategoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.withId(
      id: doc.id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? 'app_icon',
      ownerId: data['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'ownerId': ownerId,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel.withId(
      id: id,
      name: map['name'],
      iconName: map['iconName'],
      ownerId: map['ownerId'],
    );
  }
}
