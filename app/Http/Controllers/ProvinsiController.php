<?php

namespace App\Http\Controllers;

use App\Models\Provinsi;
use Illuminate\Http\Request;
use App\Http\Resources\ResponseResources;
use Illuminate\Routing\Controller;
use Illuminate\Validation\Rule; 

class ProvinsiController extends Controller
{
    public function index()
    {
        $provinsi = Provinsi::select('code', 'name')->get();
        return new ResponseResources(true, 'List Data Provinsi', $provinsi);
    }

    public function store(Request $request)
    {
        // Validasi input
        $validated = $request->validate([
            'code' => 'required|string|unique:provinsis,code', 
            'name' => 'required|string',
        ]);

        $provinsi = Provinsi::create($validated);

        // response 201 (create succes)
        return response()->json([
            'status' => true,
            'message' => 'Berhasil Menambahkan data provinsi',
            'data' => $provinsi
        ], 201);
    }

    public function show($code) 
    {
        $provinsi = Provinsi::where('code', $code)->first();

        if (!$provinsi) {
            // response 404 not found
            return response()->json([
                'status' => false,
                'message' => 'Data Provinsi Tidak Ditemukan!',
                'data' => null
            ], 404);
        }

        return new ResponseResources(true, 'Data Provinsi', $provinsi);
    }

    public function update(Request $request, $code)
    {
        $provinsi = Provinsi::where('code', $code)->first();

        if (!$provinsi) {
            // 404
            return response()->json([
                'status' => false,
                'message' => 'Provinsi Tidak Ditemukan',
                'data' => null
            ], 404);
        }

        $validated = $request->validate([
            'code' => ['required', 'string', Rule::unique('provinsis')->ignore($provinsi->id)],
            'name' => 'required|string',
        ]);

        $provinsi->update($validated);

        return new ResponseResources(true, "Berhasil Mengedit Data Provinsi", $provinsi);
    }

    public function destroy($code)
    {
        $provinsi = Provinsi::where('code',$code); 

        if (!$provinsi) {
             // 404 
             return response()->json([
                'status' => false,
                'message' => 'Provinsi Tidak Ditemukan',
                'data' => null
            ], 404);
        }

        $provinsi->delete();
        
        return new ResponseResources(true, "Provinsi Berhasil Dihapus", null);
    }
}