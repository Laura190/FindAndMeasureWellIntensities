#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Input directory", style = "directory") output
#@ int (label = "Well size (pixels)", default=52) well_size
#@ boolean (label= "Despeckle") despec


//close any open images and reset the roiManager to prevent errors
roiManager("reset");
close("*");
processFile(input,output);

function processFile(input, output) {
	//Load image sequence
	File.openSequence(input);
	title=getTitle()
	run("Flip Horizontally","stack");
	//If despeckle option selected despeckle
	if (despec) {
		run("Despeckle", "stack");
	}
	//Set to measure centroid coordinates
	run("Set Measurements...", "centroid redirect=None decimal=9");
	
	//Select only well plate area
	run("Duplicate...", "use");
	setAutoThreshold("Default dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=5000-Infinity exclude include add");
	selectWindow(title);
	roiManager("Select", 0);
	run("Duplicate...", "title=cropped duplicate");
	roiManager("Select", 0);
	roiManager("Delete");
	run("Select None");
	
	//Create background image to remove any large gradients
	run("Duplicate...", "title=background");
	run("Gaussian Blur...", "sigma=20");
	//Create foreground image, removing small noise
	selectWindow("cropped");
	run("Duplicate...", "title=foreground");
	run("Median...", "radius=2");
	//Subtrack background from foreground to highlight wells
	imageCalculator("Subtract create", "foreground","background");
	// Threshold to select wells and inbetween diamonds
	selectWindow("Result of foreground");
	setAutoThreshold("Triangle dark");
	run("Convert to Mask");
	close("Results");
	//Select only wells and measure centroid positions
	run("Analyze Particles...", "size=1200-Infinity include add");
	roiManager("Measure");

	selectWindow("cropped");
	num_rois=roiManager("count");
	print(num_rois + " wells found");
	//Sort centroids and draw circles so that final wells are labelled
	//in order top to bottom, left to right
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
	// remove original well detections, leaving only circular well selections
	roiManager("Select", Array.getSequence(num_rois));
	roiManager("delete");
	run("Select None");
	close("Results");
	
	//Measure mean grey value for every well at every time point
	run("Set Measurements...", "mean redirect=None decimal=9");
   	roiManager("Multi Measure");
   	saveAs("Results", output+"/Results_"+title+".csv");
   	close("Results");
	print("Saving to: " + output);
}
