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

Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 1; % Cutoff frequency (Hz)
P1 = [butterworth_filter(HR_x, Fs, cutoff, order) butterworth_filter(HR_y, Fs, cutoff, order) butterworth_filter(HR_z, Fs, cutoff, order)];
P2 = [butterworth_filter(HL_x, Fs, cutoff, order) butterworth_filter(HL_y, Fs, cutoff, order) butterworth_filter(HL_z, Fs, cutoff, order)];
P3 = [butterworth_filter(C7_x, Fs, cutoff, order) butterworth_filter(C7_y, Fs, cutoff, order) butterworth_filter(C7_z, Fs, cutoff, order)];

% Preallocate rotation matrix array
% N = size(P1,1);
% R = zeros(3,3,N);

% Compute rotation matrix for each point set
%for i = 1:N
%    R(:,:,i) = makeFrame(P1(i,:), P2(i,:), P3(i,:));
%end

% Create figure with two subplots
figure;

% Subplot 1: 3D scatter plot of points
subplot(2,1,1);
hold on;
% Smaller point size
scatter3(P1(:,1), P1(:,2), P1(:,3), 10, 'r', 'filled', 'DisplayName', 'HR (P1)');
scatter3(P2(:,1), P2(:,2), P2(:,3), 10, 'g', 'filled', 'DisplayName', 'HL (P2)');
scatter3(P3(:,1), P3(:,2), P3(:,3), 10, 'b', 'filled', 'DisplayName', 'C7 (P3)');

xlabel('X'); ylabel('Y'); zlabel('Z');
title('3D Points');
legend; grid on; axis equal;
hold off;

% Subplot 2:
% Store line segments
X_lines = [];
Y_lines = [];
Z_lines = [];
for i = 1:N
    % Triangle edges: P1-P2, P2-P3, P3-P1
    X_lines = [X_lines; [P1(i,1) P2(i,1)]; [P2(i,1) P3(i,1)]; [P3(i,1) P1(i,1)]; NaN NaN];
    Y_lines = [Y_lines; [P1(i,2) P2(i,2)]; [P2(i,2) P3(i,2)]; [P3(i,2) P1(i,2)]; NaN NaN];
    Z_lines = [Z_lines; [P1(i,3) P2(i,3)]; [P2(i,3) P3(i,3)]; [P3(i,3) P1(i,3)]; NaN NaN];
end
% Plot all triangle edges
plot3(X_lines', Y_lines', Z_lines', 'k--');
grid on; axis equal;
hold off;

% Adjust figure layout
sgtitle('Points and Local Frames Visualization');
