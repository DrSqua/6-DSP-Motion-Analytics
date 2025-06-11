function plot_vel_acc(tsv, local_frame)
% With local_frame being the connection of different joint points. Examples
% are the upper_arm_m1, upper_arm_m2, lower_arm, ...

Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 10; % Cutoff frequency (Hz)

ELR = tsv{:,25:27}; % Elleboog
nFrames = size(ELR,1);
t = (1:nFrames)/Fs;  % seconds

[flexion, abduction, axRot] = return_filtered_angles(tsv, local_frame);

% First derivative = rotational velocity
velocities(:,1) = gradient(flexion, 1/Fs);  % flexion velocity (°/s)
velocities(:,2) = gradient(abduction, 1/Fs);  % abduction velocity (°/s)
velocities(:,3) = gradient(axRot, 1/Fs);  % axial rotation velocity (°/s)

% Optional: low-pass filter to smooth velocity
velocities(:,1) = butterworth_filter(velocities(:,1), Fs, cutoff, order);
velocities(:,2) = butterworth_filter(velocities(:,2), Fs, cutoff, order);
velocities(:,3) = butterworth_filter(velocities(:,3), Fs, cutoff, order);

% Second derivative = rotational acceleration
accelerations = gradient(velocities, 1/Fs);  % °/s²

% Optional: low-pass filter to smooth acceleration
accelerations(:,1) = butterworth_filter(accelerations(:,1), Fs, cutoff, order);
accelerations(:,2) = butterworth_filter(accelerations(:,2), Fs, cutoff, order);
accelerations(:,3) = butterworth_filter(accelerations(:,3), Fs, cutoff, order);


fig2 = figure;
sgtitle(sprintf("Rotational Velocity (°/s) - %s",local_frame))
subplot(3,1,1), plot(t, velocities(:,1)), ylabel('Flexion vel.')
subplot(3,1,2)  , plot(t, velocities(:,2)), ylabel('Abduction vel.')
subplot(3,1,3), plot(t, velocities(:,3)), ylabel('Axial Rot. vel.'), xlabel('Time (s)')

fig3 = figure;
sgtitle(sprintf("Rotational Acceleration (°/s²) - %s",local_frame))
subplot(3,1,1), plot(t, accelerations(:,1)), ylabel('Flexion acc.')
subplot(3,1,2), plot(t, accelerations(:,2)), ylabel('Abduction acc.')
subplot(3,1,3), plot(t, accelerations(:,3)), ylabel('Axial Rot. acc.'), xlabel('Time (s)')
end