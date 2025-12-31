<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Pegawai;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB; 
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    // LOGIN (Public - Tanpa Token)
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::with(['pegawai', 'role'])->where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'data' => [
                'user' => $user,
                // Helper field: true jika role bukan Staff
                'is_atasan' => $user->role->nama_role !== 'Staff', 
            ]
        ]);
    }

    // LOGOUT (Protected - Butuh Token)
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout berhasil']);
    }

    // LIST USER (Protected - Butuh Token)
    public function index()
    {
        $users = User::with(['pegawai', 'role'])->get();
        return response()->json(['data' => $users]);
    }

    // STORE / REGISTER (Protected - Butuh Token Admin/Kadis)
    public function store(Request $request)
    {
        // 1. Validasi Input (User + Pegawai)
        $request->validate([
            // Data Akun
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8',
            'role_id' => 'required|exists:roles,id',
            // Data Pegawai (Wajib diisi saat register)
            'nama' => 'required|string', 
            'jabatan' => 'required|string', 
            'atasan_id' => 'nullable|exists:pegawai,id',
        ]);

        // 2. Database Transaction (Atomicity)
        // Gunakan transaction agar jika insert Pegawai gagal, User juga batal dibuat
        DB::transaction(function () use ($request) {
            

            // Buat Pegawai (Profil)
            $pegawai = Pegawai::create([
               
                'nama' => $request->nama,
                'jabatan' => $request->jabatan,
                'atasan_id' => $request->atasan_id
            ]);

            //  Buat User (Akun)
            User::create([
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role_id' => $request->role_id,
                'pegawai_id'=>$pegawai->id
            ]);
        });

        return response()->json(['message' => 'User & Pegawai berhasil dibuat'], 201);
    }

    // SHOW DETAIL (Protected)
    public function show($id)
    {
        $user = User::with(['pegawai', 'role'])->find($id);
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }
        return response()->json(['data' => $user]);
    }

    // UPDATE (Protected - Butuh Token)
    public function update(Request $request, $id)
    {
        $user = User::find($id);
        
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }

        // Validasi 'sometimes' artinya hanya divalidasi jika field tersebut dikirim
        $request->validate([
            'email' => 'sometimes|email|unique:users,email,' . $id,
            'password' => 'sometimes|min:8',
            'role_id' => 'sometimes|exists:roles,id',
            'nama' => 'sometimes|string',
            'jabatan' => 'sometimes|string',
            'atasan_id' => 'nullable|exists:pegawai,id',
        ]);

        // 1. Update Tabel Users (Akun)
        if ($request->has('email')) $user->email = $request->email;
        if ($request->has('role_id')) $user->role_id = $request->role_id;
        
        // Hanya hash password jika ada input password baru
        if ($request->filled('password')) { 
            $user->password = Hash::make($request->password);
        }
        
        $user->save();

        // 2. Update Tabel Pegawai (Profil)
        // Kita gunakan relasi user->pegawai() untuk update
        if ($user->pegawai) {
             $user->pegawai()->update(
                $request->only(['nama', 'jabatan', 'atasan_id'])
             );
        } else {
            // Jika user lama belum punya data pegawai (Edge Case), buat baru
            $pegawai = Pegawai::create([
                'user_id' => $user->id,
                'nama' => $request->nama ?? 'Tanpa Nama',
                'jabatan' => $request->jabatan ?? 'Staff',
                'atasan_id' => $request->atasan_id
            ]);

            $user->pegawai_id = $pegawai->id;
            $user->save();
        }

        return response()->json([
            'message' => 'Data User diperbarui', 
            'data' => $user->load(['pegawai', 'role'])
        ]);
    }

    // DELETE (Protected)
    public function destroy($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }
        
        // Hapus user otomatis menghapus pegawai (karena onDelete cascade di migration)
        $user->delete();
        
        return response()->json(['message' => 'User berhasil dihapus']);
    }
}