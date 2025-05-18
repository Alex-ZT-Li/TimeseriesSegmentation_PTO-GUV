%% SegmentObjects_Clock: Segmentation for timseries images

% Important: Xscale must be manually inputted based on your images in the
% "Input parameters" !!!

% Notes: Segmentation for timeseries images originally for clock (PTO)
% vesicles. Note that this processed .tif files by default (can be changed
% in "Import images".


%% Changelog
% AL: Updated watershed segmentation with h-minima transform and removal of bwconncomp (which canceled out watershed).
% imclearborder moved after segmentation due to issues with uneven membrane intensity causing segmentation issues.
% bwconncomp & eccentricity reforming not necessary with imhmin applied with watershed. bwconncomp essentially had canceled out watershed. 
% Core intensity measurments included

%% RENAME THE FIRST FILE OF THE SERIES TO 1.CZI SO THAT BFOPEN
%% DOES NOT TRY TO RELOAD ALL FILES AT EACH ITERATION
% Input: 	.tif timeseries of vesicles of different positions
% Process:  Performs watershed segmentation on image files

%% Clears all data and close all figure windows.
close all
clear all

%% Input parameters

%% Import images
% Returns list of files with ".tif" extension in the current directory
Xscale = 0.1563;           % !! Must Change to match your images!! x-dim scaling in units of micron/pixel. 
segslice = 5;              % Which slice to perform segmentation on? Default = 5. 

files1 = dir('*.tif');
a=pwd;
mkdir('Segmented_mat')
threshotsu=[];
ntiles = length(files1); 

for k=1:ntiles
    filename = files1(k).name;
    data= bfopen(filename);    %loads file
    omeMeta1 = data{1,4};      %loads metadata

    
    %% Split red and green channels
    red_data = data{1,1}(1:2:length(data{1,1}(:,1)),1);
    green_data = data{1,1}(2:2:length(data{1,1}(:,1)),1);
    red_mat = cat(3,red_data{:});
    green_mat = cat(3,green_data{:});
    
    framecut = length(green_data); %Currently all frames %Last frame to look at: 192 = 4 days

    %% Average slices in green channel 
%     zmean = uint8(mean(red_mat(:,:,1:framecut),3)); %adjusted
    zmean = red_mat(:,:,segslice);

    %% Segmentation
    I = zmean;
    I2 = medfilt2(I,[2 2]); %I; %Filter image to reduce noise
    thresh = multithresh(I2,4); %Adjust thresholding instead of imadjust
    threshotsu{k} = double(thresh(1))/65535;
    I3 = imbinarize(I2,(threshotsu{k})); %'adaptive'); %;%Threshold 
    %I4 = imerode(I3,strel('disk',3));  %Disabled: Erode to remove unconnected noise pixels and nanotubes
    %I4 = imdilate(I4,strel('disk',3)); %Disabled: dilate to restore boundary pixels that have been eroded
    I5 = -bwdist(~I3); 
    I5(~I5) = -Inf;
    I6 = imhmin(I5,2);
    L0 = watershed(I6);
    %FITC = imgaussfilt(FITC,[2 2]);

    %% Region properties
    bgshape = regionprops('table',L0,zmean,'Area');
    bgobj = find(bgshape.Area == max(bgshape.Area)); %Object with largest area is the background
    
    LBG = uint16(L0 == bgobj); %Set background
    L1 = imclearborder(L0); %Remove background connected objects

    shapes = regionprops('table',L1,zmean,'Area','EulerNumber','FilledArea',...
        'Eccentricity','EquivDiameter','Centroid','BoundingBox',...
        'MeanIntensity','PixelValues', 'PixelList', 'Image', 'Perimeter','PixelIdxList');  
    

    %% Apply masks to rest of timeseries 
    greenint=[];
    redint=[];
    bgint=[];
    pxvalue = {};
    green_core = [];
    
    for j = 1:framecut
        greenint= [greenint,regionprops('table',L1, green_mat(:,:,j),'MeanIntensity').MeanIntensity]; %AL added
        redint= [redint,regionprops('table',L1, red_mat(:,:,j), 'MeanIntensity').MeanIntensity];
        bgint = [bgint,regionprops('table',LBG,green_mat(:,:,j),'MeanIntensity').MeanIntensity];
        
        pxvalue{j} = regionprops('table',L1,green_mat(:,:,j),'PixelValues').PixelValues;
    end
    
    
    %% Remove NaNs & <1 micron vesciles from data
    remove = (shapes.EquivDiameter * Xscale)<1;
    SV = cell2mat(shapes.PixelIdxList(remove));
    L1(SV)=0; %Removes NaNs & 1 micorn vesicles from label matrix
    
    shapes = shapes(remove==0,:);
    greenint = greenint(remove==0,:);
    redint = redint(remove==0,:);
    
    %% Measure center of the vesicles
    A = shapes.PixelList;
    B = num2cell(shapes.Centroid,2);
    C = cellfun(@minus,A,B,'UniformOutput',false);
    C1 = ones(size(C))*2;
    C2 = cellfun(@power,C,num2cell(C1),'UniformOutput',false); %Can probably combine these into one function
    C3 = cellfun(@transpose,C2,'UniformOutput',false);
    C3 = cellfun(@sum,C3,'UniformOutput',false);
    C3 = cellfun(@transpose,C3,'UniformOutput',false);
    D = shapes.EquivDiameter * (1/3);
    D1 = cellfun(@le,C3,num2cell(D),'UniformOutput',false); %Which pixels are kept
    
    for i = 1:length(greenint(1,:))
        D2 = pxvalue{i}(remove==0);
        D3 = cellfun(@(D2,D1)D2(D1==1),D2,D1,'UniformOutput',false); %Only keep pixel values close to centroid
        D4 = cellfun(@(x)sum(x)/length(x),D3); %Calculate new mean intensity
        green_core(:,i) = D4;
    end
    
    yimsize = length(data{1,1}{1,1}(:,1));
    ximsize = length(data{1,1}{1,1}(1,:));

    
    %% save variables
    outputFileNameMAT1 = strcat(filename(1:end-4),'.mat');
    save(outputFileNameMAT1,'shapes','greenint','redint','LBG'...
        ,'zmean','Xscale','L1','bgint','yimsize','ximsize','remove'...
        ,'green_core');
    movefile(outputFileNameMAT1,strcat(a,'\Segmented_mat'));
end %end of iteration through k files
