# Perhitungan Jumlah Manusia berdasarkan Deteksi Kepala menggunakan Pyramid Histogram of Oriented Gradient

Perhitungan jumlah manusia merupakan sebuah implementasi dari ilmu computer vision, dimana sistem akan mendeteksi kepala dan menghitung jumlah manusia berdasarkan kepala yang berhasil terdeteksi. Pada repositori ini, terdiri dari tiga file yang dapat dijalankan.
1. Skema Training : File tersebut berisi code untuk menjalankan proses training, yaitu melatih sistem dalam mengenali kepala
2. Skema Testing : File tersebut berisi code untuk menjalankan proses testing, yait menguji sistem dalam mendeteksi kepala
3. PeopleCountGUI.fig : File tersebut merupakan aplikasi dalam bentuk GUI yang digunakan untuk menghitung manusia.

Untuk skema training itu sendiri terdiri dari beberapa tahap, yaitu
1. Input Dataset 
<br> Dataset terdiri dari dua kelas, yaitu kelas positif (kepala) dan kelas negatif (non-kepala)
2. Preprocessing
<br> Preprocessing yang digunakan adalah konversi RGB ke grayscale dan resize sebesar 32 x 40
3. Ekstraksi Ciri/Fitur
<br> Ekstraksi Ciri/Fitur yang digunakan adalah PHOG (Pyramid Histogram of Oriented Gradient, yaitu mengambil fitur HOG berdasarkan kedalaman level
4. Klasifikasi
<br> Klasifikasi yang digunakan adalah SVM (Support Vector Machine)

Untuk skema testing itu sendiri terdiri dari beberapa tahap, yaitu
1. Input Video
<br> Video yang digunakan adalah video orang yang sedang duduk di ruangan kelas dengan resolusi sekitar 720 x 404 pixel.
2. Background Subtraction
<br> Background subtraction merupakan algoritma yang digunakan untuk mendeteksi benda bergerak (foreground) dengan cara mengurangi background dengan frame lain.
3. Sliding Window
<br> Sliding window merupakan daerah persegi yang bergerak di sekitar citra atau daerah. Setelah didapatkan foreground, window akan begerak di sekitar daerah yang terdeteksi foreground. Setiap langkah window, window akan mengambil potongan citra dan pada potongan citra tersebut akan dilakukan preprocessing, ekstraksi ciri, dan klasifikasi. Bila potongan citra tersebut masuk ke dalam kelas kepala, maka daerah tersebut akan ditandai dengan bounding box.

Hasil deteksi
<img width="900" alt="CaptureGUIPeopleCounting" src="https://user-images.githubusercontent.com/15353477/64316373-d7b28100-cfde-11e9-9c92-f0539efdf2c9.PNG">
