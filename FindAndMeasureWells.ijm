#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
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
	run("Set Measurements...", "centroid perimeter shape descriptors redirect=None decimal=9");

	//Select only well plate area
	run("Duplicate...", "use");
	setAutoThreshold("Huang dark");
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
	run("Gaussian Blur...", "sigma=8");
	//Create foreground image, removing small noise
	selectWindow("cropped");
	run("Duplicate...", "title=foreground");
	run("Median...", "radius=2");
	//Subtrack background from foreground to highlight wells
	imageCalculator("Subtract create", "foreground","background");
	// Threshold to select wells and inbetween diamonds
	selectWindow("Result of foreground");
	setAutoThreshold("MinError dark");
	
	run("Convert to Mask");
	close("Results");
	//Select only wells and measure centroid positions
	run("Close-");
	run("Analyze Particles...", "size=1100-Infinity include add");
	roiManager("Measure");

	num_found = nResults();
	for (i = 0; i < num_found; i++) {
	  v = getResult('Circ.', i);
      if (v >= 0.5) {
    	roiManager('select',i);
    	roiManager("add");
	}
  }
	roiManager("Select", Array.getSequence(num_found));
	roiManager("delete");
	close("Results");

	selectWindow("cropped");
	num_rois=roiManager("count");
	print(num_rois + " wells found");
	if (num_rois != 96) {
		exit("Error: "+ num_rois + " wells found");
	}
	//Sort centroids and draw circles so that final wells are labelled
	//in order top to bottom, left to right
	roiManager("Measure");
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
   	saveAs("Results", output+"/Results_Mean_"+title+".csv");
   	close("Results");
	print("Saving mean measurements to: " + output);
	run("Set Measurements...", "integrated redirect=None decimal=9");
   	roiManager("Multi Measure");
   	saveAs("Results", output+"/Results_IntDen_"+title+".csv");
   	close("Results");
	print("Saving integrated density measurements to: " + output);
}