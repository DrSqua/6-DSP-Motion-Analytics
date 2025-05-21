%% ————————————————————————————————————————————————
%  Main script using attitudeMatrix, relRot, rot2CardanXYZ
%  Assumes the functions are on your MATLAB path:
%     • attitudeMatrix.m
%     • relRot.m
%     • rot2CardanXYZ.m
%  ————————————————————————————————————————————————

%% 1) Load raw marker data
tsv = readtable("10Ax1.tsv","FileType","text","Delimiter","\t");

% Assign each marker’s Nx3 trajectory
HR = tsv{:,1:3};    % right scapula origin triad
HL = tsv{:,4:6};
C7 = tsv{:,7:9};

MS = tsv{:,10:12};  % humerus markers
PX = tsv{:,13:15};
AR = tsv{:,16:18};

% Upper arm
AR = tsv{:16:18};
ELR = tsv{:,25:27};
EMR = tsv{:,28:30};
PLR = tsv{:,40:42};


nFrames = size(HR,1);

%% 2) Preallocate
R_scap = zeros(3,3,nFrames);
R_hum  = zeros(3,3,nFrames);

jointAngles = zeros(nFrames,3);  % [flexion, abduction, rotation]

%% 3) Build attitude & relative‐rotation & extract Cardan angles
for i = 1:nFrames
  % 3a) Attitude matrices (local→global)
  R_scap(:,:,i) = attitude_matrix( HR(i,:)', HL(i,:)', C7(i,:)');
  R_hum(:,:,i)  = attitude_matrix( MS(i,:)', PX(i,:)', AR(i,:)' );
  
  % 3b) Relative rotation (humerus relative to scapula)
  R_rel = rel_rotation_matrix(R_scap(:,:,i), R_hum(:,:,i));
  
  % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
  [f,a,r]           = Euler_Cardan_angles(R_rel);
  jointAngles(i,:) = [f, a, r];
end

%% 4) Butterworth filter the time series of each angle

Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 1; % Cutoff frequency (Hz)
anglesFilt(:,1) = butterworth_filter(jointAngles(:,1), Fs, cutoff, order); 
anglesFilt(:,2) = butterworth_filter(jointAngles(:,2), Fs, cutoff, order); 
anglesFilt(:,3) = butterworth_filter(jointAngles(:,3), Fs, cutoff, order); 
%% 5) Plot the three joint‐angle time series
t = (1:nFrames)/Fs;  % time vector in seconds
%t = (1:1674);  % time vector in seconds
length(t)
length(anglesFilt(:,1))
%length(anglesFilt(:,2))
%length(anglesFilt(:,3))
figure;
subplot(3,1,1)
plot(t, anglesFilt(:,1))
ylabel('Flexion (°)')
title('Glenohumeral Joint Angles')

subplot(3,1,2)
plot(t, anglesFilt(:,2))
ylabel('Abduction (°)')

subplot(3,1,3)
plot(t, anglesFilt(:,3))
ylabel('Axial Rot. (°)')
xlabel('Time (s)')

%% 6) (Optional) Visualize one frame of local axes
frameToShow = round(nFrames/2);
L = 50;  % scale for quivers

O_s = HR(frameToShow,:);
O_h = MS(frameToShow,:);

R1 = R_scap(:,:,frameToShow);
R2 = R_hum(:,:,frameToShow);

figure; hold on; axis equal; grid on
quiver3(O_s(1),O_s(2),O_s(3), R1(1,1)*L,R1(2,1)*L,R1(3,1)*L,0,'r')
quiver3(O_s(1),O_s(2),O_s(3), R1(1,2)*L,R1(2,2)*L,R1(3,2)*L,0,'g')
quiver3(O_s(1),O_s(2),O_s(3), R1(1,3)*L,R1(2,3)*L,R1(3,3)*L,0,'b')

quiver3(O_h(1),O_h(2),O_h(3), R2(1,1)*L,R2(2,1)*L,R2(3,1)*L,0,'r--')
quiver3(O_h(1),O_h(2),O_h(3), R2(1,2)*L,R2(2,2)*L,R2(3,2)*L,0,'g--')
quiver3(O_h(1),O_h(2),O_h(3), R2(1,3)*L,R2(2,3)*L,R2(3,3)*L,0,'b--')

legend('Scap X','Scap Y','Scap Z','Hum X','Hum Y','Hum Z')
xlabel('X'); ylabel('Y'); zlabel('Z')
title(sprintf('Local Frames at Frame %d', frameToShow))
view(3)
