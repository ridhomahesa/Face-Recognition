function varargout = facerecog(varargin)
% FACERECOG MATLAB code for facerecog.fig
%      FACERECOG, by itself, creates a new FACERECOG or raises the existing
%      singleton*.
%
%      H = FACERECOG returns the handle to a new FACERECOG or the handle to
%      the existing singleton*.
%
%      FACERECOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACERECOG.M with the given input arguments.
%
%      FACERECOG('Property','Value',...) creates a new FACERECOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facerecog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facerecog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facerecog

% Last Modified by GUIDE v2.5 02-Feb-2017 18:36:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facerecog_OpeningFcn, ...
                   'gui_OutputFcn',  @facerecog_OutputFcn, ...
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


% --- Executes just before facerecog is made visible.
function facerecog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facerecog (see VARARGIN)

% Choose default command line output for facerecog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(hObject,'center');

% UIWAIT makes facerecog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = facerecog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[nama_file,nama_path] = uigetfile({'*.*'});

if ~isequal(nama_file,0)
    Im = imread(fullfile(nama_path,nama_file));
    axes(handles.axes1)
    imshow(Im)
    handles.Im = Im;
    guidata(hObject,handles)
else
    return
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Im = handles.Im;
facedetector = vision.CascadeObjectDetector('FrontalFaceCART'); 
gray_images = rgb2gray(Im); %Convert RGB Image to Grayscale Image
images_gray = medfilt2(gray_images); %Noise Removal using Median Filter
BB = step(facedetector, images_gray); %Face Detection using Viola Jones Algorithm
    
N = size(BB,1);
handles.N = N;
counter=1;
for i = 1:N
   face = imcrop(images_gray,BB(i,:)); %Cropping based on detected face
end

rect = [80 70 140 175];
crop_face = imcrop(face, rect); %Cropping based on xmin ymin width height

axes(handles.axes2);
imshow(crop_face);

%Statistical Texture Feature Extraction
I3 = double(crop_face);
m = mean(I3(:));
s = skewness(I3(:));
k = kurtosis(I3(:));
e = entropy(crop_face);
%v = var(I3(:));

%GLCM Texture Feature Extraction
GLCM = graycomatrix(crop_face,'Offset',[0 1; -1 1; -1 0; -1 -1]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
contrast = mean(stats.Contrast);
correlation = mean(stats.Correlation);
energy = mean(stats.Energy);
homogeneity = mean(stats.Homogeneity);

%testing
input = [m;s;k;e;contrast;correlation;energy;homogeneity];
load trnfismat.mat
output = round(sim(net,input));

if output == 1
    class = 'Adam';
elseif output == 2
    class = 'Sam';
elseif output == 3
    class = 'Wemdy';
end

set(handles.edit1,'String',class);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
