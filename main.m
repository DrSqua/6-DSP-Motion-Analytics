%% Read Data
% bovenarm, onderarm, torso, bekken hebben assenstelsel nodig
% x: plain of motion; y: elavation
fs = 300;
fc = 1000;
    
numberOfFrames = 558;
numberOfCameras = 11;
numberOfMarkers = 34;

tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');


%[b,a] = butter(4,fc/(fs/2));

disp(tsv_data)
HR_data = tsv_data{:,1:3};

disp('Nu komt HR data')
HR_x = HR_data(:,1);
HR_y = HR_data(:,2);
HR_z = HR_data(:,3);


% Ensure the reshaping is valid
if mod(length(HR_z), num_rows) == 0
    HR_z_matrix = reshape(HR_z, num_rows, num_cols);
else
    error("Cannot reshape: Choose different num_rows value");
end

[HR_x_matrix, HR_y_matrix] = meshgrid(HR_x(1:num_cols), HR_y(1:num_rows));
disp(HR_z_matrix);

figure;
mesh(HR_x_matrix,HR_y_matrix,HR_z_matrix)
xlabel('HR_x');
ylabel('HR_y');
zlabel('HR_z');
title('3D Mesh of HR Data');


HR = [tsv_data(:,1);tsv_data(:,2);tsv_data(:,3)];
disp(HR)
%% Tobias snelle jelle test code
% Get the data and seperate the columns
dataIn = Ax1;
dataHR = tsv_data(:,1);% Column from HR
dataHL = 0;% Column from HL
% Filter the data using butterworth filter
fc = 300; % Cutoff frequency [Hz]
fs = 1000; % Sampling frequency [Hz]
n = 4; % Filter order

[b,a] = butter(n, fc/(fs/2)); % Creates filter coefficiënts
dataOutHR = filter(b,a,dataHR); % Filter the data