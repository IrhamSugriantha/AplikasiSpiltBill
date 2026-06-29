import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/session_model.dart';
import '../utils/app_theme.dart';

class RingkasanTagihanScreen extends StatefulWidget {
  final SessionModel session;
  const RingkasanTagihanScreen({super.key, required this.session});

  @override
  State<RingkasanTagihanScreen> createState() => _RingkasanTagihanScreenState();
}

class _RingkasanTagihanScreenState extends State<RingkasanTagihanScreen> {
  void _togglePaid(String memberName) {
    final ctrl = context.read<AppController>();
    if (memberName == ctrl.hostName) return; // Host can't be toggled
    
    ctrl.toggleMemberPaid(widget.session.id, memberName);
  }

  double _getMemberAmount(SessionModel session, MemberBill mb) {
    if (session.mode == BillMode.bagiRata) {
      return session.perPersonAmount;
    } else {
      return mb.total;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();
    final hostInitial = (ctrl.currentUser?.name ?? 'U')[0].toUpperCase();
    
    final session = ctrl.sessions.firstWhere(
      (s) => s.id == widget.session.id,
      orElse: () => widget.session,
    );
    
    final memberBills = session.buildMemberBills(ctrl.hostName);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Ringkasan Tagihan'),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              radius: 18,
              child: Text(hostInitial,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Session Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SESI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.sessionName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    Text(
                      formatRupiah(session.effectiveTotal),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'Anggota Sesi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Member cards
          ...memberBills.map((mb) {
            final isHost = mb.isHost;
            final isPaid = mb.isPaid;
            final amount = _getMemberAmount(session, mb);
            final initial = mb.name[0].toUpperCase();

            // Generate avatar color based on name
            final avatarColor = _avatarColor(mb.name);

            return _MemberCard(
              initial: initial,
              avatarColor: avatarColor,
              memberBill: mb,
              isHost: isHost,
              isPaid: isPaid,
              amount: amount,
              mode: session.mode,
              onTogglePaid: () => _togglePaid(mb.name),
            );
          }),
        ],
      ),
    ));
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFFDDD6FE), // purple light
      Color(0xFFFED7AA), // orange light
      Color(0xFFBFDBFE), // blue light
      Color(0xFFBBF7D0), // green light
      Color(0xFFFCE7F3), // pink light
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

// ── Member Card Widget ────────────────────────────────────────────

class _MemberCard extends StatefulWidget {
  final String initial;
  final Color avatarColor;
  final MemberBill memberBill;
  final bool isHost;
  final bool isPaid;
  final double amount;
  final BillMode mode;
  final VoidCallback onTogglePaid;

  const _MemberCard({
    required this.initial,
    required this.avatarColor,
    required this.memberBill,
    required this.isHost,
    required this.isPaid,
    required this.amount,
    required this.mode,
    required this.onTogglePaid,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final mb = widget.memberBill;
    final hasItems = mb.items.isNotEmpty;
    final showExpand = widget.mode == BillMode.detailPesanan && hasItems;

    String orderDesc;
    if (widget.mode == BillMode.bagiRata) {
      orderDesc = 'Bagian rata';
    } else {
      orderDesc = '${mb.items.length} Item';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.avatarColor,
                  child: Text(
                    widget.initial,
                    style: TextStyle(
                      color: widget.avatarColor.computeLuminance() > 0.5
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              mb.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (showExpand) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _expanded = !_expanded),
                              child: Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.mode == BillMode.detailPesanan
                                ? 'Pesanan: $orderDesc'
                                : 'Pesanan: Bagi rata',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nominal: ${formatRupiah(widget.amount)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Status badge + checkbox
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Menalangi\n(Host)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else if (widget.mode == BillMode.detailPesanan && !hasItems)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tidak Ada\nTagihan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.isPaid
                              ? AppColors.lunasLight
                              : AppColors.belumLunasLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.isPaid ? 'Sudah\nBayar' : 'Belum\nBayar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.isPaid
                                ? AppColors.lunas
                                : AppColors.belumLunas,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onTogglePaid,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: widget.isPaid
                                ? AppColors.lunas
                                : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: widget.isPaid
                                  ? AppColors.lunas
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: widget.isPaid
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Expandable detail items
          if (_expanded && mb.items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RINCIAN PESANAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...mb.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(item.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatRupiah(item.price),
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
