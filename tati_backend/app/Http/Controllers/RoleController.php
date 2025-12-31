<?php

namespace App\Http\Controllers;

use App\Models\role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $roles = Role::all();
        return response()->json(['data' => $roles]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama_role' => 'required|unique:roles',
        ]);

        $role = Role::create($request->only(['nama_role']));
        return response()->json(['message' => 'Role berhasil dibuat', 'data' => $role]);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $role = Role::find($id);
        if (!$role) {
            return response()->json(['message' => 'Role tidak ditemukan'], 404);
        }
        return response()->json(['data' => $role]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $role = Role::find($id);
        if(!$role){
            return response()->json(['message' => 'Role tidak ditemukan'], 404);
        }

        $request->validate([
            'nama_role' => 'required|unique:roles,nama_role,' . $id,
        ]);

        $role->update($request->only(['nama_role']));
        return response()->json(['message' => 'Role diperbarui', 'data' => $role]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $role = Role::find($id);
        if (!$role) {
            return response()->json(['message' => 'Role tidak ditemukan'], 404);
        }
        $role->delete();
        return response()->json(['message' => 'Role dihapus']);
    }
}
