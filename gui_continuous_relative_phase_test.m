%% Input and angles
Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 10; % Cutoff frequency (Hz)

tsv = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');

MS  = tsv{:,10:12}; % Nek?
PX  = tsv{:,13:15}; % Middenrif
AR  = tsv{:,16:18}; % Schouder Rechts
AL  = tsv{:,19:21}; % Schouder Links
ELR = tsv{:,25:27}; % Elleboog
EMR = tsv{:,28:30}; % Elleboog binnen
PMR = tsv{:,40:42}; % Pols
PLR = tsv{:,43:45}; % Pols binnen

% Number of time frames
N = size(AR,1);

% Preallocate attitude matrices
U = zeros(3,3,N);  % Upper Arm
F = zeros(3,3,N);  % Forearm

for t = 1:N
    % --- Upper Arm CS ---
    ELR_t = ELR(t,:);
    EMR_t = EMR(t,:);
    AR_t  = AR(t,:);
    
    x_U = (EMR_t - ELR_t); 
    x_U = x_U / norm(x_U);
    
    y_U = (AR_t - ELR_t);  
    y_U = y_U / norm(y_U);
    
    z_U = cross(x_U, y_U);
    z_U = z_U / norm(z_U);
    
    y_U = cross(z_U, x_U);
    y_U = y_U / norm(y_U);
    
    U(:,:,t) = [x_U' y_U' z_U'];
    
    % --- Forearm CS ---
    PLR_t = PLR(t,:);
    
    x_F = (EMR_t - ELR_t);
    x_F = x_F / norm(x_F);
    
    y_F = (PLR_t - ELR_t);
    y_F = y_F / norm(y_F);
    
    z_F = cross(x_F, y_F);
    z_F = z_F / norm(z_F);
    
    y_F = cross(z_F, x_F);
    y_F = y_F / norm(y_F);
    
    F(:,:,t) = [x_F' y_F' z_F'];

    % --- Thorax CS ---
    % Based on ISB: use MS (neck), PX (midriff), AR, AL
    MS_t = MS(t,:);
    PX_t = PX(t,:);
    AL_t = AL(t,:);
    
    % Origin: midpoint between AR and AL
    origin = (AR_t + AL_t) / 2;
    
    % y-axis: MS to PX (superior-inferior, longitudinal)
    y_T = (MS_t - PX_t);
    y_T = y_T / norm(y_T);
    
    % x-axis: perpendicular to plane formed by MS, PX, and shoulder line
    shoulder_vec = (AR_t - AL_t);
    x_T = cross(y_T, shoulder_vec);
    x_T = x_T / norm(x_T);
    
    % z-axis: cross product
    z_T = cross(x_T, y_T);
    z_T = z_T / norm(z_T);
    
    T(:,:,t) = [x_T' y_T' z_T'];
end

% Relative rotation matrices
R_rel_FU = zeros(3,3,N); % Forearm relative to Upper Arm
R_rel_UT = zeros(3,3,N); % Upper Arm relative to Thorax

for t = 1:N
    R_rel_FU(:,:,t) = F(:,:,t) * U(:,:,t)';  % Elbow
    R_rel_UT(:,:,t) = U(:,:,t) * T(:,:,t)';  % Shoulder
end

% Extract Euler angles for elbow (ZXY order)
euler_angles_FU = zeros(N, 3); % [Z, X, Y]

for t = 1:N
    R = R_rel_FU(:,:,t);
    if abs(R(3,2)) < 1
        x = asin(R(3,2));
        z = atan2(-R(1,2), R(2,2));
        y = atan2(-R(3,1), R(3,3));
    else
        x = sign(R(3,2)) * pi/2;
        z = atan2(R(2,1), R(1,1));
        y = 0;
    end
    euler_angles_FU(t,:) = rad2deg([z, x, y]);
end

% Extract Euler angles for shoulder (ZXY order)
euler_angles_UT = zeros(N, 3); % [Z, X, Y]

for t = 1:N
    R = R_rel_UT(:,:,t);
    if abs(R(3,2)) < 1
        x = asin(R(3,2));
        z = atan2(-R(1,2), R(2,2));
        y = atan2(-R(3,1), R(3,3));
    else
        x = sign(R(3,2)) * pi/2;
        z = atan2(R(2,1), R(1,1));
        y = 0;
    end
    euler_angles_UT(t,:) = rad2deg([z, x, y]);
end


%% Methode 1 Normalised
% Define signals
signal1 = euler_angles_FU(:,2);  % Elbow flexion/extension (X rotation)
signal2 = euler_angles_UT(:,2);  % Shoulder flexion/extension (X rotation)

% Apply Butterworth filter to smooth signals
[b, a] = butter(order, cutoff/(Fs/2), 'low');
signal1 = filtfilt(b, a, signal1);
signal2 = filtfilt(b, a, signal2);

% Compute angular velocity (derivative over time)
vel1 = gradient(signal1);
vel2 = gradient(signal2);

% Normalisation (specific to methode 1)
signal1_norm = (signal1 - min(signal1)) / (max(signal1) - min(signal1)) * 2 - 1;
signal2_norm = (signal2 - min(signal2)) / (max(signal2) - min(signal2)) * 2 - 1;
vel1_norm = (vel1 - min(vel1)) / (max(vel1) - min(vel1)) * 2 - 1;
vel2_norm = (vel2 - min(vel2)) / (max(vel2) - min(vel2)) * 2 - 1;

phase1 = atan2(vel1_norm, signal1_norm);
phase2 = atan2(vel2_norm, signal2_norm);

crp = rad2deg(phase1 - phase2);
crp = mod(crp + 180, 360) - 180;  % wrap to [-180, 180]

% Plot
%
% Plot angle-velocity phase plane for signal1 (elbow)
% Create a single figure with two subplots side by side
figure;

% Left subplot: Angle-Velocity Phase Plane for Elbow
subplot(1, 2, 1); % 1 row, 2 columns, first plot
hold on; grid on;

% Plot trajectory as blue dots
plot(signal1_norm, vel1_norm, 'b.', 'MarkerSize', 12);

% Mark start and end points
plot(signal1_norm(1), vel1_norm(1), 'go', 'MarkerSize', 10, 'LineWidth', 2); % Start
plot(signal1_norm(end), vel1_norm(end), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % End

% Axis labels and title
xlabel('Angle');
ylabel('Velocity');
title('Angle-Velocity Phase Plane (Elbow)');

% Legend
legend({'Trajectory', 'Start', 'End'}, 'Location', 'best');

% Add annotation for max velocity point
[~, idx] = max(abs(vel1_norm));
x_annot = signal1_norm(idx);
y_annot = vel1_norm(idx);
text(x_annot, y_annot, 'Max Velocity', 'Color', 'k', 'FontSize', 10, 'HorizontalAlignment', 'right');

hold off;

% Right subplot: CRP over Time
subplot(1, 2, 2); % 1 row, 2 columns, second plot
hold on; grid on;

% Plot CRP as black line
plot(crp, 'k-', 'LineWidth', 1.5);

% Axis labels and title
xlabel('Time (samples)');
ylabel('Continuous Relative Phase (degrees)');
title('CRP: Elbow vs. Shoulder Flexion/Extension');

% Legend
legend({'CRP'}, 'Location', 'best');
hold off;

% Adjust figure layout
sgtitle('Elbow Motion Analysis Methode 1 Normalised'); % Optional: Add a super-title for the entire figure
set(gcf, 'Position', [100, 100, 1200, 400]); % Adjust figure size for better visibility

%% Methode 1 Non-normalized
signal1 = euler_angles_FU(:,2);  % Elbow flexion/extension (X rotation)
signal2 = euler_angles_UT(:,2);  % Shoulder flexion/extension (X rotation)

% Apply Butterworth filter to smooth signals
[b, a] = butter(order, cutoff/(Fs/2), 'low');
signal1 = filtfilt(b, a, signal1);
signal2 = filtfilt(b, a, signal2);

% Compute angular velocity (derivative over time)
vel1 = gradient(signal1);
vel2 = gradient(signal2);

% Non normal, specific to method 2
signal1_norm = (signal1 - mean(signal1)) / std(signal1);
signal2_norm = (signal2 - mean(signal2)) / std(signal2);
vel1_norm = (vel1 - mean(vel1)) / std(vel1);
vel2_norm = (vel2 - mean(vel2)) / std(vel2);

phase1 = atan2(vel1_norm, signal1_norm);
phase2 = atan2(vel2_norm, signal2_norm);

crp = rad2deg(phase1 - phase2);
crp = mod(crp + 180, 360) - 180;  % wrap to [-180, 180]

% Plot
%
% Create a single figure with two subplots side by side
figure;

% Left subplot: Angle-Velocity Phase Plane for Elbow
subplot(1, 2, 1); % 1 row, 2 columns, first plot
hold on; grid on;

% Plot trajectory as blue dots
plot(signal1_norm, vel1_norm, 'b.', 'MarkerSize', 12);

% Mark start and end points
plot(signal1_norm(1), vel1_norm(1), 'go', 'MarkerSize', 10, 'LineWidth', 2); % Start
plot(signal1_norm(end), vel1_norm(end), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % End

% Axis labels and title
xlabel('Angle');
ylabel('Velocity');
title('Angle-Velocity Phase Plane (Elbow)');

% Legend
legend({'Trajectory', 'Start', 'End'}, 'Location', 'best');

% Add annotation for max velocity point
[~, idx] = max(abs(vel1_norm));
x_annot = signal1_norm(idx);
y_annot = vel1_norm(idx);
text(x_annot, y_annot, 'Max Velocity', 'Color', 'k', 'FontSize', 10, 'HorizontalAlignment', 'right');

hold off;

% Right subplot: CRP over Time
subplot(1, 2, 2); % 1 row, 2 columns, second plot
hold on; grid on;

% Plot CRP as black line
plot(crp, 'k-', 'LineWidth', 1.5);

% Axis labels and title
xlabel('Time (samples)');
ylabel('Continuous Relative Phase (degrees)');
title('CRP: Elbow vs. Shoulder Flexion/Extension');

% Legend
legend({'CRP'}, 'Location', 'best');

hold off;

% Adjust figure layout
sgtitle('Elbow Motion Analysis Method 1 Non-normalised'); % Optional: Add a super-title for the entire figure
set(gcf, 'Position', [100, 100, 1200, 400]); % Adjust figure size for better visibility

%% Methode 2: Hilbert Transform
signal1 = euler_angles_FU(:,2);  % Elbow flexion/extension (X rotation)
signal2 = euler_angles_UT(:,2);  % Shoulder flexion/extension (X rotation)

% Apply Butterworth filter to smooth signals
[b, a] = butter(order, cutoff/(Fs/2), 'low');
signal1 = filtfilt(b, a, signal1);
signal2 = filtfilt(b, a, signal2);

% Compute angular velocity (derivative over time)
vel1 = gradient(signal1);
vel2 = gradient(signal2);

% Signals
analytic_signal1 = hilbert(signal1);  % Analytic signal for elbow
analytic_signal2 = hilbert(signal2);  % Analytic signal for shoulder
phase1 = angle(analytic_signal1);     % Instantaneous phase in radians
phase2 = angle(analytic_signal2);     % Instantaneous phase in radians

% Compute continuous relative phase (CRP)
crp = rad2deg(phase1 - phase2);
crp = mod(crp + 180, 360) - 180;  % Wrap to [-180, 180]

% Plot
% Create a single figure with two subplots side by side
figure;

% Left subplot: Angle-Velocity Phase Plane for Elbow
subplot(1, 2, 1); % 1 row, 2 columns, first plot
hold on; grid on;

% Plot trajectory as blue dots
plot(analytic_signal1, vel1_norm, 'b.', 'MarkerSize', 12);

% Mark start and end points
plot(analytic_signal1(1), vel1(1), 'go', 'MarkerSize', 10, 'LineWidth', 2); % Start
plot(analytic_signal1(end), vel1(end), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % End

% Axis labels and title
xlabel('Angle');
ylabel('Velocity');
title('Angle-Velocity Phase Plane (Elbow)');

% Legend
legend({'Trajectory', 'Start', 'End'}, 'Location', 'best');

% Add annotation for max velocity point
[~, idx] = max(abs(vel1));
x_annot = analytic_signal1(idx);
y_annot = vel1(idx);
text(x_annot, y_annot, 'Max Velocity', 'Color', 'k', 'FontSize', 10, 'HorizontalAlignment', 'right');

hold off;

% Right subplot: CRP over Time
subplot(1, 2, 2); % 1 row, 2 columns, second plot
hold on; grid on;

% Plot CRP as black line
plot(crp, 'k-', 'LineWidth', 1.5);

% Axis labels and title
xlabel('Time (samples)');
ylabel('Continuous Relative Phase (degrees)');
title('CRP: Elbow vs. Shoulder Flexion/Extension');

% Legend
legend({'CRP'}, 'Location', 'best');

hold off;

% Adjust figure layout
sgtitle('Elbow Motion Analysis'); % Optional: Add a super-title for the entire figure
set(gcf, 'Position', [100, 100, 1200, 400]); % Adjust figure size for better visibility