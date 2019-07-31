tic;
%% Read Video
v=VideoReader('.\File Testing\Data Video\11.MP4');
% Ambil Background
background = rgb2gray(read(v,1));

%% load anotasi kepala
% Load anotasi dengan nama file yang sama dengan nama videonya
truehead = load('.\File Testing\Anotasi\11.mat');
labelbboxes = truehead.gTruth.LabelData.head;

%% load model svm
SVMModel = loadCompactModel('SVMhead');

%% Load daerah pergeseran window
groundtruth=load('ROIKursi6.mat');
daerah=[];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah{1}]; 
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah2{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah3{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah4{1}];


frameke={};
jmlprecission = 0;
jmlrecall = 0;
jmlF1Score = 0;
jmlframe = 0;
jmlframe1 = 0;
PerformanceTable=[];
AllInformation=[];

%% Proses ke video keseluruhan
for frame=1 : 10 : v.numberOfFrames
    vidbboxes = labelbboxes{frame};
    vid = read(v,frame);
    
    %background subtraction threshold
    thisFrame = rgb2gray(vid);
    Difference = abs(double(thisFrame)-double(background));
    out = uint8(Difference);
    hasil = Difference > 25;
    FilteredImage = medfilt2(hasil,[9 9]);
    FilteredImage = bwmorph(FilteredImage, 'bridge', 'Inf');
    FilteredImage = imfill(FilteredImage, 'holes');
    FilteredImage = bwmorph(FilteredImage, 'dilate',4);
    imglabel = bwlabel(FilteredImage);
    
    %menandai daerah foreground yang terdeteksi
    stats = regionprops(imglabel,'BoundingBox','Area');
    [row, col] = size(stats);
    
    %mengambil daerah foreground yang luasnya lebih dari 1000
    kump_daerah={};
    for j=1:row
        if(stats(j).Area>1000)
            kump_daerah=[kump_daerah stats(j)];
        end
    end
    
    bbox=[];
    bbbox=[];
    scoreall=[];
    feature=[];
    %Melakukan sliding window pada daerah foreground
    for i=1 : length(kump_daerah)
        width=floor(kump_daerah{i}.BoundingBox(1));
        height=floor(kump_daerah{i}.BoundingBox(2));
        width1 = width-1+kump_daerah{i}.BoundingBox(3);
        height1 = height-1+kump_daerah{i}.BoundingBox(4);
        %inisiasi window awal pada daerah tersebut
        if height>=daerah(1,2)
            window_size = [40,50];
        elseif height>=daerah(2,2)
            window_size = [28,35];
        elseif height>=daerah(3,2)
            window_size = [20,25];
        elseif height>=daerah(4,2)
            window_size = [16,20];
        else
            continue;
        end
        %Proses Sliding Window
        for ht=height:2:height1-window_size(1)
            for wt=width:window_size(1)/4:width1-window_size(2)
                wdw = [wt ht window_size(1) window_size(2)];
                % mengambil gambar
                image = imcrop(thisFrame,wdw);
                % melihat intensitas nilai pixel 1, jika rata-ratanya lebih
                % dari 0,3 maka akan dilakukan ekstraksi ciri dan prediksi
                % kelas
                image_diff = imcrop(FilteredImage,wdw);
                avg_intensity=mean2(image_diff);
                if avg_intensity>0.3
                    % Melakukan ekstraksi ciri
                    im = imresize(image,[40,32]);
                    im = [im;zeros(8,32)];
                    PHOGftr=PHOGFeature(im,2);
%                     PHOGftr = newHOGFeature180bin9(im,[2,2]);
                    % Melakukan prediksi kelas
                    [label,score]=predict(SVMModel,PHOGftr);
                    % bila termasuk kepala maka
                    if label==1
                        % simpan fitur dan nilai svm
                        bbox=[bbox ;[wt ht window_size(1) window_size(2)]];
                        bbbox=[bbbox ;[wt ht window_size(1) window_size(2)]];
                        feature=[feature;PHOGftr];
                        scoreall = [scoreall;score(2)];
                    end
                end
            end
            % perubahan ukuran sliding window
            if ht>daerah(1,2)
                window_size = [40,50];
            elseif ht>daerah(2,2)
                window_size = [28,35];
            elseif ht>daerah(3,2)
                window_size = [20,25];
            elseif ht>=daerah(4,2)
                window_size = [16,20];
            end
            if ht>daerah(1,2)+daerah(1,4)-window_size(2)
                break;
            end
        end
    end
    
    imshow(vid);
    hold on;
    % menggambarkan bounding box hasil annotasi
    for i=1 : size(vidbboxes,1)
        vid = insertShape(vid,'Rectangle',vidbboxes(i,1:4),'LineWidth',3,'Color','r');
        rectangle('Position',vidbboxes(i,1:4),...
            'Curvature',[0,0],...
            'EdgeColor','r',...
            'LineWidth',2,...
            'LineStyle','-')
    end
    % menghilangkan kotak overlap dengan cara menggunakan fungsi matlab,
    % yang dimana nantinya memilih kotak yang memiliki nilai klasifikasi
    % terbaik berdasarkan thresholdnya
    if size(bbox,1)>0
        [bbox, selectedScore, index] = selectStrongestBbox(bbox, scoreall,'OverlapThreshold',0.1,'RatioType','Min');
        % menyimpan informasi2 penting
        Ft.NoFrame=frame;
        Ft.bbox=bbox;
        Ft.selectedScore=selectedScore;
        Ft.feature=feature(index,:);
        AllInformation=[AllInformation;Ft];
    else
        Ft.NoFrame=frame;
        Ft.bbox=bbox;
        Ft.selectedScore=[];
        Ft.feature=[];
        AllInformation=[AllInformation;Ft];
    end
    %menggambar hasil deteksi
    for i=1 : size(bbox,1)
        vid = insertShape(vid,'Rectangle',bbox(i,1:4),'LineWidth',3,'Color','g');
        rectangle('Position',bbox(i,1:4),...
            'Curvature',[0,0],...
            'EdgeColor','g',...
            'LineWidth',2,...
            'LineStyle','-')
    end
    pause(0.00001);
    
    % Hitung performansi pakai confussion matrix
    TP = 0;
    FN = 0;
    FP = 0;
    precission = 0;
    recall = 0;
    F1Score = 0;
    if size(bbox,1)>0 && size(vidbboxes,1)>0
        [TP, FN, FP, precission, recall, F1Score]=confmatrix(vidbboxes,bbox);
        Perf.second      = (frame-1)/10;
        Perf.precision   = precission;
        Perf.recall      = recall;
        Perf.F1Score     = F1Score;
        PerformanceTable = [PerformanceTable;Perf];
        jmlframe=jmlframe+1;
    end
    
    %menampilkan performansi per-frame
    disp(strcat('Performansi frame ke-',num2str(frame)));
    disp(strcat('TP =',num2str(TP)));
    disp(strcat('FN =',num2str(FN)));
    disp(strcat('FP =',num2str(FP)));
    disp(strcat('precission =',num2str(precission)));
    disp(strcat('recall =',num2str(recall)));
    disp(strcat('F1Score =',num2str(F1Score)));
    jmlprecission = jmlprecission+precission;
    jmlrecall = jmlrecall+recall;
    jmlF1Score = jmlF1Score+F1Score;
    jmlframe1 = jmlframe1 + 1;
    hasilframe{jmlframe1}=vid;
end

%% menghitung rata-rata performansi pada frame
rata2Precission=jmlprecission/(jmlframe);
rata2Recall=jmlrecall/(jmlframe);
rata2F1Score=jmlF1Score/(jmlframe);

disp('Rata-rata Performansi');
disp(strcat('Precision = ',num2str(rata2Precission)));
disp(strcat('Recall = ', num2str(rata2Recall)));
disp(strcat('F1 Score = ',num2str(rata2F1Score)));
toc;