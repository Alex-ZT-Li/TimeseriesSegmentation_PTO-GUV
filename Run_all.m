%% Run_all.m: Image Processing for Timeseries Experiments (PTO-GUVs).

% Notes: This code runs the entire processing chain.

run SegmentObjects_Clock.m
run SelectObjects_Clock.m
run GenerateMontageSelected.m
run Compile_Data.m
run Filter_Ves.m
run SortbySize.m

%% Optional
% run GenerateMontageSegmented.m %Optional: if you want to check segmentation quality.

% run Crop_condition.m        %Optional: if you want crops of individual vesicles (single slice). Allows cropping by specified conditions.

% run Crop_condition_full.m   %Optional: if you want crops of individual vesicles (full timeseries). Allows cropping by specified conditions.