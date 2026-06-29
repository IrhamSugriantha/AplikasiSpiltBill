import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/item_model.dart';

class AppController extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Auth State ──────────────────────────────────────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Persistent Login ─────────────────────────────────────────
  static const _keyUserId = 'saved_user_id';

  /// Coba auto-login dari data yang tersimpan di penyimpanan lokal
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_keyUserId);
    if (savedId == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(savedId)
          .get();
      if (!doc.exists) {
        await prefs.remove(_keyUserId);
        return false;
      }
      _currentUser = UserModel.fromJson(doc.data()!);
      _startListening();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveSession() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, _currentUser!.id);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  /// Returns null on success, error message on failure
  Future<String?> login(String email, String password) async {
    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .where('password', isEqualTo: password)
          .get();
      if (qs.docs.isEmpty) return 'Email atau password salah.';
      _currentUser = UserModel.fromJson(qs.docs.first.data());
      await _saveSession();
      _startListening();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns null on success, error message on failure
  Future<String?> register(String name, String email, String password) async {
    try {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();
      if (qs.docs.isNotEmpty) return 'Email sudah terdaftar.';

      final newUser = UserModel(
        id: _uuid.v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toJson());

      _currentUser = newUser;
      await _saveSession();
      _startListening();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _clearSession();
    _currentUser = null;
    _sessionsSub?.cancel();
    _sessions.clear();
    notifyListeners();
  }

  // ── Session State ───────────────────────────────────────────
  final List<SessionModel> _sessions = [];
  StreamSubscription? _sessionsSub;

  void _startListening() {
    _sessionsSub?.cancel();
    if (_currentUser == null) return;
    
    // For simplicity, we load all sessions that involve the user.
    // In production, we'd use array-contains on members field.
    _sessionsSub = FirebaseFirestore.instance
        .collection('sessions')
        .where(
          'ownerId',
          isEqualTo: _currentUser!.id,
        )
        .snapshots()
        .listen((snapshot) {
      _sessions.clear();
      for (final doc in snapshot.docs) {
        try {
          _sessions.add(SessionModel.fromJson(doc.data()));
        } catch (e) {
          // Ignore bad data
        }
      }
      notifyListeners();
    });
  }

  List<SessionModel> get sessions => List.unmodifiable(_sessions);

  List<SessionModel> get activeSessions =>
      _sessions.where((s) => !s.isCompleted).toList();

  List<SessionModel> get completedSessions =>
      _sessions.where((s) => s.isCompleted).toList();

  /// Total piutang = sum of effective total of active sessions
  /// (excluding host's share, approximated as all members share)
  double get totalPiutang {
    double total = 0;
    for (final s in activeSessions) {
      final bills = s.buildMemberBills(hostName);
      for (final mb in bills) {
        if (!mb.isHost && !mb.isPaid) {
          total += s.mode == BillMode.bagiRata ? s.perPersonAmount : mb.total;
        }
      }
    }
    return total;
  }

  void addSession(SessionModel session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  SessionModel createSession({
    required String name,
    required String date,
    required List<String> members,
  }) {
    return SessionModel(
      id: _uuid.v4(),
      ownerId: _currentUser!.id,
      sessionName: name,
      date: date,
      members: members,
    );
  }

  Future<void> finalizeSession(SessionModel session) async {
    final bills = session.buildMemberBills(hostName);
    final allPaid = bills.every((mb) => mb.isPaid);
    session.isCompleted = allPaid;

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(session.id)
        .set(session.toJson());
  }

  Future<void> deleteSession(String id) async {
    await FirebaseFirestore.instance.collection('sessions').doc(id).delete();
  }

  Future<void> toggleMemberPaid(String sessionId, String memberName) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    if (session.paidMembers.contains(memberName)) {
      session.paidMembers = Set.from(session.paidMembers)..remove(memberName);
    } else {
      session.paidMembers = Set.from(session.paidMembers)..add(memberName);
    }

    notifyListeners();
    await finalizeSession(session);
  }

  String get hostName => _currentUser?.name ?? 'Host';
}
