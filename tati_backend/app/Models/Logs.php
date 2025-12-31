<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Logs extends Model
{
    protected $fillable = [
        'pegawai_id',
        'tanggal',
        'aktivitas',
        'status',
        'catatan',
    ];

    protected $table = 'logs';
    protected $guarded = [];

    public function pegawai()
    {
        return $this->belongsTo(Pegawai::class, 'pegawai_id');
    }
}
