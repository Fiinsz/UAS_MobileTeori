# Panduan Sistem Verifikasi User

## Fitur yang Ditambahkan

Sistem verifikasi admin untuk pendaftaran user baru telah berhasil diimplementasikan.

## Cara Kerja

### 1. Pendaftaran User Baru
- User mendaftar dengan role "Wali Santri" melalui halaman Register
- Akun dibuat dengan status **"pending"** (menunggu persetujuan)
- User diarahkan ke halaman "Pending Approval" dan tidak dapat mengakses aplikasi
- User hanya bisa logout dari halaman tersebut

### 2. Login User
- User yang **belum disetujui** tidak dapat login
- Muncul pesan: *"Akun Anda masih menunggu persetujuan admin"*
- User yang **ditolak** mendapat pesan: *"Akun Anda ditolak oleh admin"*
- User yang **disetujui** dapat login normal sesuai role-nya

### 3. Persetujuan Admin

#### Akses Menu
1. Login sebagai Admin
2. Pilih menu **"Kelola Akun"**

#### Filter Status
- **Semua**: Tampilkan semua user
- **Pending**: User menunggu persetujuan (warna orange)
- **Disetujui**: User yang sudah disetujui (warna hijau)
- **Ditolak**: User yang ditolak (warna merah)

#### Aksi Admin
- **Setujui**: Mengubah status user menjadi "approved" → user bisa login
- **Tolak**: Mengubah status user menjadi "rejected" → user tidak bisa login
- **Setujui Kembali**: Untuk user yang sudah ditolak, bisa disetujui kembali
- **Edit**: Mengubah data user (nama, email, role)
- **Hapus**: Menghapus user dari sistem

#### Notifikasi Pending
- Banner orange muncul jika ada user pending
- Menampilkan jumlah user yang menunggu persetujuan
- User pending ditampilkan paling atas

## Migrasi User Lama

### Auto-Migrasi saat Login
User lama yang sudah ada sebelum sistem verifikasi akan **otomatis dimigrasi** saat login pertama kali:
- Status diset menjadi "approved"
- User dapat login tanpa hambatan
- Tidak perlu approval manual admin

### Migrasi Manual (Opsional)
Admin dapat melakukan migrasi manual semua user sekaligus:
1. Buka menu **"Kelola Akun"**
2. Klik icon **⋮** (titik tiga) di kanan atas
3. Pilih **"Migrasi User Lama"**
4. Konfirmasi → Semua user lama akan disetujui otomatis

## Special Case: Admin Account

- Akun dengan role **"admin"** selalu **auto-approved**
- Admin tidak perlu menunggu persetujuan
- Admin tidak pernah di-block saat login
- User yang diubah menjadi admin akan otomatis disetujui

## Struktur Data Firestore

Setiap user di collection `users` memiliki field:

```javascript
{
  email: "user@example.com",
  role: "wali" | "ustadz" | "admin",
  displayName: "Nama User",
  createdAt: Timestamp,
  
  // Field Approval (baru)
  isApproved: true/false,
  status: "pending" | "approved" | "rejected",
  approvedBy: "uid_admin",  // UID admin yang approve
  approvedAt: Timestamp      // Waktu approval
}
```

## Testing

### Test 1: Registrasi Baru
1. Logout dari aplikasi
2. Klik "Daftar Akun"
3. Isi data dan submit
4. **Hasil**: Muncul halaman "Akun Anda Sedang Diverifikasi"

### Test 2: Login User Pending
1. Logout dari halaman pending
2. Coba login dengan akun yang baru didaftarkan
3. **Hasil**: Error "Akun masih menunggu persetujuan admin"

### Test 3: Approval Admin
1. Login sebagai admin
2. Buka "Kelola Akun"
3. Lihat user dengan badge orange "Menunggu"
4. Klik tombol "Setujui"
5. **Hasil**: User berubah status menjadi "Disetujui" (hijau)

### Test 4: Login User Approved
1. Logout dari admin
2. Login dengan user yang sudah disetujui
3. **Hasil**: Berhasil masuk ke aplikasi sesuai role

### Test 5: User Lama
1. Login dengan akun admin/user yang sudah ada sebelumnya
2. **Hasil**: Berhasil login (auto-migrasi di background)
3. Cek di "Kelola Akun" → Status user menjadi "approved"

## Tips

1. **Notifikasi Pending**: Selalu cek banner orange di halaman Kelola Akun
2. **Filter**: Gunakan filter "Pending" untuk fokus pada user yang perlu diproses
3. **Rejected Users**: User yang ditolak tetap ada di database, bisa disetujui kembali kapan saja
4. **Delete**: Gunakan hapus jika ingin benar-benar menghilangkan user dari sistem
5. **Admin Creation**: User yang dibuat langsung oleh admin otomatis disetujui

## Troubleshooting

### User lama tidak bisa login
**Solusi**: Login sekali akan auto-migrasi, atau gunakan fitur "Migrasi User Lama" di menu admin

### User pending tidak muncul di list
**Solusi**: Gunakan filter "Pending" atau "Semua" untuk melihat semua user

### Admin tidak bisa login
**Solusi**: Admin selalu bisa login, periksa email/password atau koneksi Firebase

## File yang Dimodifikasi

1. `lib/features/auth/providers/auth_provider.dart` - Logic login & registrasi
2. `lib/features/auth/presentation/register_page.dart` - Redirect ke pending page
3. `lib/features/auth/presentation/pending_approval_page.dart` - Halaman waiting (baru)
4. `lib/features/admin/presentation/admin_users_page.dart` - UI approval admin
5. `lib/main.dart` - Route pending approval

---

**Catatan**: Sistem ini menggunakan Firebase Authentication & Firestore. Pastikan koneksi internet aktif saat testing.
