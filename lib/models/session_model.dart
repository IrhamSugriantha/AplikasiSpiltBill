import 'item_model.dart';

enum BillMode { bagiRata, detailPesanan }

class MemberBill {
  final String name;
  final bool isHost;
  List<OrderItem> items;
  bool isPaid;

  MemberBill({
    required this.name,
    this.isHost = false,
    this.items = const [],
    this.isPaid = false,
  });

  double get total => items.fold(0, (sum, item) => sum + item.price);
}

class SessionModel {
  final String id;
  final String ownerId;
  String sessionName;
  String date;
  List<String> members; // member names
  BillMode mode;
  double totalBill; // used for bagiRata mode
  List<OrderItem> items; // used for detailPesanan mode
  bool isCompleted; // all members paid
  Set<String> paidMembers; // track who has paid

  SessionModel({
    required this.id,
    required this.ownerId,
    required this.sessionName,
    required this.date,
    required this.members,
    this.mode = BillMode.bagiRata,
    this.totalBill = 0,
    this.items = const [],
    this.isCompleted = false,
    this.paidMembers = const {},
  });

  /// Returns per-member bill amount in bagiRata mode
  double get perPersonAmount =>
      members.isEmpty ? 0 : totalBill / members.length;

  /// Total from items (detailPesanan mode)
  double get itemsTotal => items.fold(0, (sum, i) => sum + i.price);

  double get effectiveTotal =>
      mode == BillMode.bagiRata ? totalBill : itemsTotal;

  /// Build MemberBill list for ringkasan screen
  List<MemberBill> buildMemberBills(String hostName) {
    if (mode == BillMode.bagiRata) {
      return members.map((m) {
        final mb = MemberBill(
          name: m,
          isHost: m == hostName,
          isPaid: m == hostName || paidMembers.contains(m),
        );
        return mb;
      }).toList();
    } else {
      // Detail pesanan: group items by assignedTo
      final Map<String, List<OrderItem>> grouped = {};
      for (final member in members) {
        grouped[member] = [];
      }
      for (final item in items) {
        grouped.putIfAbsent(item.assignedTo, () => []).add(item);
      }
      return members.map((m) {
        final memberItems = grouped[m] ?? [];
        final hasNoBill = memberItems.isEmpty;
        return MemberBill(
          name: m,
          isHost: m == hostName,
          items: memberItems,
          isPaid: m == hostName || hasNoBill || paidMembers.contains(m),
        );
      }).toList();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'sessionName': sessionName,
        'date': date,
        'members': members,
        'mode': mode.name,
        'totalBill': totalBill,
        'items': items.map((i) => i.toJson()).toList(),
        'isCompleted': isCompleted,
        'paidMembers': paidMembers.toList(),
      };

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      sessionName: json['sessionName'] ?? '',
      date: json['date'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      mode: BillMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => BillMode.bagiRata,
      ),
      totalBill: (json['totalBill'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] ?? false,
      paidMembers: Set<String>.from(json['paidMembers'] ?? []),
    );
  }
}
