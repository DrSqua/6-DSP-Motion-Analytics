%% Load Data

tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');

%[b,a] = butter(4,fc/(fs/2));

HR_data = tsv_data{:,1:3};
HL_data = tsv_data{:,4:6};

disp('Nu komt HR data')
HR_x = HR_data(:,1);
HR_y = HR_data(:,2);
HR_z = HR_data(:,3);

HL_x = HL_data(:,1);
HL_y = HL_data(:,2);
HL_z = HL_data(:,3);
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

%% Plot
plot3(HR_x, HR_y, HR_z)
hold on

plot3(HL_x, HL_y, HL_z)
axis equal
xlabel("X Space")
ylabel("Y Space")
zlabel("Z Space")
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

%%
%% Load marker data
%data = readtable("D:\User\Mateo\Unif\S6\6-Digital Signal Processing\10Ax1_view.xlsx");
tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');

HR_x = tsv_data{:,1};
HR_y = tsv_data{:,2};
HR_z = tsv_data{:,3};

HL_x = tsv_data{:,4};
HL_y = tsv_data{:,5};
HL_z = tsv_data{:,6};

C7_x = tsv_data{:,7};
C7_y = tsv_data{:,8};
C7_z = tsv_data{:,9};

MS_x = tsv_data{:,10};
MS_y = tsv_data{:,11};
MS_z = tsv_data{:,12};

PX_x = tsv_data{:,13};
PX_y = tsv_data{:,14};
PX_z = tsv_data{:,15};

AR_x = tsv_data{:,16};
AR_y = tsv_data{:,17};
AR_z = tsv_data{:,18};

% Veronderstel dat we markers hebben zoals: SCAP1_x, SCAP1_y, SCAP1_z, HUM1_x, ...
% Zet ze om naar matrices (positie in tijd: Nx3)
HR = [HR_x HR_y HR_z];
HL = [HL_x HL_y HL_z];
C7 = [C7_x C7_y C7_z];

MS = [MS_x MS_y MS_z];
PX = [PX_x PX_y PX_z];
AR = [AR_x AR_y AR_z];


numCols = width(tsv_data);
disp(numCols);

for i = 1:numCols
    
end

% Bereken rotatiematrices over de tijd
R_scap = makeFrame(HR, HL, C7); % scapula als proximale segment
R_hum  = makeFrame(MS, PX, AR);    % humerus als distale segment

nFrames = size(R_scap, 3);
R_joint = zeros(3,3,nFrames);

for i = 1:nFrames
    R_joint(:,:,i) = R_scap(:,:,i)' * R_hum(:,:,i); % transponeren = inverse (orthonormaal)
end

angles = zeros(nFrames, 3); % [alpha beta gamma]

for i = 1:nFrames
    rotm = R_joint(:,:,i);
    % Gebruik ZYX of gewenste volgorde hier — hier bv. 'yxy'
    eul = rot_matx_euler(rotm); 
    angles(i,:) = rad2deg(eul); % omzetten naar graden
end

% Applying butterworth filtering
Fs = 300;                       % Sampling frequency (Hz)
order = 4;                      % Filter order
cutoff = 100;                   % Cutoff frequency (Hz)
Wn = cutoff / (Fs/2);           % Normalize cutoff to Nyquist frequency
[b, a] = butter(order, Wn);     % Low-pass Butterworth filter

y = angles(:,1);

y_clean = y(isfinite(y));
y_filtered = filtfilt(b, a, y_clean);% Zero-phase filtering (recommended for analysis)

% Plot bijvoorbeeld elevatie (2e hoek)
plot(y_filtered);
ylabel("GH Elevation (degrees)");
xlabel("Time Frame");

