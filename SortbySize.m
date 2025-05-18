%% Sort vesicle by size
clear all
close all

a = pwd;
cd ('Processed_mat')
load('Filtered_data.mat')

%% Initalize Variables
dia_size = {};
encap_size = {};
area_size = {};
red_chan_size= {};
pos_size = {};
redpixels_size = {};
boundbox_size = {};
encapcore_size = {};
shapes_size = {};

bin = discretize(dia_filt,0.5:1:max(dia_filt)+1);

%% Sort Filtered Variables by Size Bin
for i=1:max(bin)
    dia_size{i} = dia_filt(bin==i);
    encap_size{i} = encap_filt(bin==i,:);
    area_size{i} = area_filt(bin==i); %Area is in um^2
    red_chan_size{i} = red_chan_filt(bin==i,:);
    pos_size{i} = pos_filt(bin==i);
    redpixels_size{i} = redpixels_filt(bin==i);
    boundbox_size{i} = boundbox_filt(bin==i,:);
    encapcore_size{i} = encapcore_filt(bin==i,:); 
    shapes_size{i} = shapes_filt(bin==i,:);
end

outputFileNameMAT1 = 'Size_sorted_data';
save(outputFileNameMAT1,'t','Xscale','dia_size','encap_size','area_size'...
    ,'red_chan_size','pos_size','redpixels_size','bgshapes','ves_move'...
    ,'boundbox_size','encapcore_size','shapes_size'); 

cd(a)
