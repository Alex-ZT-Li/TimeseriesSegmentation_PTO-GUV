%% Crop Condition: Cropping by selected vesicle size
% Notes: Creates single images of individual vesicles of a given size to output folder.
% This outputs the images from the slice used to segment the vesicles.

%Setup
close all
clear all
od = pwd;
cd('Processed_mat')
load('Size_sorted_data.mat')
load('Compiled_data','L_com');
cd(od)

%% Input Conditions Parameters (what to crop)
size = 3;    %Which diameter vesicle to crop
imscale = 4; %image crop scaling factor (for a larger image)

%% Create 
seldir = strcat('Vesicle Crop_',num2str(size),'um');
mkdir(seldir)

%% Cropping selected vesicles
ves_pos = 0;
files = dir('*.tif');
pos_sel = pos_size{size}; 
bbox_sel = boundbox_size{size}; 
num = 1;

for j= 1:max(pos_sel) % For each position
    ves_pos = j;
    filename = files(ves_pos).name;
    imdata = bfopen(filename);
    bbox_sel2 = bbox_sel(pos_sel == j,:);
    size_2 = size;
    ves_overlay = L_com{j};
    
    cd(seldir)
    for k=1:length(bbox_sel2(:,1))
        Y = bbox_sel2(k,:);

        savename2 = strcat(num2str(size),'um_',num2str(j),'pos_',num2str(num),'_Ves_R.tif');
        savename3 = strcat(num2str(size),'um_',num2str(j),'pos_',num2str(num),'_Ves_RO.tif');
        crop = imcrop(([imdata{1,1}{5,1}]),Y);
        crop2 = imcrop(ves_overlay,Y);
        crop = imresize(crop,imscale); %increase size
        crop2 = imresize(crop2,imscale); %increase size
        if ~isempty(crop)
            crop3 = imfuse(imadjust(crop,[0 0.038]),crop2,'blend');
            crop4 = imfuse(crop,crop3,'montage');
            imwrite(crop4,savename2);
        end
        num = num+1;
    end
    cd(od)
end