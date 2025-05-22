import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/topic_progress_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthState {
  final bool isLoggedIn;
  final String? email;
  final String? userId;
  final String? username;
  final bool isEmailVerified;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isLoggedIn = false,
    this.email,
    this.userId,
    this.username,
    this.isEmailVerified = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? email,
    String? userId,
    String? username,
    bool? isEmailVerified,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    // Uygulama başlatıldığında Firebase giriş durumunu kontrol et
    _initFirebaseAuth();
  }

  // Firebase Auth dinleyici
  Future<void> _initFirebaseAuth() async {
    // Firebase oturum durumunu dinle
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();
        final refreshedUser = firebase_auth.FirebaseAuth.instance.currentUser;

        // Kullanıcı giriş yapmış durumda
        state = state.copyWith(
          isLoggedIn: true,
          email: refreshedUser?.email ?? user.email,
          userId: refreshedUser?.uid ?? user.uid,
          username: refreshedUser?.displayName ??
              refreshedUser?.email?.split('@')[0] ??
              'Kullanıcı',
          isEmailVerified: refreshedUser?.emailVerified ?? false,
        );

        // Kullanıcı Firestore'da var mı kontrol et, yoksa oluştur
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          // Kullanıcı Firestore'da yok, oluştur
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'userId': user.uid,
            'username':
                user.displayName ?? user.email?.split('@')[0] ?? 'Kullanıcı',
            'email': user.email,
            'createdAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
            'emailVerified': refreshedUser?.emailVerified ?? false,
            "isAdmin": false
          });
        } else {
          // Kullanıcı var, son giriş bilgisini güncelle
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastLoginAt': Timestamp.now(),
            'emailVerified': refreshedUser?.emailVerified ?? false,
          });
        }

        // Update the global login state
        _ref.read(isUserLoggedInProvider.notifier).state = true;

        // Load topic progress after successful login
        _loadUserProgress();
      } else {
        // Kullanıcı çıkış yapmış durumda
        state = AuthState();

        // Update the global login state
        _ref.read(isUserLoggedInProvider.notifier).state = false;
      }
    });
  }

  // Load user progress after login
  void _loadUserProgress() {
    // Load the user progress data
    Future.microtask(
        () => _ref.read(topicProgressProvider.notifier).loadUserProgress());
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Firebase Auth ile giriş yap
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();

        // Kullanıcı giriş yapmış ise Firestore'daki son giriş bilgisini güncelle
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastLoginAt': Timestamp.now(),
          'emailVerified': user.emailVerified,
        });

        // Giriş başarılı - authStateChanges dinleyicisi state'i otomatik olarak güncelleyecek
        state = state.copyWith(
          isLoading: false,
          isEmailVerified: user.emailVerified,
        );
        return true;
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: 'Giriş yapılamadı');
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Yanlış şifre girdiniz';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'user-disabled':
          errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmış';
          break;
        default:
          errorMessage = 'Giriş sırasında bir hata oluştu: ${e.message}';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Giriş sırasında bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Firebase Auth ile kayıt ol
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Kullanıcı adını kaydet
        await user.updateDisplayName(username);

        // Firestore'a kullanıcı bilgilerini kaydet
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'username': username,
          'email': email,
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'emailVerified': false,
          "isAdmin": false
        });

        // E-posta doğrulama gönder
        await user.sendEmailVerification();

        // Kayıt başarılı - authStateChanges dinleyicisi state'i otomatik olarak güncelleyecek
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: 'Kayıt yapılamadı');
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf, daha güçlü bir şifre seçin';
          break;
        case 'operation-not-allowed':
          errorMessage = 'E-posta/şifre girişi devre dışı bırakılmış';
          break;
        default:
          errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Kayıt sırasında bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Doğrulama e-postası gönderilirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<bool> checkEmailVerification() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Kullanıcı bilgilerini yenile
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        // Güncel kullanıcıyı al
        final updatedUser = firebase_auth.FirebaseAuth.instance.currentUser;

        // Email doğrulama durumunu al
        final isVerified = updatedUser?.emailVerified ?? false;

        // Firestore'daki kullanıcı belgesini güncelle
        if (isVerified) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'emailVerified': true,
          });
        }

        state = state.copyWith(
          isEmailVerified: isVerified,
          isLoading: false,
        );

        return isVerified;
      }

      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage:
              'E-posta doğrulama durumu kontrol edilirken bir hata oluştu: ${e.toString()}');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Çıkış zamanını Firestore'a kaydet
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastLogoutAt': Timestamp.now(),
        });
      }

      await firebase_auth.FirebaseAuth.instance.signOut();
      // authStateChanges dinleyicisi otomatik olarak state'i güncelleyecek
    } catch (e) {
      print('Çıkış yapılırken hata: $e');
    }
  }

  Future<bool> updateUserProfile({String? username}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firebase Authentication'da kullanıcı adını güncelle
        if (username != null && username.isNotEmpty) {
          await user.updateDisplayName(username);
        }

        // Firestore'daki kullanıcı belgesini güncelle
        final updateData = <String, dynamic>{
          'updatedAt': Timestamp.now(),
        };

        if (username != null && username.isNotEmpty) {
          updateData['username'] = username;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);

        // Güncel kullanıcı bilgilerini state'e yansıt
        state = state.copyWith(
          username: username ?? state.username,
          isLoading: false,
        );

        return true;
      }

      state = state.copyWith(
          isLoading: false, errorMessage: 'Kullanıcı bulunamadı');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Profil güncellenirken bir hata oluştu: ${e.toString()}',
      );
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
