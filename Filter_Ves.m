%% Filter_Ves.m
% Notes: Filters out vesicles that move out of capatured ROI during
% timeseries. Targets vesicles that detach and float away.

clear all
close all
a = pwd;
cd ('Processed_mat')
load('Compiled_data.mat')
cd (a)

%% Filter by Changes in Mean Intensity of Red Channel
% Removes vesicles that moved out or into ROI
a1=mean(transpose(red_chan)); % Mean red intensity of each vesicle
b1=transpose(red_chan(:,1));
Iratio=a1./b1; % mean/inital ratio for each vesicle
ves_move=transpose(Iratio < 0.7 | Iratio > 1.4);

%% Create filtered dataset
cd(a)
dia_filt = dia(ves_move==0);
encap_filt = encap(ves_move==0,:);
area_filt = area(ves_move==0);
boundbox_filt = boundbox(ves_move==0,:);
red_chan_filt = red_chan(ves_move==0,:);
pos_filt = pos(ves_move==0);
redpixels_filt = redpixels(ves_move==0);
encapcore_filt = encapcore(ves_move==0,:);
shapes_filt = shapes(ves_move == 0,:);

outputFileNameMAT1 = 'Filtered_data.mat';
save(outputFileNameMAT1,'t','Xscale','dia_filt','encap_filt'...
    ,'red_chan_filt','pos_filt','redpixels_filt','bgshapes'...
    ,'ves_move','Iratio','boundbox_filt','encapcore_filt'...
    ,'area_filt','shapes_filt');
movefile(outputFileNameMAT1,strcat(a,'\Processed_mat'));
