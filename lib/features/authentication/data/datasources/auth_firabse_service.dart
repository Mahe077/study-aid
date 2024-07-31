import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class RemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String username);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithFacebook();
  Future<void> updateUserCollection(UserModel user);
  Future<UserModel?> getUserById(String id);
  Future<Unit> signOut();
  Future<Unit> resetPassword(String newPassword);
  Future<Unit> sendPasswordResetEmail(String email);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();
      return UserModel.fromFirestore(doc);
    } on Exception catch (e) {
      throw Exception('Error signing in with email: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
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
    } on Exception catch (e) {
      throw Exception('Error signing up with email: $e');
    }
  }

  @override
  Future<void> updateUserCollection(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    } on Exception catch (e) {
      throw Exception('Error updating user collection: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } on Exception catch (e) {
      throw Exception('Error retrieving user by ID: $e');
    }
  }

  @override
  Future<Unit> signOut() async {
    try {
      await _auth.signOut();
      return unit;
    } on Exception catch (e) {
      throw Exception('Error signing out with: $e');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    /// Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel? user = await getUserById(userCredential.user!.uid);
      if (user == null) {
        user = UserModel(
          id: userCredential.user!.uid,
          username: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          createdTopics: [],
        );
        await updateUserCollection(user);
        return user;
      } else {
        return user;
      }
    } on Exception catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    /// Trigger the authentication flow
    try {
      final LoginResult facebookUser = await _facebookAuth.login();
      if (facebookUser.accessToken == null) {
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(
              facebookUser.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      UserModel? user = await getUserById(userCredential.user!.uid);
      if (user == null) {
        user = UserModel(
          id: userCredential.user!.uid,
          username: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          createdTopics: [],
        );
        await updateUserCollection(user);
        return user;
      } else {
        return user;
      }
    } on Exception catch (e) {
      throw Exception('Error signing in with Facebook: $e');
    }
  }

  @override
  Future<Unit> resetPassword(String newPassword) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Error reset password: user not logged in');
      }
      return unit;
    } catch (e) {
      throw Exception('Error reset password: $e');
    }
  }

  @override
  Future<Unit> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return unit;
    } catch (e) {
      throw Exception('Error password reset email: $e');
    }
  }
}
