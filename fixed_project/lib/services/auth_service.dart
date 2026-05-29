import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN — throws FirebaseAuthException so caller can show exact error
  Future<User?> signIn(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // REGISTER — throws FirebaseAuthException so caller can show exact error
  Future<User?> register(String email, String password,
      {String? displayName}) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Optionally save the display name
    if (displayName != null && displayName.trim().isNotEmpty) {
      await userCredential.user?.updateDisplayName(displayName.trim());
    }

    return userCredential.user;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // AUTH STATE STREAM
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
