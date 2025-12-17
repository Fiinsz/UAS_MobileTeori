import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { admin, ustadz, wali }

class AuthState {
  final bool loggedIn;
  final String? email;
  final Role? role;
  final String? uid;

  AuthState({this.loggedIn = false, this.email, this.role, this.uid});

  AuthState copyWith({bool? loggedIn, String? email, Role? role, String? uid}) {
    return AuthState(
      loggedIn: loggedIn ?? this.loggedIn,
      email: email ?? this.email,
      role: role ?? this.role,
      uid: uid ?? this.uid,
    );
  }
}

AuthState currentAuth = AuthState();

Future<void> signInWithEmailPassword({required String email, required String password}) async {
  final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  final uid = cred.user?.uid;
  Role? role;
  if (uid != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    final r = data['role'] as String?;
    
    // Check if approval fields exist (for existing users migration)
    final hasApprovalFields = data.containsKey('isApproved') && data.containsKey('status');
    
    // Auto-migrate existing users without approval fields
    if (!hasApprovalFields && r != null) {
      // Auto-approve existing users (they were created before verification system)
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isApproved': true,
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': 'system', // System migration
      });
    }
    
    // Check approval status after migration
    final isApproved = data['isApproved'] as bool? ?? !hasApprovalFields; // Default to true for migrated users
    final status = data['status'] as String? ?? (!hasApprovalFields ? 'approved' : 'pending');
    
    // Admins always bypass approval check
    // Non-admins must be approved
    if (r != 'admin' && !isApproved) {
      await FirebaseAuth.instance.signOut();
      if (status == 'rejected') {
        throw Exception('Akun Anda ditolak oleh admin. Silakan hubungi administrator untuk informasi lebih lanjut.');
      } else {
        throw Exception('Akun Anda masih menunggu persetujuan admin. Status: $status');
      }
    }
    
    if (r != null) {
      switch (r) {
        case 'admin':
          role = Role.admin;
          break;
        case 'ustadz':
          role = Role.ustadz;
          break;
        case 'wali':
          role = Role.wali;
          break;
      }
    }
  }
  if (role == null) {
    throw Exception('Role pengguna belum diset. Tambahkan field role di Firestore (users/${uid ?? 'unknown'}).');
  }
  currentAuth = AuthState(loggedIn: true, email: cred.user?.email, role: role, uid: uid);
}

Future<bool> registerWithEmailPassword({required String email, required String password, String? displayName, String role = 'wali'}) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) return false;
      
      // Auto-approve admin accounts, others need approval
      final isApproved = role == 'admin';
      final status = role == 'admin' ? 'approved' : 'pending';
      
      // Write user doc with role and approval fields
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'displayName': displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isApproved': isApproved,
        'status': status,
        'approvedBy': null,
        'approvedAt': null,
      }, SetOptions(merge: true));
      
      final Role roleEnum = role == 'admin' ? Role.admin : role == 'ustadz' ? Role.ustadz : Role.wali;
      currentAuth = AuthState(loggedIn: true, email: email, role: roleEnum, uid: uid);
      return true;
    } catch (_) {
      return false;
    }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  currentAuth = AuthState();
}
