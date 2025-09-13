import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

abstract class FirebaseProps {
  Future<void> addData(String path, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> fetchData(String path, String id);
}

class FirebaseController implements FirebaseProps {
  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<void> addData(
    String path,
    String id,
    Map<String, dynamic> data,
  ) async {
    final docRef = FirebaseFirestore.instance.collection(path).doc(id);
    await docRef.set({
      ...data,
      'userId': id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addAutoIncrementedKey(
    String collectionPath,
    String userId,
    Map<String, dynamic> value,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(userId);
    final docSnapshot = await docRef.get();

    Map<String, dynamic> existingData = {};
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        existingData = Map<String, dynamic>.from(data);
      }
    }

    // Find next numeric key
    List<int> existingKeys = existingData.keys
        .map((k) => int.tryParse(k))
        .whereType<int>()
        .toList();
    int nextKey = existingKeys.isEmpty
        ? 1
        : (existingKeys.reduce((a, b) => a > b ? a : b) + 1);

    // Add new entry
    existingData[nextKey.toString()] = {
      ...value,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Update the entire document
    await docRef.set(existingData);

    if (kDebugMode) {
      print("Upload stored under key: $nextKey");
    }
  }

  @override
  Future<Map<String, dynamic>> fetchData(String path, String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await firebase
        .collection(path)
        .doc(id)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    } else {
      return {};
    }
  }

  Future<DocumentSnapshot> fetchSingle(String path, String id) async {
    DocumentSnapshot doc = await firebase.collection(path).doc(id).get();
    return doc;
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    try {
      // Initialize with your Web Client ID
      await googleSignIn.initialize(
        serverClientId:
            '  51302484906-9kbpdf0ampbj4hchc6p5mh0b1aveof1j.apps.googleusercontent.com',
      );

      // On supported platforms (e.g., Android), use authenticate()
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Build a credential for Firebase Authentication
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In failed: $e');
      }
      return null;
    }
  }

  Future<void> uploadImageAndSaveMetadata({
    required String userId,
    required String firestorePath,
    required String storagePath,
    required String fileName,
    required File file,
    required String name,
    required String price,
    required String details,
    required String location,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        '$storagePath/$userId/$fileName.jpg',
      );

      // 2. Upload image to Firebase Storage
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 3. Save metadata to Firestore
      final metadata = {
        'userId': userId,
        'imageUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileName': '$fileName.jpg',
        'storagePath': storageRef.fullPath,
        'name': name,
        'price': price,
        'details': details,
        'location': location,
      };

      await FirebaseFirestore.instance
          .collection(firestorePath)
          .doc()
          .set(metadata);

      if (kDebugMode) {
        print('Upload successful!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> uploadMultipleImages({
    required String userId,
    required String firestorePath,
    required String storagePath,
    required List<XFile> pickedFiles,
    required String name,
    required String price,
    required String details,
    required String location,
  }) async {
    for (var i = 0; i < pickedFiles.length; i++) {
      final file = File(pickedFiles[i].path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';

      await uploadImageAndSaveMetadata(
        userId: userId,
        firestorePath: firestorePath,
        storagePath: storagePath,
        fileName: fileName,
        file: file,
        name: name,
        price: price,
        details: details,
        location: location,
      );
    }

    if (kDebugMode) {
      print('All images uploaded successfully.');
    }
  }

  Future<Map<String, bool>> changeUserEmail(String newEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload(); // Refresh user info
        return {'success': true};
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Error updating email: ${e.message}");
      }
      // Handle errors like reauthentication required
    }
    return {'success': false};
  }

  Future<Map<String, bool>> updateValue(
    String uid,
    String value,
    String key,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      key: value,
    });
    return {'success': true};
  }
}
