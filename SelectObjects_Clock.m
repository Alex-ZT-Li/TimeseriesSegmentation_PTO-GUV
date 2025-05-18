%% SelectObjects_Clock.m: Selects unilamellar vesicles from segmented objects

% Notes: Uses a intensity-based criteria to select unilamellar vesicles.

close all
clear
mkdir('Selected_mat_all'), 
mkdir('Selected_histogram_all')
a=pwd;
cd Segmented_mat
files2 = dir('*.mat');

edges = 0:0.02:1;
centers = (edges(1:end-1)+edges(2:end))/2;


%% Initialize shape variables for this set
fcount = length(files2);
samples = cell(fcount,1);
L1_all = cell(fcount,1);
i_all = [];
i_norm_all = cell(fcount,1);
shapesall = cell(fcount,1);
greenint_all = cell(fcount,1);
redint_all = cell(fcount,1);
zmaxall = cell(fcount,1);
bgint_all = cell(fcount,1);

%% Collects all data for current Z position
for j=1:length(files2)
    samples{j} = files2(j).name(1:end-4);
    data = open(files2(j).name);
    L1_all{j}=data.L1;
    i_norm = transpose(data.shapes.MeanIntensity./4095);
    i_all = [i_all,i_norm];
    i_norm_all{j} = i_norm;
    Xscale = data.Xscale;
    shapesall{j}=data.shapes;
    zmaxall{j}=data.zmean;
    bgint_all{j} = data.bgint;
    redint_all{j} = data.redint;
    greenint_all{j} = data.greenint;
    greencore_all{j} = data.green_core;
    
end

%% Peak fitting
ydata = histcounts(i_all,edges,'Normalization','probability');
[pks,locs, w, p] = findpeaks(ydata,centers,'MinPeakDistance',0.9,'MinPeakHeight',0.2*max(ydata));
if ~ isempty(locs)
    lb = centers(find(centers<locs(1) & ydata<0.1*pks(1),1,'last'));
    if isempty(lb)
        lb = centers(1);
    end
    ub = locs+(1*w); %0.6; %Adjusting this will make it more or less selective

   %Plot histogram
    h=figure; hold on; axis square; set(h, 'Visible', 'on');
    h=histogram(i_all,edges,'Normalization','probability', 'FaceColor','w');
    findpeaks(ydata,centers,'MinPeakDistance',0.9,'MinPeakHeight',0.2*max(ydata),'Annotate', 'Extents');
    plot([lb lb],[0 1],'b'); plot([ub ub],[0 1],'b');
    legend(strjoin({'peak loc =',num2str(locs)}), strjoin({'width =',num2str(round(w*100)/100)}),...
         strjoin({'lower bound',num2str(round(lb*100)/100)}),strjoin({'upper bound',num2str(round(ub*100)/100)}));
    legend('Location','NorthEast');
    axis([0 1 0 0.2]),title('all images'),xlabel('Intensity'),ylabel('Frequency');
    saveas(gcf,strcat('hist_Z','.png'));
    movefile(strcat('hist_Z','.png'),strcat(a,'/Selected_histogram_all'));
end

if isempty(locs)
    h=figure; hold on; axis square; set(h, 'Visible', 'on');
    h=histogram(i_all,edges,'Normalization','probability', 'FaceColor','w');
    legend('Location','NorthEast');
    axis([0 0.5 0 0.2]),title('No_Peak'),xlabel('Intensity'),ylabel('Frequency');
    saveas(gcf,strcat('hist_','No_Peak','.png'));
    movefile(strcat('hist_','No_Peak','.png'),strcat(a,'/Selected_histogram_all'));
end

%% Choose only vesicles
ves_sel = cell(fcount,1);

for k=1:length(files2)
    if ~ isempty(locs)
        % Choose only vesicles
        ves_sel{k} = (i_norm_all{k} <= ub & i_norm_all{k} >= lb);

        diameter_UV = shapesall{k}.EquivDiameter(ves_sel{k});
        MeanIntensity_UV = shapesall{k}.MeanIntensity(ves_sel{k});
        greenint_UV = greenint_all{k}(ves_sel{k},:); 
        redint_UV = redint_all{k}(ves_sel{k},:);
        V = cell2mat(shapesall{k}.PixelIdxList(ves_sel{k}));
        redpixels_UV = shapesall{k}.PixelValues(ves_sel{k}); %3/17 Al
        boundbox_UV = shapesall{k}.BoundingBox(ves_sel{k},:);
        greencore_UV = greencore_all{k}(ves_sel{k},:);

        % Identify non-vesicles
        NV = cell2mat(shapesall{k}.PixelIdxList(i_norm_all{k} > ub));
        NB = cell2mat(shapesall{k}.PixelIdxList(i_norm_all{k} < lb));
        % Relabel label matrix
        L1_all{k}(NV)=6;
        L1_all{k}(V)=2;
        L1_all{k}(NB)=1;
        
        shapes_UV = shapesall{k}(ves_sel{k},:);
        bgint = bgint_all{k,:};
    end
    
    zmax = zmaxall{k};
    L1 = L1_all{k};

    save(strcat(samples{k},'_selected.mat'),'zmax','L1','shapes_UV','Xscale','diameter_UV','MeanIntensity_UV'...
        ,'redpixels_UV','bgint','ves_sel','greenint_UV','redint_UV','boundbox_UV','greencore_UV');
    movefile(strcat(samples{k},'_selected.mat'),strcat(a,'/Selected_mat_all'));
end

cd ../