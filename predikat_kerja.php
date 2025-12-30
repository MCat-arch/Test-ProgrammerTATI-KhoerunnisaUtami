<?php

class PerformanceEvaluator
{
    public function predikat_kinerja(string $hasil_kerja, string $perilaku)
    {
        // Normalisasi Input)
        $hasil_kerja = $this->normalisasiInput($hasil_kerja);
        $perilaku    = $this->normalisasiInput($perilaku);

        // Matriks Logika 
        $matrix = [
            'Sangat Baik',     'Baik',            'Kurang/misconduct',
            'Baik',            'Baik',            'Kurang/misconduct',
            'Butuh perbaikan', 'Butuh perbaikan', 'Sangat Kurang',
        ];

        // Eksekusi Pengecekan (ambil data array : (row * width + column))
        return $matrix[($hasil_kerja *3) + $perilaku] ?? 'Invalid Input';
    }

    /**
     * Helper untuk membersihkan input string.
     */
    private function normalisasiInput($input): int
    {
        $input = strtolower(trim($input));

        //normalisasi to index
        
        if (str_contains($input, 'diatas')) {
            return 0;
        }else if(str_contains($input, 'sesuai')) {
            return 1;
        }else if (str_contains($input, 'dibawah')) {
            return 2;
        }else {
            throw new Exception("Input tidak valid: " . $input);
        };
    }
        
}

//==================TEST CASE================

$evaluator = new PerformanceEvaluator();

// Test Case 1 
$hasil1 = 'diatas ekspektasi';
$perilaku1 = 'diatas ekspektasi';
echo "Test : " . $evaluator->predikat_kinerja($hasil1, $perilaku1) . "\n"; 
// Output: Sangat Baik

?>