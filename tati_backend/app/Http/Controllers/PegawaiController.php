<?php

namespace App\Http\Controllers;

use App\Models\Pegawai;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PegawaiController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        $pegawai = $user->pegawai;
        $role = $user->role->nama_role;

        if ($role === 'Kepala Dinas') {
            // Kadis bisa melihat semua pegawai untuk monitoring
            $data = Pegawai::with('user.role')->get();
        
        } elseif ($role === 'Kepala Bidang') {
           
            $data = Pegawai::where('atasan_id', $pegawai->id)
                    ->orWhere('id', $pegawai->id) 
                    ->with('user.role')
                    ->get();
                    
        } else {
            // Staff hanya melihat diri sendiri
            $data = Pegawai::where('id', $pegawai->id)->with('user.role')->get();
        }

        return response()->json(['data' => $data]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required',
            'jabatan' => 'required',
            'atasan_id' => 'nullable|exists:pegawais,id',
        ]);

        $pegawai = Pegawai::create($request->only([ 'nama', 'jabatan', 'atasan_id']));
        return response()->json(['message' => 'Pegawai berhasil dibuat', 'data' => $pegawai]);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $pegawai = Pegawai::with('user')->find($id);
        if (!$pegawai) {
            return response()->json(['message' => 'Pegawai tidak ditemukan'], 404);
        }
        return response()->json(['data' => $pegawai]);
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $pegawai = Pegawai::find($id);
        if (!$pegawai) {
            return response()->json(['message' => 'Pegawai tidak ditemukan'], 404);
        }

        $request->validate([
            'nama' => 'sometimes|required',
            'jabatan' => 'sometimes|required',
            'atasan_id' => 'nullable|exists:pegawais,id',
        ]);

        $pegawai->update($request->only(['nama', 'jabatan', 'atasan_id']));
        return response()->json(['message' => 'Pegawai diperbarui', 'data' => $pegawai]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $pegawai = Pegawai::find($id);
        if(!$pegawai){
            return response()->json(['message' => 'Pegawai tidak ditemukan'], 404);
        }
        $pegawai->delete();
        return response()->json(['message' => 'Pegawai dihapus']);
    }
}
