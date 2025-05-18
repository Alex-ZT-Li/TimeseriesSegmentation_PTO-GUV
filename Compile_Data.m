%% Compiles all segmented/selected mats files.
clear all
close all

%% Input parameters
time_scale = 0.5;    %Input imaging frequency in hours per image.
size = 1;            %Minimum diameter in microns to observe, set to 0 for all. Default = 1 to only compile GUVs.

%% Directory Setup
a=pwd;
mkdir('Processed_mat')
cd 'Selected_mat_all'
files = dir('*.mat');

%% Initalizing variables
dia = [];
encap = [];
boundbox = [];
pos = [];
red_chan = [];
L_com = {};
LBG_com = {};
redpixels = {};
bgshapes = [];
encap_mbg = [];
area = [];
greenpixels = {};
encapcore = [];
shapes = [];

%% Compile Data
for k=1:length(files)
    filename{k,1} = files(k).name;
    data =      open(filename{k});
    Xscale =    data.Xscale;
    dia =   vertcat(dia, data.shapes_UV.EquivDiameter .* Xscale);
    encap = vertcat(encap, data.greenint_UV);
    encapcore = vertcat(encapcore, data.greencore_UV);
    area =  vertcat(area, data.shapes_UV.Area .* Xscale^2); %In micron^2
    red_chan = vertcat(red_chan, data.redint_UV);
    L_com = vertcat(L_com, data.L1);
    pos = vertcat(pos,k.* ones(length(data.shapes_UV.EquivDiameter),1));
    redpixels = vertcat(redpixels, data.shapes_UV.PixelValues);
    bgshapes = vertcat(bgshapes, data.bgint);
    boundbox = vertcat(boundbox, data.boundbox_UV);
    shapes = vertcat(shapes,data.shapes_UV);
end

cd(a)
t = 0:2:(length(encap(1,:))-1)*2;

%% Save Files
outputFileNameMAT1 = 'Compiled_data.mat';
save(outputFileNameMAT1,'t','Xscale','dia','encap','area','red_chan','L_com'...
    ,'pos','redpixels','bgshapes','boundbox','encapcore','shapes');
movefile(outputFileNameMAT1,strcat(a,'\Processed_mat'));