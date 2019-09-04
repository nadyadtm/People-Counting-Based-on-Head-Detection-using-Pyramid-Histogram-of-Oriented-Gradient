# Perhitungan Jumlah Manusia berdasarkan Deteksi Kepala menggunakan Pyramid Histogram of Oriented Gradient

Perhitungan jumlah manusia merupakan sebuah implementasi dari ilmu computer vision, dimana sistem akan mendeteksi kepala dan menghitung jumlah manusia berdasarkan kepala yang berhasil terdeteksi. Pada repositori ini, terdiri dari tiga file yang dapat dijalankan.
1. Skema Training : File tersebut berisi code untuk menjalankan proses training, yaitu melatih sistem dalam mengenali kepala
2. Skema Testing : File tersebut berisi code untuk menjalankan proses testing, yait menguji sistem dalam mendeteksi kepala
3. PeopleCountGUI.fig : File tersebut merupakan aplikasi dalam bentuk GUI yang digunakan untuk menghitung manusia.

Untuk skema training itu sendiri terdiri dari beberapa tahap, yaitu
1. Input Dataset 
Dataset terdiri dari dua kelas, yaitu kelas positif (kepala) dan kelas negatif (non-kepala)
2. Preprocessing
Preprocessing yang digunakan adalah konversi RGB ke grayscale dan resize sebesar 32 x 40
3. Ekstraksi Ciri/Fitur
Ekstraksi Ciri/Fitur yang digunakan adalah PHOG (Pyramid Histogram of Oriented Gradient, yaitu mengambil fitur HOG berdasarkan kedalaman level
4. Klasifikasi
Klasifikasi yang digunakan adalah SVM (Support Vector Machine)

Untuk skema testing itu sendiri terdiri dari beberapa tahap, yaitu
1. Input Video
Video yang diinputkan 
