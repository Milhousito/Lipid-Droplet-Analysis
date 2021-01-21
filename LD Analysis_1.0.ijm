/* 
 * IBGM Imaging Facility
 * ImageJ/Fiji Macro Language
 * javier.casas@uva.es - BioImage Informatics Facility @IBGM
 * December 2020
 */

//batch processing
input_path = getDirectory("Choose image folder"); 
fileList = getFileList(input_path); 
//loops over all images in the given directory
for (f=0; f<fileList.length; f++){ 
	
	//clean-up to prepare for analysis
	roiManager("reset");	
	run("Close All");
	run("Clear Results");

	//open file
	open(input_path + fileList[f]);
	print(input_path + fileList[f]); //displays file that is processed

	//minimum particle size (microns) for "Analyze particles..." command, will be used for all other images in the folder
	if(f==0){
		minSize = getNumber("minimum size of nuclei", 20); 
	}
	
	//Step1: Getting image information + normalise the data name
	//get general information
	title = getTitle();
	

	//split channels and rename them
	run("Split Channels");
	selectWindow("C1-"+title);
	rename("nuclei");
	selectWindow("C2-"+title);
	rename("signal");
	selectWindow("C3-"+title);
	rename("brightfield");	
	close("brightfield");		
	//Step2: Prefilter nuclear image and make binary image to count cell number
	selectWindow("nuclei");
	//preprocessing of the grayscale image
	run("Gaussian Blur...", "radius=2");
	//thresholding
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	//postprocessing of binary image
	run("Fill Holes");
	run("Watershed");	
	run("Analyze Particles...", "size=" + minSize + "-Infinity circularity=0.20-1.00 show=Outlines display clear summarize");	
	nRois = roiManager("count");
	
	
	//Step3: Getting Lipid Droplet information + normalise the data name
	//get general information

	//minimum particle size (microns) for "Analyze particles..." command, will be used for all other images in the folder
	if(f==0){
		minSize2 = getNumber("minimum size of lipid droplet", 0.5); 
	}
	
	selectWindow("signal");
	run("Duplicate...", "title=signal_1");
	//title = getTitle();
	setAutoThreshold("Default dark");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	roiManager("Deselect");	
	run("Analyze Particles...", "size=" + minSize2 + "-Infinity circularity=0.00-1.00 show=Outlines  clear  add");

	// measure signal from detected Lipid Droplets
	run("Set Measurements...", "area mean standard perimeter shape median display nan redirect=None decimal=3");
	selectWindow("signal");
	roiManager("deselect");
	roiManager("multi-measure measure_all");
		
	 	

	// Save results with specific name
	updateResults();
	selectWindow("signal");
	getTitle();
	saveAs("results", "/Volumes/Milhousito\ HDD/Users/milhousito/Documents/IBGM-2/PTA/MABalboa/Filipina/Results/ " + title + "_results.csv");
	}
	// Save Summary with specific name
	selectWindow("Summary");
	saveAs("Results", "/Volumes/Milhousito\ HDD/Users/milhousito/Documents/IBGM-2/PTA/MABalboa/Filipina/Results/Summary.csv");


 