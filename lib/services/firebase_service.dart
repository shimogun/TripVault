import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 現在のユーザーを取得
  static User? get currentUser => _auth.currentUser;

  // ユーザーのログイン状態ストリーム
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Googleサインイン
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // ユーザー情報をFirestoreに保存
      await _saveUserToFirestore(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // メールとパスワードでサインイン
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Email Sign In Error: $e');
      return null;
    }
  }

  // メールとパスワードで新規登録
  static Future<UserCredential?> registerWithEmail(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // プロフィール更新
      await userCredential.user?.updateDisplayName(name);
      
      // ユーザー情報をFirestoreに保存
      await _saveUserToFirestore(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      print('Email Registration Error: $e');
      return null;
    }
  }

  // サインアウト
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // ユーザー情報をFirestoreに保存
  static Future<void> _saveUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Save User Error: $e');
    }
  }

  // ユーザーデータを取得
  static Future<DocumentSnapshot?> getUserData() async {
    try {
      if (currentUser == null) return null;
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      print('Get User Data Error: $e');
      return null;
    }
  }

  // ユーザープロファイル更新
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (currentUser == null) return;
      await _firestore.collection('users').doc(currentUser!.uid).update(data);
    } catch (e) {
      print('Update User Profile Error: $e');
    }
  }
}