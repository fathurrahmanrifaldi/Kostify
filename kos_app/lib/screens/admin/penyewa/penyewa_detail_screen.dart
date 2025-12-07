import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/kamar_model.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/kamar_provider.dart';
import '../../../providers/pembayaran_provider.dart';
import '../../../utils/helpers.dart';
import 'penyewa_form_screen.dart';
import '../kamar/kamar_detail_screen.dart';
import '../pembayaran/pembayaran_list_screen.dart';

class PenyewaDetailScreen extends StatefulWidget {
  final int userId;

  const PenyewaDetailScreen({super.key, required this.userId});

  @override
  State<PenyewaDetailScreen> createState() => _PenyewaDetailScreenState();
}

class _PenyewaDetailScreenState extends State<PenyewaDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    final pembayaranProvider = Provider.of<PembayaranProvider>(
      context,
      listen: false,
    );

    await userProvider.fetchUserById(widget.userId);
    await kamarProvider.fetchKamars();
    await pembayaranProvider.fetchPembayarans();
  }

  Future<void> _handleDelete() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Penyewa',
      message: 'Yakin ingin menghapus penyewa ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.deleteUser(widget.userId);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Penyewa berhasil dihapus');
      Navigator.of(context).pop(true);
    } else {
      Helpers.showSnackBar(
        context,
        userProvider.errorMessage ?? 'Gagal menghapus penyewa',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyewa'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.selectedUser;
              if (user == null) return const SizedBox();

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PenyewaFormScreen(user: user),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _handleDelete,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.selectedUser;
          if (user == null) {
            return const Center(child: Text('Penyewa tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              children: [
                // Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryLight,
                          child: Text(
                            user.nama.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.nama,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.noTelepon != null) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'No Telepon',
                            value: user.noTelepon!,
                          ),
                        ],
                        if (user.createdAt != null) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Bergabung',
                            value: Helpers.formatDate(user.createdAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Tambahan',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const Divider(height: 24),
                        // Kamar yang Ditempati
                        Consumer<KamarProvider>(
                          builder: (context, kamarProvider, _) {
                            // Find kamar for this user
                            final kamarDitempati = kamarProvider.kamars
                                .firstWhere(
                                  (kamar) => kamar.userId == user.id,
                                  orElse: () => Kamar(
                                    id: 0,
                                    nomorKamar: '',
                                    tipe: '',
                                    hargaBulanan: 0,
                                    status: '',
                                  ),
                                );

                            final hasKamar = kamarDitempati.id != 0;

                            return InkWell(
                              onTap: hasKamar
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KamarDetailScreen(
                                            kamarId: kamarDitempati.id,
                                          ),
                                        ),
                                      ).then((_) => _loadData());
                                    }
                                  : null,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.home_work),
                                title: const Text('Kamar yang Ditempati'),
                                subtitle: Text(
                                  hasKamar
                                      ? '${kamarDitempati.nomorKamar} (${kamarDitempati.tipe})'
                                      : 'Belum ada kamar',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        // Riwayat Pembayaran
                        Consumer<PembayaranProvider>(
                          builder: (context, pembayaranProvider, _) {
                            // Filter pembayarans for this user
                            final userPembayarans = pembayaranProvider
                                .pembayarans
                                .where((p) => p.userId == user.id)
                                .toList();

                            return InkWell(
                              onTap: userPembayarans.isNotEmpty
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PembayaranListScreen(),
                                        ),
                                      ).then((_) => _loadData());
                                    }
                                  : null,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.payment),
                                title: const Text('Riwayat Pembayaran'),
                                subtitle: Text(
                                  userPembayarans.isEmpty
                                      ? 'Belum ada pembayaran'
                                      : '${userPembayarans.length} pembayaran',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}