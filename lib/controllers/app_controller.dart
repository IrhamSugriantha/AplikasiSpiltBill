import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/item_model.dart';

class AppController extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Auth State ──────────────────────────────────────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Dummy registered users list (simulates a local DB)
  final List<UserModel> _registeredUsers = [
    UserModel(
      id: 'user-budi',
      name: 'Budi',
      email: 'budi@example.com',
      password: 'password123',
    ),
  ];

  /// Returns null on success, error message on failure
  String? login(String email, String password) {
    final user = _registeredUsers.where(
      (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase() &&
             u.password == password,
    );
    if (user.isEmpty) return 'Email atau password salah.';
    _currentUser = user.first;
    notifyListeners();
    return null;
  }

  /// Returns null on success, error message on failure
  String? register(String name, String email, String password) {
    final exists = _registeredUsers.any(
      (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) return 'Email sudah terdaftar.';
    final newUser = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
    _registeredUsers.add(newUser);
    _currentUser = newUser;
    // Pre-seed dummy sessions for new user (empty by default)
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ── Session State ───────────────────────────────────────────
  final List<SessionModel> _sessions = [
    SessionModel(
      id: 'sess-1',
      sessionName: 'Nugas Kafe A',
      date: '12 Okt 2023',
      members: ['Budi', 'Irham', 'Citra'],
      mode: BillMode.detailPesanan,
      isCompleted: false,
      items: [
        OrderItem(id: 'i1', name: 'Ayam Bakar Madu Spesial', price: 80000, assignedTo: 'Budi'),
        OrderItem(id: 'i2', name: 'Nasi Padang', price: 10000, assignedTo: 'Irham'),
        OrderItem(id: 'i3', name: 'Jus Jeruk', price: 5000, assignedTo: 'Irham'),
        OrderItem(id: 'i4', name: 'Kwetiau Siram Sapi', price: 55000, assignedTo: 'Citra'),
      ],
    ),
    SessionModel(
      id: 'sess-2',
      sessionName: 'Nonton Bioskop',
      date: '10 Okt 2023',
      members: ['Budi', 'Ani', 'Citra'],
      mode: BillMode.bagiRata,
      totalBill: 105000,
      isCompleted: false,
    ),
    SessionModel(
      id: 'sess-3',
      sessionName: 'Nasi Padang Stikes',
      date: '05 Okt 2023',
      members: ['Budi', 'Reza', 'Sari'],
      mode: BillMode.bagiRata,
      totalBill: 150000,
      isCompleted: true,
    ),
    SessionModel(
      id: 'sess-4',
      sessionName: 'Ngopi Senja',
      date: '28 Sep 2023',
      members: ['Budi', 'Dina'],
      mode: BillMode.bagiRata,
      totalBill: 85000,
      isCompleted: true,
    ),
  ];

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
      // Piutang = total bill minus host's own share
      final perPerson = s.mode == BillMode.bagiRata
          ? s.perPersonAmount
          : (s.members.isEmpty ? 0 : s.effectiveTotal / s.members.length);
      // Count non-host, non-paid members
      total += s.effectiveTotal - perPerson;
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
      sessionName: name,
      date: date,
      members: members,
    );
  }

  void finalizeSession(SessionModel session) {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) {
      _sessions[idx] = session;
    } else {
      _sessions.insert(0, session);
    }
    notifyListeners();
  }

  void toggleMemberPaid(String sessionId, String memberName) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    // We track paid state differently — store paid member names
    notifyListeners();
  }

  String get hostName => _currentUser?.name ?? 'Host';
}
