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

%% Tobias snelle jelle test code
% Get the data and seperate the columns
dataIn = Ax1;
dataHR = % Column from HR
dataHL = % Column from HL
% Filter the data using butterworth filter
fc = 300; % Cutoff frequency [Hz]
fs = 1000; % Sampling frequency [Hz]
n = 4; % Filter order

[b,a] = butter(n, fc/(fs/2)); % Creates filter coefficiënts
dataOutHR = filter(b,a,dataHR); % Filter the data