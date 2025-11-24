"""
# ===== LANGKAH-LANGKAH SETUP & RUNNING =====

# 1. Pastikan sudah di folder project
cd kos-api

# 2. Copy .env example (jika belum)
cp .env.example .env

# 3. Generate Application Key
php artisan key:generate

# 4. Edit file .env, sesuaikan konfigurasi database:
#    DB_DATABASE=kos_db
#    DB_USERNAME=root
#    DB_PASSWORD= (kosongkan jika tidak ada password)

# 5. Buat database di MySQL/phpMyAdmin dengan nama: kos_db

# 6. Jalankan Migration (buat tabel)
php artisan migrate

# 7. Jalankan Seeder (isi data dummy)
php artisan db:seed

# 8. Clear cache (optional tapi recommended)
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# 9. Jalankan Laravel Server
php artisan serve

# Server akan berjalan di: http://127.0.0.1:8000
# API Base URL: http://127.0.0.1:8000/api


# ===== TESTING DI POSTMAN =====

# Endpoint yang bisa di test:

# 1. REGISTER (POST)
# URL: http://127.0.0.1:8000/api/register
# Body (JSON):
{
    "nama": "Test User",
    "email": "test@gmail.com",
    "password": "password",
    "role": "penyewa",
    "no_telepon": "081234567899"
}

# 2. LOGIN (POST)
# URL: http://127.0.0.1:8000/api/login
# Body (JSON):
{
    "email": "admin@kos.com",
    "password": "password"
}
# Response akan berisi token, copy token tersebut!

# 3. GET PROFILE (GET)
# URL: http://127.0.0.1:8000/api/profile
# Headers:
# Authorization: Bearer {paste_token_disini}
# Accept: application/json

# 4. GET ALL KAMAR (GET)
# URL: http://127.0.0.1:8000/api/kamar
# Headers:
# Authorization: Bearer {paste_token_disini}
# Accept: application/json

# 5. GET KAMAR BY ID (GET)
# URL: http://127.0.0.1:8000/api/kamar/1
# Headers:
# Authorization: Bearer {paste_token_disini}
# Accept: application/json

# 6. CREATE KAMAR (POST) - Admin Only
# URL: http://127.0.0.1:8000/api/kamar
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json
# Body (JSON):
{
    "nomor_kamar": "C02",
    "tipe": "single",
    "harga_bulanan": 750000,
    "status": "tersedia",
    "fasilitas": "AC, WiFi, Kasur"
}

# 7. UPDATE KAMAR (PUT) - Admin Only
# URL: http://127.0.0.1:8000/api/kamar/1
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json
# Body (JSON):
{
    "harga_bulanan": 850000,
    "status": "tersedia"
}

# 8. DELETE KAMAR (DELETE) - Admin Only
# URL: http://127.0.0.1:8000/api/kamar/5
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json

# 9. GET ALL USERS/PENYEWA (GET) - Admin Only
# URL: http://127.0.0.1:8000/api/users
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json

# 10. CREATE USER/PENYEWA (POST) - Admin Only
# URL: http://127.0.0.1:8000/api/users
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json
# Body (JSON):
{
    "nama": "Rina Wati",
    "email": "rina@gmail.com",
    "password": "password",
    "no_telepon": "081234567894"
}

# 11. GET ALL PEMBAYARAN (GET)
# URL: http://127.0.0.1:8000/api/pembayaran
# Headers:
# Authorization: Bearer {paste_token}
# Accept: application/json
# Note: Admin akan lihat semua, Penyewa hanya lihat miliknya

# 12. CREATE PEMBAYARAN (POST) - Admin Only
# URL: http://127.0.0.1:8000/api/pembayaran
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json
# Body (JSON):
{
    "kamar_id": 1,
    "user_id": 2,
    "bulan_pembayaran": 11,
    "tahun_pembayaran": 2025,
    "tanggal_bayar": "2025-11-05",
    "jumlah": 800000,
    "status": "lunas"
}

# 13. UPDATE PEMBAYARAN (PUT) - Admin Only
# URL: http://127.0.0.1:8000/api/pembayaran/1
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json
# Body (JSON):
{
    "status": "lunas",
    "tanggal_bayar": "2025-11-22"
}

# 14. GET STATISTIK KAMAR (GET)
# URL: http://127.0.0.1:8000/api/kamar/statistics/dashboard
# Headers:
# Authorization: Bearer {paste_token}
# Accept: application/json

# 15. GET LAPORAN PEMBAYARAN (GET)
# URL: http://127.0.0.1:8000/api/pembayaran/laporan/dashboard?bulan=11&tahun=2025
# Headers:
# Authorization: Bearer {paste_token_admin}
# Accept: application/json

# 16. LOGOUT (POST)
# URL: http://127.0.0.1:8000/api/logout
# Headers:
# Authorization: Bearer {paste_token}
# Accept: application/json


# ===== AKUN DEFAULT SETELAH SEEDER =====
# Admin:
# Email: admin@kos.com
# Password: password

# Penyewa:
# Email: budi@gmail.com
# Password: password

# Email: siti@gmail.com
# Password: password

# Email: ahmad@gmail.com
# Password: password


# ===== TROUBLESHOOTING =====

# Jika error "Class 'AdminMiddleware' not found":
composer dump-autoload

# Jika error migration:
php artisan migrate:fresh --seed

# Jika error 419 CSRF:
# Pastikan di Postman headers ada:
# Accept: application/json

# Jika error 401 Unauthenticated:
# Pastikan token sudah di set di headers:
# Authorization: Bearer {token}

# Jika error 403 Forbidden:
# Pastikan menggunakan akun admin untuk endpoint yang butuh admin

# Check routes yang tersedia:
php artisan route:list
"""