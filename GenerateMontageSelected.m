%% GenerateMontageSelected: 
% Notes: Use to create labelmatrix montage for checking selection quality.


close all, clear
mkdir('Selected_montage')
c=pwd;
cd 'Selected_mat_all'
files2 = dir('*.mat');


for k=1:length(files2)
    samples = files2(k).name(1:end-4);
    data = open(files2(k).name);
    mask = label2rgb(data.L1,'hot',[0 0 0]);
    D = imfuse(data.zmax,mask,'blend');
    D1 = insertText(D,data.shapes_UV.Centroid,round(data.shapes_UV.EquivDiameter*data.Xscale),'FontSize',16,...
          'TextColor','white','BoxOpacity',0,'AnchorPoint','RightCenter');
    E = imfuse(data.zmax,D1,'montage');
    imwrite(E,strcat(samples,'.png'),'compression','lzw');
    movefile(strcat(samples,'.png'),strcat(c,'\Selected_montage'));
    
end

cd ../
