<?php

class LogicTest
{
    public function helloworld($n)
    {
        //array kosong untuk hasil
        $hasil = [];

        // loop standar dari 1 sampai n
        for ($i = 1; $i <= $n; $i++) {
            
            // siapkan variabel string kosong
            $teks = '';

            // Cek kelipatan 4
            if ($i % 4 == 0) {
                $teks .= 'hello'; 
            }

            // cek kelipatan 5
            if ($i % 5 == 0) {
                $teks .= 'world'; 
            }

            // Jika $i adalah 20 (kelipatan 4 dan 5) otomatis teks digabung : helloworld
            
            // Jika $teks selain case diatas, isi angka
            if ($teks == '') {
                $teks = $i; 
            }

            // Masukkan ke array penampung
            $hasil[] = $teks;
        }

        // Ubah array menjadi string panjang dipisahkan spasi
        return implode(' ', $hasil);
    }
}

//==================TEST CASE================
$tes = new LogicTest();
echo $tes->helloworld(6); 
// Output: 1 2 3 hello world 6