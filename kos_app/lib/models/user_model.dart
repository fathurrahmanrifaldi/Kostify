// lib/models/user_model.dart

class User {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? noTelepon;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.noTelepon,
    this.createdAt,
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      role: json['role'],
      noTelepon: json['no_telepon'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'no_telepon': noTelepon,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isAdmin => role == 'admin';
  bool get isPenyewa => role == 'penyewa';

  // Copy with
  User copyWith({
    int? id,
    String? nama,
    String? email,
    String? role,
    String? noTelepon,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      noTelepon: noTelepon ?? this.noTelepon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}