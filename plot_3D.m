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

%% Plot
plot3(HR_x, HR_y, HR_z)
hold on

plot3(HL_x, HL_y, HL_z)
axis equal
hold off
xlabel("X Space")
ylabel("Y Space")
zlabel("Z Space")

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


% numCols = width(tsv_data);
% disp(numCols);
% 
% markerNames = cell(1, numCols);
% 
% for i = 1:numCols
%    markerNames{i} = tsv_data(11,i);
% 
% 
% end

% Bereken rotatiematrices over de tijd
R_scap = makeFrame(HR, HL, C7); % scapula als proximale segment
R_hum  = makeFrame(MS, PX, AR);    % humerus als distale segment
origin_scap = HR;  % or mean([HR; HL; C7])
origin_hum  = MS;  % or mean([MS; PX; AR])

nFrames = size(R_scap, 3);
L = 100;  % vector length for plotting

% Initialize storage for all origins and endpoints
scap_origins = zeros(nFrames, 3);
scap_X = zeros(nFrames, 3);
scap_Y = zeros(nFrames, 3);
scap_Z = zeros(nFrames, 3);

hum_origins = zeros(nFrames, 3);
hum_X = zeros(nFrames, 3);
hum_Y = zeros(nFrames, 3);
hum_Z = zeros(nFrames, 3);
counter = 0;
% Loop to collect data
for i = 1:nFrames
    if (counter == 20)
        R1 = R_scap(:,:,i); origin1 = HR(i,:);
        R2 = R_hum(:,:,i);  origin2 = MS(i,:);
    
        scap_origins(i,:) = origin1;
        scap_X(i,:) = R1(:,1)' * L;
        scap_Y(i,:) = R1(:,2)' * L;
        scap_Z(i,:) = R1(:,3)' * L;
    
        hum_origins(i,:) = origin2;
        hum_X(i,:) = R2(:,1)' * L;
        hum_Y(i,:) = R2(:,2)' * L;
        hum_Z(i,:) = R2(:,3)' * L;

        counter = 0;
    else
        counter = counter + 1;
    end
end

% Final plot
figure;
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('All Unit Vectors of Scapula and Humerus Over Time');
view(3);

% Plot all scapula vectors
quiver3(scap_origins(:,1), scap_origins(:,2), scap_origins(:,3), ...
        scap_X(:,1), scap_X(:,2), scap_X(:,3), 0, 'r');
quiver3(scap_origins(:,1), scap_origins(:,2), scap_origins(:,3), ...
        scap_Y(:,1), scap_Y(:,2), scap_Y(:,3), 0, 'g');
quiver3(scap_origins(:,1), scap_origins(:,2), scap_origins(:,3), ...
        scap_Z(:,1), scap_Z(:,2), scap_Z(:,3), 0, 'b');

% Plot all humerus vectors
quiver3(hum_origins(:,1), hum_origins(:,2), hum_origins(:,3), ...
        hum_X(:,1), hum_X(:,2), hum_X(:,3), 0, 'r');
quiver3(hum_origins(:,1), hum_origins(:,2), hum_origins(:,3), ...
        hum_Y(:,1), hum_Y(:,2), hum_Y(:,3), 0, 'g');
quiver3(hum_origins(:,1), hum_origins(:,2), hum_origins(:,3), ...
        hum_Z(:,1), hum_Z(:,2), hum_Z(:,3), 0, 'b');

legend('X scap', 'Y scap', 'Z scap', 'X hum', 'Y hum', 'Z hum');



%%
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
cutoff = 1;                   % Cutoff frequency (Hz)
Wn = cutoff / (Fs/2);           % Normalize cutoff to Nyquist frequency
[b, a] = butter(order, Wn);     % Low-pass Butterworth filter

y = angles(:,1);

y_clean = y(isfinite(y));
y_filtered = filtfilt(b, a, y_clean);% Zero-phase filtering (recommended for analysis)

% Plot bijvoorbeeld elevatie (2e hoek)
figure
plot(y_filtered);
ylabel("GH Elevation (degrees)");
xlabel("Time Frame");

%% Maak een FFT en analyseren bij welke frequennties het meeste energie zit
