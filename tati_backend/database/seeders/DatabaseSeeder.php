<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Role;
use App\Models\Pegawai;
use App\Models\Logs;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        DB::transaction(function () {
            $this->command->info('Memulai Seeding Database...');

            // 1. BUAT ROLES
            $roleKadis = Role::create(['nama_role' => 'Kepala Dinas']);
            $roleKabid = Role::create(['nama_role' => 'Kepala Bidang']);
            $roleStaff = Role::create(['nama_role' => 'Staff']);
            
            $password = Hash::make('password123'); // Password seragam biar gampang test

            // 2. LEVEL 1: KEPALA DINAS (Top Level)
            $pegawaiKadis = Pegawai::create([
                // 'user_id' => $userKadis->id,
                'nama' => 'Bapak Kepala Dinas',
                'jabatan' => 'Kepala Dinas',
                'atasan_id' => null, // Tidak punya atasan
            ]);

            $userKadis = User::create([
                'email' => 'kadis@pemda.go.id',
                'password' => $password,
                'role_id' => $roleKadis->id,
                'pegawai_id'=>$pegawaiKadis->id,
            ]);
            
            
            
            $this->command->info('Created: Kepala Dinas');

            // 3. LEVEL 2: KEPALA BIDANG (Bawahan Kadis)
            
            // --- KABID 1 ---
            $pegawaiKabid1 = Pegawai::create([
                'nama' => 'Ibu Kabid Pemerintahan',
                'jabatan' => 'Kepala Bidang 1',
                'atasan_id' => $pegawaiKadis->id, // Atasannya Kadis
            ]);

            $userKabid1 = User::create([
                'email' => 'kabid1@pemda.go.id',
                'password' => $password,
                'role_id' => $roleKabid->id,
                'pegawai_id'=>$pegawaiKabid1->id,
            ]);

            
            // --- KABID 2 ---
            $pegawaiKabid2 = Pegawai::create([
                'nama' => 'Bapak Kabid Pembangunan',
                'jabatan' => 'Kepala Bidang 2',
                'atasan_id' => $pegawaiKadis->id, // Atasannya Kadis
            ]);

            $userKabid2 = User::create([
                'email' => 'kabid2@pemda.go.id',
                'password' => $password,
                'role_id' => $roleKabid->id,
                'pegawai_id'=>$pegawaiKabid2->id,
            ]);
            

            $this->command->info('Created: 2 Kepala Bidang');

            // 4. LEVEL 3: STAFF (Bawahan Kabid)

            // --- STAFF A (Bawahan Kabid 1) ---
             $pegawaiStaffA = Pegawai::create([
                'nama' => 'Andi Staff (Tim Kabid 1)',
                'jabatan' => 'Staff Administrasi',
                'atasan_id' => $pegawaiKabid1->id, // Atasannya Kabid 1
            ]);

            $userStaffA = User::create([
                'email' => 'staff1@pemda.go.id',
                'password' => $password,
                'role_id' => $roleStaff->id,
                'pegawai_id'=>$pegawaiStaffA->id,
            ]);

           

            // --- STAFF B (Bawahan Kabid 2) ---
            $pegawaiStaffB = Pegawai::create([
                'nama' => 'Budi Staff (Tim Kabid 2)',
                'jabatan' => 'Staff Lapangan',
                'atasan_id' => $pegawaiKabid2->id, // Atasannya Kabid 2
            ]);

            $userStaffB = User::create([
                'email' => 'staff2@pemda.go.id',
                'password' => $password,
                'role_id' => $roleStaff->id,
                'pegawai_id' => $pegawaiStaffB->id
            ]);

            

            $this->command->info('Created: 2 Staff');

            // 5. SAMPLE LOG HARIAN (Untuk Testing UI List)

            // Log milik Staff A (Pending - Biar Kabid 1 bisa verifikasi)
            Logs::create([
                'pegawai_id' => $pegawaiStaffA->id,
                'tanggal' => now()->format('Y-m-d'),
                'aktivitas' => 'Membuat laporan rekapitulasi data kecamatan',
                'status' => 'pending',
            ]);

            // Log milik Staff A (Approved - Biar history terlihat)
            Logs::create([
                'pegawai_id' => $pegawaiStaffA->id,
                'tanggal' => now()->subDay()->format('Y-m-d'),
                'aktivitas' => 'Rapat koordinasi via Zoom',
                'status' => 'approved', // Pastikan enum di DB mendukung 'approved' (atau 'disetujui')
            ]);

            // Log milik Kabid 1 (Pending - Biar Kadis bisa verifikasi)
            Logs::create([
                'pegawai_id' => $pegawaiKabid1->id,
                'tanggal' => now()->format('Y-m-d'),
                'aktivitas' => 'Melakukan supervisi ke lapangan',
                'status' => 'pending',
            ]);

            $this->command->info('Seeding Selesai! Data siap digunakan.');
        });
    }
}