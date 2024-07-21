import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';

abstract class RemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String username);
  Future<void> updateUserCollection(UserModel user);
  Future<UserModel> getUserById(String id);
  Future<Unit> signOut();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userCredential.user?.uid)
        .get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> signUpWithEmail(
      String email, String password, String username) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    UserModel user = UserModel(
      id: userCredential.user!.uid,
      username: username,
      email: email,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      createdTopics: [],
    );
    await updateUserCollection(user);
    return user;
  }

  @override
  Future<void> updateUserCollection(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  @override
  Future<UserModel> getUserById(String id) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<Unit> signOut() async {
    await _auth.signOut();
    return unit;
  }
}
