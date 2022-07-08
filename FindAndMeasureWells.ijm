#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ int (label = "Well size (pixels)", value=52) well_size

roiManager("reset");
close("*");
processFile(input,output);

function processFile(input, output) {
File.openSequence(input);
run("Set Measurements...", "centroid redirect=None decimal=9");

run("Duplicate...", "use");
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=5000-Infinity exclude include add");
selectWindow("image sequence for Laura CAMDU");
roiManager("Select", 0);
run("Duplicate...", "title=cropped duplicate");
roiManager("Select", 0);
roiManager("Delete");
run("Select None");

run("Duplicate...", "title=background");
run("Gaussian Blur...", "sigma=20");
selectWindow("cropped");
run("Duplicate...", "title=foreground");
run("Median...", "radius=2");
imageCalculator("Subtract create", "foreground","background");
selectWindow("Result of foreground");
setAutoThreshold("Triangle dark");
run("Convert to Mask");
close("Results")
run("Analyze Particles...", "size=1200-Infinity include add");
roiManager("Measure");

selectWindow("cropped");
num_rois=roiManager("count");
print(num_rois + " wells found");
// could stop here
Table.sort("X");
selectWindow("cropped");
close("\\Others");
for (i = 0; i < 12; i++) {
	x=newArray(8);
	y=newArray(8);
	for (j = 0; j < 8; j++) {
    	x[j] = getResult('X', i*8+j);
    	y[j] = getResult('Y', i*8+j);
	}
	arr=Array.rankPositions(y);
	for (j = 0; j < 8; j++) {
		makeOval(x[arr[j]]-well_size/2,y[arr[j]]-well_size/2,well_size,well_size);
    	roiManager("add");
	}
}

roiManager("Select", Array.getSequence(num_rois));
roiManager("delete");
run("Select None");

close("Results")

run("Set Measurements...", "mean standard modal median redirect=None decimal=9");

for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    frame=IJ.pad(i,3);
    roiManager("Measure");
    saveAs("Results", output+"/Frame"+frame+".csv");
    close("Results");
}
	print("Saving to: " + output);
}