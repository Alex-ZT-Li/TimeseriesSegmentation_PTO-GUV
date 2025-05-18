# PTO-GUV_TimeseriesSegmentation

Authors: Alexander Zhan Tu Li and Anand Bala Subramaniam

## Description
Performs image segmentation to analyze giant unilamellar vesicles (GUVs) over time on multchannel timeseries images. Designed to obtain circadian clock data on GUVs encapsulated with a post-translational oscillator (PTO). Tracks the circadian clock signal through changes in fluoresence intensity overtime. This code requires timeseries files that are already aligned, instructions on alignment using ImageJ/Fiji are provided below. 

## Requirements:

Code requires MATLAB version R2021a or greater with packages:
- (1 of 6) Bio-Formats Plugin for MATLAB, version 5.3.4 or greater (External plugin from Open Microscopy Environment)
- (2 of 6) Image Processing Toolbox, version 11.3 or greater
- (3 of 6) Curve Fitting Toolbox, version 3.5.13 or greater
- (4 of 6) Signal Processing Toolbox, version 8.6 or greater
- (5 of 6) Statistics and Machine Learning Toolbox, version 12.1 or greater.
- (6 of 6) Computer Vision Toolbox, version 10.0 or greater.

(Tested on MATLAB version R2021a and Windows 10 & 11 Build 26100)

## Instructions

1. All timeseries files must first be aligned using MultiStackReg plugin with the “Translation” algorithm in ImageJ or FIJI to align the images. This the image must be cropped so the empty black regions created due to the translation of the image during alignment are removed for ALL slices. Save the new aligned and cropped images as .tif images.

2. Place all .m files (10 total) in the same folders with the .tif image files.

    ```
    File List:
    1. Run_All.m
    2. SegmentObjects_Clock.m
    3. SelectObjects_Clock.m
    4. GenerateMontageSelected.m
    5. Compile_Data.m
    6. Filter_Ves.m
    7. SortbySize.m
    8. GenerateMontageSegmented.m
    9. Crop_conditions.m
    10. Crop_condition_full.m
    ```

3. Run "Run_All.m" for running the entire processing chain.

4. "Run_All.m" will run through the following codes described here in order:

    - SegmentObjects_Clock.m - !!NOTE: MUST INPUT XSCALE MANUALLY!! Will segment all objects in the .tif images and measure both total and core intensity from the objects. Outputs a .mat file per .tif image into the generated "Segmented_mat" folder.

    - SelectObjects_Clock.m - Selects likely vesicles from segmented objects using a intenity analysis method. Intensity range is automatically selected but can be adjusted if necessary. Outputs a mat file per tif image into the generated "Selected_mat_all" folder.

    - GenerateMontageSelected.m - Provides reference images to check processing quality. Outputs a montage images of selected and segmented vesicles, one for each tif image file in the "Selected_montage" folder. Will output a reference image on the left side. On the right side, it will contain the reference image with segmented (white overlay) and selected vesicles (red overlay).
NOTE: This can take considerable amount of time to run. If all processing parameters are known to work, you could consider skipping this processing step.

    - Compile_Data.m - Compiles all relevant vesicle data from the "Selected_mat_all" folder into one output file "Compiled_data.mat" in the "Processed_mat" folder. Note a vesicle diameter minimum value must be set here in the parameters. Defaults to 1 microns so only GUVs (by definition >= 1 micron) are captured.
      
      ```
      Key Variables for "Complied_data.mat"
      bgshapes 	- List of background intensity values over time of each tif image.
      dia 	 	- List of diameter values in microns for each vesicle.
      encap 	 	- List of total encapsulated intensity values over time (e.g. intensity of the clock reaction)
      encapcore 	- List of core encapsulated intensity values over time (not typically used for clock data)
      redpixels	- List of all pixel intensities for the lipid channel from each vesicle (e.g. DOPC-RhPE)
      red_chan	- List of total intensity values from the lipid channel (e.g. DOPC-RhPE)
      pos 		- List of file numbers each vescile comes from (note might not match file names, confirm processing order)
      shapes		- Table of segmented vesicle data from lipid channel, includes area, bounding box, and eccentricity.
      t		- Time vector with units in hours.
      Xscale 		- Xscale value (micron/pixel) determined from the original czi metadata (not included in tif files).
      ```

    - Filter_Ves.m - Uses an intensity analysis to filter out vesicles that move out of the ROI during the extent of the timeseries. Outputs the same data as "Compile_Data.m" but with "_filt" appended to denote the filtered state. 

    - SortbySize.m - Sorts the compiled and filtered data by vesicle diameter, centered around integer values +/- 0.5 microns (e.g. 3 micron group = 3 micron +/- 0.5 micron). Outputs the same data as "Filter_Ves.m" but with "_size" appended to denote the size sorted state. Variables are now cells, with the column number denoting the vesicle diameter in microns (e.g. column 10 is the 10 +/- 0.5 micron vesicles group). Empty columns means no vesicles of that size exists.

--- Optional Code Files ----

1. GenerateMontageSegmented.m - performs the same task as GenerateMontageSelectedCV.m but includes all segmented objects. Usually unnecessary to run both unless troubleshooting segmentation issues.

2. Crop_conditions.m - Creates single image crops of individual vesicles of a given size to output folder. This outputs the images from the slice used to segment the vesicles. Must choose what vesicle diameter group to run (e.g. size = 3, will output 3 +/- 0.5 micron diameter vesicles images).

3. Crop_condition_full.m - Creates timeseries image crops of individiual vesicles of a desired size to a output folder. Must choose what vesicle diameter group to run (e.g. size = 3, will output 3 +/- 0.5 micron diameter vesicles images).
