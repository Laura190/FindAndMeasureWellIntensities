# FindAndMeasureWellIntensities
ImageJ macro to automatically finds well positions and measures the intensitites over time

Tested with 96 well plate images on Ubuntu 20.04, ImageJ 1.53q

## Parameters:
Input: Folder containing 2D+t image stack of well plate
Output: Folder to save .csv file of measurements
Well size: Diameter of wells in pixels
Despeckle: Applies despeckle function to image stack before analysis if true

## Usage
In ImageJ/Fiji: Plugins > Macros > Edit and select the macro "FindAndMeasureWells.ijm". \
Click Run \
Input the requested parameters into the dialog box

## Output
One .csv file with mean intensity for each well (columns) for each time point (rows). File will be named "Results_\<name of image stack\>.csv"

## Limitations
The macro assumes the plate does not move during imaging.
