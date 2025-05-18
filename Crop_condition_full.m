%% Crop Condition: Cropping of timeseries by selected vesicle size
% Notes: Creates timeseries images of individiual vesicles of a desired size to a output folder.

% Setup
close all
clear all
od = pwd;
cd('Processed_mat')
load('Size_sorted_data.mat')
load('Compiled_data','L_com');
cd(od)

%% Input Parameter Conditions
size = 10; %Which diameter vesicle to crop

%% Create Directory
seldir = strcat('Vesicle Crop Full_',num2str(size),'um');
mkdir(seldir)

%% Cropping selected vesicles
ves_pos = 0;
files = dir('*.tif');
pos_sel = pos_size{size};
bbox_sel = boundbox_size{size};
num = 1;

for j= 1:max(pos_sel)% For each position
    ves_pos = j;
    filename = files(ves_pos).name;
    imdata = bfopen(filename);
    bbox_sel2 = bbox_sel(pos_sel == j,:);
    ves_overlay = L_com{j};
    
    cd(seldir)
    for k=1:length(bbox_sel2(:,1))
        Y = bbox_sel2(k,:);
        savename = strcat(num2str(size),'um_',num2str(j),'pos_',num2str(k),'_Ves_G.tif');
        for i=2:2:102 %4 cycles
            crop = imcrop(([imdata{1,1}{i,1}]),Y);
            if ~isempty(crop)
                imwrite(crop,savename,'WriteMode','append');
            end
        end
        
        savename2 = strcat(num2str(size),'um_',num2str(j),'pos_',num2str(num),'_Ves_R.tif');

        for i=1:2:101
            crop = imcrop(([imdata{1,1}{i,1}]),Y);
            if ~isempty(crop)
                imwrite(crop,savename2,'WriteMode','append');
            end
        end
        
        num = num+1;

    end
    cd(od)
end