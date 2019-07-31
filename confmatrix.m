function [TP, FN, FP, precission, recall, F1s] = confmatrix(bboxA,bboxB)
%Ini untuk menghitung confussion matrix
%bboxA = merupakan gambar deteksi yang sudah dilabeli dengan bounding box
%bboxB = merupakan hasil deteksi setelah program deteksi objek dibuat
jumlahbboxA = size(bboxA,1);
jumlahbboxB = size(bboxB,1);
%menghitung ratio kotak-kotak yang overlap
overlapratioLA = bboxOverlapRatio(bboxA,bboxB);
%inisiasi TP FN FP
TP = 0;
FN = 0;
FP = 0;

for i=1 : jumlahbboxA
    M = max(overlapratioLA(i,1:jumlahbboxB));
    if M>0.5
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end

for j=1 : jumlahbboxB
    M = max(overlapratioLA(1:jumlahbboxA,j));
    if M < 0.5
        FP = FP + 1;
    end
end

%perhitungan precision recall
precission = TP/(TP+FP);
recall = TP/(TP+FN);
F1s = 2*((recall*precission)/(recall+precission));
end

