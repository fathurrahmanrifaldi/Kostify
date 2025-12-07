import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/kamar_provider.dart';
import '../../../utils/helpers.dart';
import 'kamar_form_screen.dart';
import 'kamar_detail_screen.dart';

class KamarListScreen extends StatefulWidget {
  const KamarListScreen({super.key});

  @override
  State<KamarListScreen> createState() => _KamarListScreenState();
}

class _KamarListScreenState extends State<KamarListScreen> {
  String? _selectedStatus;
  String? _selectedTipe;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    await kamarProvider.fetchKamars(
      status: _selectedStatus,
      tipe: _selectedTipe,
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Kamar',
      message: 'Yakin ingin menghapus kamar ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    final success = await kamarProvider.deleteKamar(id);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Kamar berhasil dihapus');
      _loadData();
    } else {
      Helpers.showSnackBar(
        context,
        kamarProvider.errorMessage ?? 'Gagal menghapus kamar',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kamar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Tersedia'),
                      selected: _selectedStatus == 'tersedia',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'tersedia' : null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Terisi'),
                      selected: _selectedStatus == 'terisi',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'terisi' : null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Filter Tipe:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _selectedTipe == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTipe = null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Single'),
                      selected: _selectedTipe == 'single',
                      onSelected: (selected) {
                        setState(() {
                          _selectedTipe = selected ? 'single' : null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Double'),
                      selected: _selectedTipe == 'double',
                      onSelected: (selected) {
                        setState(() {
                          _selectedTipe = selected ? 'double' : null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Kamar
          Expanded(
            child: Consumer<KamarProvider>(
              builder: (context, kamarProvider, _) {
                if (kamarProvider.isLoading && kamarProvider.kamars.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (kamarProvider.kamars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada kamar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    itemCount: kamarProvider.kamars.length,
                    itemBuilder: (context, index) {
                      final kamar = kamarProvider.kamars[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    KamarDetailScreen(kamarId: kamar.id),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.bed,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Kamar ${kamar.nomorKamar}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: kamar.tipe == 'single'
                                                      ? Colors.blue
                                                          .withOpacity(0.1)
                                                      : Colors.purple
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  Helpers.capitalize(kamar.tipe),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: kamar.tipe == 'single'
                                                        ? Colors.blue
                                                        : Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            Helpers.formatCurrency(
                                                kamar.hargaBulanan),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Helpers.getStatusColor(
                                            kamar.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        Helpers.capitalize(kamar.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (kamar.fasilitas != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          kamar.fasilitas!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (kamar.user != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Penyewa: ${kamar.user!.nama}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => KamarFormScreen(
                                              kamar: kamar,
                                            ),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _handleDelete(kamar.id),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Hapus'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KamarFormScreen()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
      ),
    );
  }
}