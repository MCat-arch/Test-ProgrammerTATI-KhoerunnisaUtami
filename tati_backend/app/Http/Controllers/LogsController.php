<?php

namespace App\Http\Controllers;

use App\Models\Logs;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Routing\Controller;
use App\Models\Logs as Log;
class LogsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();

        $logs = $user->pegawai->logHarian()->orderBy('tanggal', 'desc')->get();

        return response()->json(['data'=>$logs]);
    }

    /**
     * Show the form for creating a new resource.
     */

    public function store(Request $request)
    {
        $request->validate([
            'aktivitas'=>'required',
            'tanggal'=>'required|date',
        ]);

        $pegawai = Auth::user()->pegawai;

        $log = $pegawai->logHarian()->create([
            'tanggal'=>$request->tanggal,
            'aktivitas'=>$request->aktivitas,
            'status'=>'pending'

        ]);

        return response()->json(['message' => 'Berhasil', 'data' => $log]);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $log = Logs::find($id);
        if(!$log){
            return response()->json(['message' => 'Log tidak ditemukan'], 404);
        }

        if($log->pegawai_id !== Auth::user()->pegawai->id && $log->pegawai->atasan_id !== Auth::user()->pegawai->id){
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        return response()->json(['data' => $log]);
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {

        $request->validate([
            'aktivitas'=>'required',
            'tanggal'=>'required|date',
        ]);

        $log = Logs::find($id);
                if (!$log) {
            return response()->json(['message' => 'Log tidak ditemukan'], 404);
        }
        // Otorisasi: hanya pemilik
        if ($log->pegawai_id !== Auth::user()->pegawai->id) {
            return response()->json(['message' => 'Akses ditolak'], 403);
        }

        $log->update([
            'tanggal'=>$request->tanggal,
            'aktivitas'=> $request->aktivitas,
        ]);

        return response()->json(['message' => 'Log diperbarui', 'data' => $log]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $log = Logs::find($id);
        if(!$log){
            return response()->json(['message' => 'Id Tidak ditemukan']);
        }
        $log->delete();
         return response()->json(['message' => 'data berhasil di hapus']);
    }

    public function logBawahan()
    {
        $pegawai = Auth::user()->pegawai;

        // Ambil ID semua bawahan
        $bawahanIds = $pegawai->bawahan()->pluck('id');

        // Ambil Logs milik ID tersebut
        $logs = Log::whereIn('pegawai_id', $bawahanIds)
            ->with('pegawai:id,nama,jabatan') 
            ->orderBy('status', 'asc') 
            ->orderBy('tanggal', 'desc')
            ->get();

        return response()->json(['data' => $logs]);
    }

    public function verifikasi(Request $request, $id)
    {
        $request->validate([
        'status' => 'required|in:approved,rejected',
        'catatan' => 'required_if:status,rejected'
    ]);

    $log = Log::findOrFail($id);
    $pegawaiLogin = Auth::user()->pegawai;

    if($log->pegawai->atasan_id !== $pegawaiLogin->id)
    {
        return response()->json(['message' => 'Access Denied : Bukan Atasan user terkait']);
    }

    $log->update([
        'status' => $request->status,
        'catatan' => $request->catatan
    ]);

    return response()->json(['message' => 'Status diperbarui']);
    }
}
