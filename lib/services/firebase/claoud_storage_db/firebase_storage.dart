import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseCloudStorageHelper {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  /// Uploads a receipt image to Firebase Storage and returns the download URL.
  // Future<String> uploadReceipt(File file, String fileName) async {
  //   try {
  //     final ref = firebaseStorage.ref().child('receipts/$fileName');

  //     await ref.putFile(file);
      
  //     final downloadUrl = await ref.getDownloadURL();
      
  //     return downloadUrl;
  //   } catch (e) {
  //     throw Exception('Failed to upload receipt: $e');
  //   }
  // }

  Future<String?> uploadReceipt(File file, String fileName) async {
    try {

      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('receipts/$fileName');
      debugPrint(file.exists().toString());
      UploadTask uploadTask = storageReference.putFile(file);
      debugPrint(uploadTask.toString());

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      debugPrint(downloadURL
      );
      debugPrint('Receipt uploaded to Firebase Storage. Download URL: $downloadURL');

      return downloadURL;

    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }


  /// Retrieves a receipt's download URL given its path in Firebase Storage.
  Future<String> getReceiptUrl(String receiptPath) async {
    try {
      final ref = firebaseStorage.ref().child(receiptPath);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to get receipt URL: $e');
    }
  }

  Future<String?> uploadProfileImage(File? image) async {
    if (image == null) return null;
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${image.path.split('/').last}');

      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      debugPrint(
          'File uploaded to Firebase Storage. Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
