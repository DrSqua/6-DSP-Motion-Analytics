% bovenarm, onderarm, torso, bekken hebben assenstelsel nodig
% x: plain of motion; y: elavation
fs = 300;
fc = 1000;
    
numberOfFrames = 558;
numberOfCameras = 11;
numberOfMarkers = 34;

tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');
sdxcc
[b,a] = butter(4,fc/(fs/2));

disp(tsv_data)
ddd