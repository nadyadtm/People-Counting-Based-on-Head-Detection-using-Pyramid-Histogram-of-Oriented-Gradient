function varargout = PeopleCountGUI(varargin)
% PEOPLECOUNTGUI MATLAB code for PeopleCountGUI.fig
%      PEOPLECOUNTGUI, by itself, creates a new PEOPLECOUNTGUI or raises the existing
%      singleton*.
%
%      H = PEOPLECOUNTGUI returns the handle to a new PEOPLECOUNTGUI or the handle to
%      the existing singleton*.
%
%      PEOPLECOUNTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PEOPLECOUNTGUI.M with the given input arguments.
%
%      PEOPLECOUNTGUI('Property','Value',...) creates a new PEOPLECOUNTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PeopleCountGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PeopleCountGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PeopleCountGUI

% Last Modified by GUIDE v2.5 07-May-2019 10:26:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PeopleCountGUI_OpeningFcn, ...
    'gui_OutputFcn',  @PeopleCountGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PeopleCountGUI is made visible.
function PeopleCountGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PeopleCountGUI (see VARARGIN)

% Choose default command line output for PeopleCountGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PeopleCountGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PeopleCountGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadVideoInput.
function LoadVideoInput_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVideoInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mp4','Select Video');
[pathstr,name,ext] = fileparts(FileName);
handles.video = VideoReader([PathName,FileName]);
handles.label = load(strcat('.\File Testing\Anotasi\',name,'.mat'));
handles.detection=load(strcat('.\File Testing\Fitur Hasil Deteksi\',name,'.mat'));
handles.Filename=FileName;
guidata(hObject, handles);
% set(handles.filevideo,'String',handles.Filename);
set(handles.durasi,'String',num2str(floor(handles.video.Duration)));
set(handles.framerate,'String',num2str(floor(handles.video.FrameRate)));
axes(handles.axes1);
imshow(read(handles.video,1));


% --- Executes on button press in prosesseluruhvideo.
function prosesseluruhvideo_Callback(hObject, eventdata, handles)
% hObject    handle to prosesseluruhvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.avgprec,'String',num2str(0));
set(handles.avgrec,'String',num2str(0));
set(handles.avgf1s,'String',num2str(0));
set(handles.jmlManusia,'String',num2str(0));
set(handles.frmke,'String',num2str(0));
labelbboxes = handles.label.gTruth.LabelData.head;
detectedbboxes = handles.detection.AllInformation;

% SVMModel = loadCompactModel('SVMface.mat');
% PCAvector = load('PCAvector.mat');
% PCArata2 = load('PCArata2.mat');

background = rgb2gray(read(handles.video,1));

groundtruth=load('ROIKursi6.mat');
daerah=[];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah2{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah3{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah4{1}];

jmlprecission = 0;
jmlrecall = 0;
jmlF1Score = 0;
jmlframe = 0;
for frame=1 : 10 : handles.video.numberOfFrames
    vidbboxes = labelbboxes{frame};
    detects=detectedbboxes(find(arrayfun(@(s) ismember(frame, s.NoFrame), detectedbboxes)));
    vid=read(handles.video,frame);
    thisFrame = rgb2gray(vid);
    Difference = abs(double(thisFrame)-double(background));
    out = uint8(Difference);
    hasil = Difference > 25;
    FilteredImage = medfilt2(hasil,[9 9]);
    FilteredImage = bwmorph(FilteredImage, 'bridge', 'Inf');
    FilteredImage = imfill(FilteredImage, 'holes');
    FilteredImage = bwmorph(FilteredImage, 'dilate',4);
    
    TP = 0;
    FN = 0;
    FP = 0;
    precission = 0;
    recall = 0;
    F1Score= 0;
    if size(detects.bbox,1)>0 && size(vidbboxes,1)>0
        [TP, FN, FP, precission, recall, F1Score]=confmatrix(vidbboxes,detects.bbox);
        jmlframe=jmlframe+1;
    end
     
    axes(handles.hsldetect);
    imshow(vid);
    hold on;
    for i=1 : size(vidbboxes,1)
        rectangle('Position',vidbboxes(i,1:4),...
            'Curvature',[0,0],...
            'EdgeColor','r',...
            'LineWidth',2,...
            'LineStyle','-')
    end
    for i=1 : size(detects.bbox,1)
        rectangle('Position',detects.bbox(i,1:4),...
            'Curvature',[0,0],...
            'EdgeColor','g',...
            'LineWidth',2,...
            'LineStyle','-')
    end
     
    axes(handles.bkgsub);
    imshow(FilteredImage);
    
%     axes(handles.annotate);
%     imshow(vid);
%     hold on;
%     for i=1 : size(vidbboxes,1)
%         rectangle('Position',vidbboxes(i,1:4),...
%             'Curvature',[0,0],...
%             'EdgeColor','r',...
%             'LineWidth',2,...
%             'LineStyle','-')
%     end
    
    set(handles.jmlManusia,'String',num2str(TP));
    set(handles.frmke,'String',num2str(frame));
    set(handles.TP,'String',num2str(TP));
    set(handles.FN,'String',num2str(FN));
    set(handles.FP,'String',num2str(FP));
    set(handles.precision,'String',num2str(round(precission,5)));
    set(handles.recall,'String',num2str(round(recall,5)));
    set(handles.f1s,'String',num2str(round(F1Score,5)));
    
    pause(1);

    jmlprecission = jmlprecission+precission;
    jmlrecall = jmlrecall+recall;
    jmlF1Score = jmlF1Score+F1Score;
end

rata2Precission=jmlprecission/(jmlframe);
rata2Recall=jmlrecall/(jmlframe);
rata2F1Score=jmlF1Score/(jmlframe);

set(handles.avgprec,'String',num2str(rata2Precission));
set(handles.avgrec,'String',num2str(rata2Recall));
set(handles.avgf1s,'String',num2str(rata2F1Score));


% --- Executes on button press in ambil1frame.
function ambil1frame_Callback(hObject, eventdata, handles)
% hObject    handle to ambil1frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.avgprec,'String',num2str(0));
set(handles.avgrec,'String',num2str(0));
set(handles.avgf1s,'String',num2str(0));
set(handles.jmlManusia,'String',num2str(0));
set(handles.frmke,'String',num2str(0));

%load daerah sliding Window yang sudah ditentukan
groundtruth=load('ROIKursi6.mat');
daerah=[];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah2{1}];
daerah = [daerah ; groundtruth.gTruth.LabelData.daerah3{1}];

vidbboxes = handles.label.gTruth.LabelData.head;
detectedbboxes = handles.detection.AllInformation;

dtk = str2num(get(handles.detikke, 'String'));
frameke = dtk*10+1;
vid = read(handles.video,frameke);
detects=detectedbboxes(find(arrayfun(@(s) ismember(frameke, s.NoFrame), detectedbboxes)));
thisFrame = rgb2gray(vid);
background = rgb2gray(read(handles.video,1));

Difference = abs(double(thisFrame)-double(background));
out = uint8(Difference);
hasil = Difference > 25;
FilteredImage = medfilt2(hasil,[9 9]);
FilteredImage = bwmorph(FilteredImage, 'bridge', 'Inf');
FilteredImage = imfill(FilteredImage, 'holes');
FilteredImage = bwmorph(FilteredImage, 'dilate',4);

TP = 0;
FN = 0;
FP = 0;
precission = 0;
recall = 0;
F1Score= 0;
if size(detects.bbox,1)>0 && size(vidbboxes{frameke},1)>0
    [TP, FN, FP, precission, recall, F1Score]=confmatrix(vidbboxes{frameke},detects.bbox);
end

axes(handles.hsldetect);
imshow(vid);
hold on;
for i=1 : size(vidbboxes{frameke},1)
    rectangle('Position',vidbboxes{frameke}(i,1:4),...
        'Curvature',[0,0],...
        'EdgeColor','r',...
        'LineWidth',2,...
        'LineStyle','-')
end
for i=1 : size(detects.bbox,1)
    rectangle('Position',detects.bbox(i,1:4),...
        'Curvature',[0,0],...
        'EdgeColor','g',...
        'LineWidth',2,...
        'LineStyle','-')
end


axes(handles.bkgsub);
imshow(FilteredImage);

set(handles.jmlManusia,'String',num2str(TP));
set(handles.frmke,'String',num2str(frameke));
set(handles.TP,'String',num2str(TP));
set(handles.FN,'String',num2str(FN));
set(handles.FP,'String',num2str(FP));
set(handles.precision,'String',num2str(precission));
set(handles.recall,'String',num2str(recall));
set(handles.f1s,'String',num2str(F1Score));


function detikke_Callback(hObject, eventdata, handles)
% hObject    handle to detikke (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of detikke as text
%        str2double(get(hObject,'String')) returns contents of detikke as a double


% --- Executes during object creation, after setting all properties.
function detikke_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detikke (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
