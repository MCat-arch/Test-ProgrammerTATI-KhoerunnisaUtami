<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pegawai extends Model
{
    protected $fillable = [
        'nama',
        'jabatan',
        'atasan_id',
    ];

    protected $table = 'pegawais';
    protected $guarded = [];

    public function user()
    {
         return $this->hasOne(User::class, 'pegawai_id');
    }

        // Relasi ke Atasan (Parent)
    public function atasan()
    {
        return $this->belongsTo(Pegawai::class, 'atasan_id');
    }

    // Relasi ke Bawahan (Children)
    public function bawahan()
    {
        return $this->hasMany(Pegawai::class, 'atasan_id');
    }

    // Relasi ke Log
    public function logHarian()
    {
        return $this->hasMany(Logs::class, 'pegawai_id');
    }

        
}
