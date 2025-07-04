function plot_vel_acc(tsv, local_frame, vel_ax1, vel_ax2, vel_ax3, acc_ax1, acc_ax2, acc_ax3)
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

plot(vel_ax1, t, velocities(:,1));
ylabel(vel_ax1, 'Flexion vel.');
xlabel(vel_ax1, 'Time (s)')
title(vel_ax1, sprintf("Rotational Velocity (°/s) - %s", local_frame));

plot(vel_ax2, t, velocities(:,2));
ylabel(vel_ax2, 'Abduction vel.');
xlabel(vel_ax2, 'Time (s)')
title(vel_ax2, sprintf("Rotational Velocity (°/s) - %s", local_frame));

plot(vel_ax3, t, velocities(:,3));
ylabel(vel_ax3, 'Axial Rot. vel.');
xlabel(vel_ax3, 'Time (s)')
title(vel_ax3, sprintf("Rotational Velocity (°/s) - %s", local_frame));

plot(acc_ax1, t, accelerations(:,1));
ylabel(acc_ax1, 'Flexion acc.');
xlabel(acc_ax1, 'Time (s)');
title(acc_ax1, sprintf("Rotational Acceleration (°/s²) - %s", local_frame));

plot(acc_ax2, t, accelerations(:,2));
ylabel(acc_ax2, 'Abduction acc.');
xlabel(acc_ax2, 'Time (s)');
title(acc_ax2, sprintf("Rotational Acceleration (°/s²) - %s", local_frame));

plot(acc_ax3, t, accelerations(:,3));
ylabel(acc_ax3, 'Axial Rot. acc.');
xlabel(acc_ax3, 'Time (s)');
title(acc_ax3, sprintf("Rotational Acceleration (°/s²) - %s", local_frame));
end