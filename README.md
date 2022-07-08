# FindAndMeasureWellIntensities
ImageJ macro to automatically finds well positions and measures the intensitites over time

Tested with 96 well plate images on Ubuntu 20.04, ImageJ 1.53q

## Parameters:
Input: Folder containing 2D+t image stack of well plate
Output: Folder to save .csv files of measurements
Well size: Diameter of wells in pixels

## Usage
In ImageJ/Fiji: Plugins > Macros > Edit and select the macro "FindAndMeasureWells.ijm". \
Click Run \
Input the requested parameters into the dialog box

## Output
One .csv file will be outputtted for each time point containing the intensity measurements for each well. The wells are labelled top to bottom, left to right.

## Limitations
The macro assumes the plate does not move during imaging.
