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

%% Thorax
MS = tsv{:,10:12};  % humerus markers
PX  = tsv{:,13:15}; % Middenrif
AR  = tsv{:,16:18}; % Schouder Rechts
AL  = tsv{:,19:21}; % Schouder Links
%% Upper arm (U): AR, ELR, EMR, PLR
ELR = tsv{:,25:27}; % Elleboog
EMR = tsv{:,28:30}; % Elleboog binnen
PMR = tsv{:,40:42}; % Pols
PLR = tsv{:,43:45}; % Pols binnen

nFrames = size(HR,1);
%% 2) Preallocate
R_scap = zeros(3,3,nFrames);
R_hum  = zeros(3,3,nFrames);
R_upp_arm = zeros(3,3,nFrames);
R_upp_arm_child = zeros(3,3,nFrames);
R_thorax = zeros(3,4,nFrames);
R_thorax_child = [MS(1,:)', PX(1,:)', AR(1,:)', AL(1,:)'];

jointAngles_arm = zeros(nFrames,3);  % [flexion, abduction, rotation]
jointAngles_thorax = zeros(nFrames,3);  % [flexion, abduction, rotation]
jointAngles_hum = zeros(nFrames,3);  % [flexion, abduction, rotation]

%% 3) Build attitude & relative‐rotation & extract Cardan angles
for i = 1:nFrames
  % 3a) Attitude matrices (local→global)
  R_scap(:,:,i) = attitude_matrix( HR(i,:)', HL(i,:)', C7(i,:)');
  R_hum(:,:,i)  = attitude_matrix( MS(i,:)', PX(i,:)', AR(i,:)' );
  R_upp_arm(:,:,i) = attitude_matrix( AR(i,:)', ELR(i,:)', EMR(i,:)' );
  R_upp_arm_child(:,:,i) = attitude_matrix(AR(1,:)',ELR(1,:)',EMR(1,:)');
  R_thorax(:,:,i) = [MS(i,:)', PX(i,:)', AR(i,:)', AL(i,:)'];

  % 3b) Relative rotation (humerus relative to scapula)
  R_rel_hum = rel_rotation_matrix(R_scap(:,:,i), R_hum(:,:,i));
  R_rel_arm = rel_rotation_matrix(R_upp_arm(:,:,i), R_upp_arm_child(:,:,i));
  R_rel_thorax = rel_rot_for_N_points(R_thorax(:,:,i) ,R_thorax_child);

  % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
  [f,a,r] = Euler_Cardan_angles(R_rel_arm);
  [f2,a2,r2] = Euler_Cardan_angles(R_rel_hum);
  [f3,a3,r3] = Euler_Cardan_angles(R_rel_thorax);
  jointAngles_arm(i,:) = [f, a, r];
  jointAngles_hum(i,:) = [f2, a2, r2];
  jointAngles_thorax(i,:) = [f3,a3,r3];
end

%% 4) Butterworth filter the time series of each angle

Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 10; % Cutoff frequency (Hz)
anglesFilt_arm(:,1) = butterworth_filter(jointAngles_arm(:,1), Fs, cutoff, order); 
anglesFilt_arm(:,2) = butterworth_filter(jointAngles_arm(:,2), Fs, cutoff, order); 
anglesFilt_arm(:,3) = butterworth_filter(jointAngles_arm(:,3), Fs, cutoff, order); 

anglesFilt_hum(:,1) = butterworth_filter(jointAngles_hum(:,1), Fs, cutoff, order); 
anglesFilt_hum(:,2) = butterworth_filter(jointAngles_hum(:,2), Fs, cutoff, order); 
anglesFilt_hum(:,3) = butterworth_filter(jointAngles_hum(:,3), Fs, cutoff, order); 

anglesFilt_thorax(:,1) = butterworth_filter(jointAngles_thorax(:,1), Fs, cutoff, order); 
anglesFilt_thorax(:,2) = butterworth_filter(jointAngles_thorax(:,2), Fs, cutoff, order); 
anglesFilt_thorax(:,3) = butterworth_filter(jointAngles_thorax(:,3), Fs, cutoff, order); 
%% 5) Plot the three joint‐angle time series
t = (1:nFrames)/Fs;  % time vector in seconds
%t = (1:1674);  % time vector in seconds
length(t)
length(anglesFilt_arm(:,1))
length(anglesFilt_hum(:,1))
%length(anglesFilt(:,2))
%length(anglesFilt(:,3))

figure;
sgtitle("arm")
subplot(3,1,1)
plot(t, anglesFilt_arm(:,1))
ylabel('Flexion (°)')
title('Glenohumeral Joint Angles')

subplot(3,1,2)
plot(t, anglesFilt_arm(:,2))
ylabel('Abduction (°)')

subplot(3,1,3)
plot(t, anglesFilt_arm(:,3))
ylabel('Axial Rot. (°)')
xlabel('Time (s)')

figure;
sgtitle("hum")
subplot(3,1,1)
plot(t, anglesFilt_hum(:,1))
ylabel('Flexion (°)')
title('Glenohumeral Joint Angles')

subplot(3,1,2)
plot(t, anglesFilt_hum(:,2))
ylabel('Abduction (°)')

subplot(3,1,3)
plot(t, anglesFilt_hum(:,3))
ylabel('Axial Rot. (°)')
xlabel('Time (s)')

figure;
sgtitle("thorax")
subplot(3,1,1)
plot(t, anglesFilt_thorax(:,1))
ylabel('Flexion (°)')
title('Glenohumeral Joint Angles')

subplot(3,1,2)
plot(t, anglesFilt_thorax(:,2))
ylabel('Abduction (°)')

subplot(3,1,3)
plot(t, anglesFilt_thorax(:,3))
ylabel('Axial Rot. (°)')
xlabel('Time (s)')
%% 6) (Optional) Visualize one frame of local axes
frameToShow = round(nFrames/2);
L = 100;  % scale for quivers

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
