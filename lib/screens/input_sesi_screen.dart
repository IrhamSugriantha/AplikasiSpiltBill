import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/session_model.dart';
import '../utils/app_theme.dart';
import 'input_pesanan_screen.dart';

class InputSesiScreen extends StatefulWidget {
  const InputSesiScreen({super.key});

  @override
  State<InputSesiScreen> createState() => _InputSesiScreenState();
}

class _InputSesiScreenState extends State<InputSesiScreen> {
  final _namaCtrl = TextEditingController();
  final _temanCtrl = TextEditingController();
  String _selectedDate = '';
  final List<String> _members = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _temanCtrl.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _temanCtrl.text.trim();
    if (name.isEmpty) return;
    if (_members.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama sudah ditambahkan')),
      );
      return;
    }
    setState(() {
      _members.add(name);
      _temanCtrl.clear();
    });
  }

  void _removeMember(String name) {
    setState(() => _members.remove(name));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _lanjut() {
    if (_namaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama sesi tidak boleh kosong')),
      );
      return;
    }
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 anggota')),
      );
      return;
    }

    final ctrl = context.read<AppController>();
    // Add host to members if not already
    final allMembers = [ctrl.hostName, ..._members.where((m) => m != ctrl.hostName)];

    final session = ctrl.createSession(
      name: _namaCtrl.text.trim(),
      date: _selectedDate,
      members: allMembers,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InputPesananScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<AppController>();
    final hostInitial = (ctrl.currentUser?.name ?? 'U')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Input Sesi'),
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
              child: Text(
                hostInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buat Sesi Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Catat pengeluaran bersama dengan mudah.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Session details card
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
                          'NAMA TONGKRONGAN / SESI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _namaCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Makan Nasi Padang',
                            prefixIcon: Icon(Icons.restaurant_menu_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'TANGGAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    color: AppColors.textHint, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Members section
                  const Text(
                    'Pilih Teman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Add member input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _temanCtrl,
                          onSubmitted: (_) => _addMember(),
                          decoration: const InputDecoration(
                            hintText: 'Ketik nama teman...',
                            prefixIcon: Icon(Icons.person_add_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addMember,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Tambah'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Member chips
                  if (_members.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _members
                          .map(
                            (m) => Chip(
                              label: Text(m),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeMember(m),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                    color: AppColors.border),
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _lanjut,
                child: const Text('Lanjut ke Tagihan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
