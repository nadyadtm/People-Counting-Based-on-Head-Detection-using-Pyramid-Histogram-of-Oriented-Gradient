function PHOGFt = PHOGFeature(image,lv)
% Fungsi untuk mengekstrak fitur dengan metode Pyramid Histogram of
% Oriented Gradient
% image = citra yang sudah digrayscale dan diresize agar dapat dibagi
% cellnya
% lv = level HOG
PHOGftr=[];
% mengambil fitur HOG dari setiap level, dimana pada setiap level cell akan
% dibagi menjadi 2^l x 2^l
for i=0 : lv
    ftr = newHOGFeature180bin9(image,[2^i,2^i]);
    PHOGftr = [PHOGftr ftr];
end
PHOGFt=PHOGftr;
end

