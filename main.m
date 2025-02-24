% bovenarm, onderarm, torso, bekken hebben assenstelsel nodig
% x: plain of motion; y: elavation
frequency = 300;
numberOfFrames = 558;
numberOfCameras = 11;
numberOfMarkers = 34;
    
tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');
print(tsv_data)