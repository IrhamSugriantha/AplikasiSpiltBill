import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/app_controller.dart';
import '../models/session_model.dart';
import '../models/item_model.dart';
import '../utils/app_theme.dart';
import 'ringkasan_tagihan_screen.dart';

class InputPesananScreen extends StatefulWidget {
  final SessionModel session;
  const InputPesananScreen({super.key, required this.session});

  @override
  State<InputPesananScreen> createState() => _InputPesananScreenState();
}

class _InputPesananScreenState extends State<InputPesananScreen> {
  static const _uuid = Uuid();
  BillMode _mode = BillMode.bagiRata;

  // Bagi Rata
  final _totalCtrl = TextEditingController();

  // Detail Pesanan
  final List<_ItemEntry> _itemEntries = [];

  @override
  void initState() {
    super.initState();
    _addItemEntry();
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    for (final e in _itemEntries) {
      e.nameCtrl.dispose();
      e.priceCtrl.dispose();
    }
    super.dispose();
  }

  void _addItemEntry() {
    setState(() {
      _itemEntries.add(_ItemEntry(
        id: _uuid.v4(),
        nameCtrl: TextEditingController(),
        priceCtrl: TextEditingController(),
        assignedTo: widget.session.members.first,
      ));
    });
  }

  void _removeItemEntry(int index) {
    setState(() {
      _itemEntries[index].nameCtrl.dispose();
      _itemEntries[index].priceCtrl.dispose();
      _itemEntries.removeAt(index);
    });
  }

  void _hitungPembagian() {
    final ctrl = context.read<AppController>();

    if (_mode == BillMode.bagiRata) {
      final total = double.tryParse(
              _totalCtrl.text.replaceAll('.', '').replaceAll(',', '')) ??
          0;
      if (total <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan total tagihan yang valid')),
        );
        return;
      }
      widget.session.mode = BillMode.bagiRata;
      widget.session.totalBill = total;
      widget.session.items = [];
    } else {
      // Validate all items
      final items = <OrderItem>[];
      for (final e in _itemEntries) {
        final name = e.nameCtrl.text.trim();
        final price = double.tryParse(
                e.priceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ??
            0;
        if (name.isEmpty || price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Lengkapi semua data item pesanan')),
          );
          return;
        }
        items.add(OrderItem(
          id: e.id,
          name: name,
          price: price,
          assignedTo: e.assignedTo,
        ));
      }
      widget.session.mode = BillMode.detailPesanan;
      widget.session.items = items;
    }

    ctrl.finalizeSession(widget.session);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RingkasanTagihanScreen(session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostInitial =
        (context.read<AppController>().currentUser?.name ?? 'U')[0]
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Input Pesanan'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              radius: 18,
              child: Text(hostInitial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'Bagi Rata',
                    selected: _mode == BillMode.bagiRata,
                    onTap: () => setState(() => _mode = BillMode.bagiRata),
                  ),
                  _ModeTab(
                    label: 'Detail Pesanan',
                    selected: _mode == BillMode.detailPesanan,
                    onTap: () =>
                        setState(() => _mode = BillMode.detailPesanan),
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: _mode == BillMode.bagiRata
                ? _buildBagiRataBody()
                : _buildDetailPesananBody(),
          ),

          // Bottom button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hitungPembagian,
                child: const Text('Hitung Pembagian'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bagi Rata body ────────────────────────────────────────────────
  Widget _buildBagiRataBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Struk Keseluruhan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan total akhir yang tertera pada\nstruk.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // Amount input
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _totalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHint,
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline,
                        color: AppColors.accent, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sistem otomatis membaginya dengan jumlah orang yang diinput di halaman sebelumnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail Pesanan body ───────────────────────────────────────────
  Widget _buildDetailPesananBody() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: _itemEntries.length + 1,
      itemBuilder: (ctx, i) {
        if (i == _itemEntries.length) {
          // Add item button
          return GestureDetector(
            onTap: _addItemEntry,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.textSecondary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Item',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final entry = _itemEntries[i];
        return _ItemCard(
          entry: entry,
          members: widget.session.members,
          onDelete: _itemEntries.length > 1 ? () => _removeItemEntry(i) : null,
          onAssignedChanged: (val) {
            setState(() => entry.assignedTo = val!);
          },
        );
      },
    );
  }
}

// ── Supporting classes ────────────────────────────────────────────

class _ItemEntry {
  final String id;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  String assignedTo;

  _ItemEntry({
    required this.id,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.assignedTo,
  });
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final _ItemEntry entry;
  final List<String> members;
  final VoidCallback? onDelete;
  final ValueChanged<String?> onAssignedChanged;

  const _ItemCard({
    required this.entry,
    required this.members,
    this.onDelete,
    required this.onAssignedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + delete
          Row(
            children: [
              const Text('Nama Makanan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.belumLunas, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: entry.nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Nama item...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harga',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: entry.priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        hintText: '0',
                        prefixText: 'Rp ',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Assigned to
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Siapa yang makan?',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: members.contains(entry.assignedTo)
                          ? entry.assignedTo
                          : members.first,
                      items: members
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: onAssignedChanged,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
