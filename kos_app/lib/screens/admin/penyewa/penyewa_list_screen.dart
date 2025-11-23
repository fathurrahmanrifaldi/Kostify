// lib/screens/admin/penyewa/penyewa_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/helpers.dart';
import 'penyewa_form_screen.dart';
import 'penyewa_detail_screen.dart';

class PenyewaListScreen extends StatefulWidget {
  const PenyewaListScreen({super.key});

  @override
  State<PenyewaListScreen> createState() => _PenyewaListScreenState();
}

class _PenyewaListScreenState extends State<PenyewaListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUsers();
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Penyewa',
      message: 'Yakin ingin menghapus penyewa ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.deleteUser(id);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Penyewa berhasil dihapus');
      _loadData();
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
        title: const Text('Daftar Penyewa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari penyewa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // List Penyewa
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.isLoading && userProvider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = userProvider.users;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) {
                    return user.nama.toLowerCase().contains(_searchQuery) ||
                        user.email.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada penyewa'
                              : 'Penyewa tidak ditemukan',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMD,
                      vertical: AppTheme.spaceSM,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PenyewaDetailScreen(userId: user.id),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceMD),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppTheme.primaryLight,
                                  child: Text(
                                    user.nama.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.nama,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      if (user.noTelepon != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: AppTheme.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              user.noTelepon!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 20, color: AppTheme.errorColor),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hapus',
                                            style: TextStyle(
                                                color: AppTheme.errorColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PenyewaFormScreen(user: user),
                                        ),
                                      ).then((_) => _loadData());
                                    } else if (value == 'delete') {
                                      _handleDelete(user.id);
                                    }
                                  },
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
            MaterialPageRoute(builder: (_) => const PenyewaFormScreen()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Penyewa'),
      ),
    );
  }
}