function HOGFt = newHOGFeature180bin9(image,cell_partition)
% Fungsi ini adalah fungsi untuk mengekstrak fitur dengan menggunakan
% metode Histogram of Oriented Gradient

% melakukan partisi cell
[baris, kolom] = size(image);
jumlah_cell = cell_partition; 
cellbaris = baris/jumlah_cell(1);
cellkolom = kolom/jumlah_cell(2);

% Disini jumlah binnya 9
nbins = 9;
feature = [];

% deteksi sobel
hx = [-1 0 1
    -2 0 2
    -1 0 1];
hy = hx';
gx = imfilter(double(image),hx);
gy = imfilter(double(image),hy);

% menghitung magnitude
mag = zeros(baris,kolom);
for i=1:baris
    for j=1:kolom
        mag(i,j)=sqrt(gx(i,j)^2+gy(i,j)^2);
    end
end

% menghitung orientasi
ang=zeros(baris,kolom);
for i=1:1:baris
    for j=1:1:kolom
        ang(i,j)=atand(gy(i,j)/gx(i,j));
        if ang(i,j)<0
            ang(i,j)=ang(i,j)+180;
        end
    end
end

for c=0 : cellbaris : baris-cellbaris
    for d=0 : cellkolom : kolom-cellkolom
        cp_mag = mag(c+1:c+cellbaris,d+1:d+cellkolom);
        cp_ang = ang(c+1:c+cellbaris,d+1:d+cellkolom);
        [baris_cell,kolom_cell]=size(cp_mag);
        
        %histogram voting 20 40 60 80 100 120 140 160 180
        hist=zeros(1,nbins);
        for i=1 : baris_cell
            for j=1 : kolom_cell
                if cp_ang(i,j)>0 && cp_ang(i,j)<=20
                    hist(1)=hist(1)+cp_mag(i,j);
                elseif cp_ang(i,j)>20 && cp_ang(i,j)<=40
                    hist(1)=hist(1)+cp_mag(i,j)*((cp_ang(i,j)-20)/20);
                    hist(2)=hist(2)+cp_mag(i,j)*((40-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>40 && cp_ang(i,j)<=60
                    hist(2)=hist(2)+cp_mag(i,j)*((cp_ang(i,j)-40)/20);
                    hist(3)=hist(3)+cp_mag(i,j)*((60-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>60 && cp_ang(i,j)<=80
                    hist(3)=hist(3)+cp_mag(i,j)*((cp_ang(i,j)-60)/20);
                    hist(4)=hist(4)+cp_mag(i,j)*((80-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>80 && cp_ang(i,j)<=100
                    hist(4)=hist(4)+cp_mag(i,j)*((cp_ang(i,j)-80)/20);
                    hist(5)=hist(5)+cp_mag(i,j)*((100-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>100 && cp_ang(i,j)<=120
                    hist(5)=hist(5)+cp_mag(i,j)*((cp_ang(i,j)-100)/20);
                    hist(6)=hist(6)+cp_mag(i,j)*((120-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>120 && cp_ang(i,j)<=140
                    hist(6)=hist(6)+cp_mag(i,j)*((cp_ang(i,j)-120)/20);
                    hist(7)=hist(7)+cp_mag(i,j)*((140-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>140 && cp_ang(i,j)<=160
                    hist(7)=hist(7)+cp_mag(i,j)*((cp_ang(i,j)-140)/20);
                    hist(8)=hist(8)+cp_mag(i,j)*((160-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>160 && cp_ang(i,j)<=180
                    hist(8)=hist(8)+cp_mag(i,j)*((cp_ang(i,j)-160)/20);
                    hist(9)=hist(9)+cp_mag(i,j)*((180-cp_ang(i,j))/20);
                elseif cp_ang(i,j)>180
                    hist(9)=hist(9)+cp_mag(i,j);
                end
            end
        end
        % melakukan normalisasi pada histogram
        hist=hist/(sqrt(norm(hist)^2+0.1));
        feature=[feature hist];
    end
end
HOGFt = feature;
end


