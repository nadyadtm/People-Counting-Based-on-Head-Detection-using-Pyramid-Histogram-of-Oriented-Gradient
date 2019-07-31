clc;
clear;
%% Load data training dan data validasi
Data_Train=load('.\Dataset\Data_Trainx.mat');
Data_Valid=load('.\Dataset\Data_Valid.mat');

Data_Train=Data_Train.Data_Train;
Data_Valid=Data_Valid.ImgValid;

%% Preprocessing
% Untuk Data Train
Data_Trainpre=[];
for K = 1 : size(Data_Train,1)
  % Preprocessing (terdiri dari grayscale dan resize)
  ImgData.image   = rgb2gray(imresize(Data_Train(K).image,[40 32]));
  % Penambahan padding untuk pembagian cell PHOG
  ImgData.image   = [ImgData.image; zeros(8,32)];
  % Penambahan label
  ImgData.label   = Data_Train(K).label;
  Data_Trainpre=[Data_Trainpre;ImgData];
end

% Untuk Data Validasi
Data_Validpre=[];
for K = 1 : size(Data_Valid,1)
  ImgData.image   = rgb2gray(imresize(Data_Valid(K).image,[40 32]));
  ImgData.image   = [ImgData.image; zeros(8,32)];
  ImgData.label   = Data_Train(K).label;
  Data_Validpre=[Data_Validpre;ImgData];
end

%% Ekstraksi Ciri
% Untuk Data Train
PHOGftrtrain = []
for i = 1 : length(Data_Trainpre)
    % Ekstraksi Ciri PHOG
    ftr = PHOGFeature(Data_Trainpre(i).image,2);
    % Ekstraksi Ciri HOG single level
%     ftr = newHOGFeature180bin9(Data_Trainpre(i).image,[2,2]);
    PHOGftrtrain = [PHOGftrtrain;ftr];
end

% Untuk Data Validasi
PHOGftrvalid = []
for i = 1 : length(Data_Validpre)
    ftr = PHOGFeature(Data_Validpre(i).image,2);
%     ftr = newHOGFeature180bin9(Data_Validpre(i).image,[4,4]);
    PHOGftrvalid = [PHOGftrvalid;ftr];
end

%% Klasifikasi
% Model SVM
kelas = [];
kelas = [kelas;Data_Train.label];

SVMModel = fitcsvm(PHOGftrtrain,kelas,'KernelFunction','Polynomial');
saveCompactModel(SVMModel,'SVMhead');

%% Validasi Model
% Melakukan validasi pada model
kelas = [];
kelas = [kelas;Data_Valid.label];

[label, ~]=predict(SVMModel,PHOGftrvalid);
EVAL = Evaluate(kelas',label);