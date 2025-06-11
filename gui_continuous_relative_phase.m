function [figure] = gui_continuous_relative_phase(compute_type, signal1, signal2, name_signal_1, name_signal_2, sampling_frequency, cutoff_frequency, order)
    % Compute type -> 'norm, notnorm, hilbert'
    % Input of signal1 and signal2 should be a 1D matrix of euler angles in
    % a given direction.

    %% Preprocessing
    % Apply Butterworth filter to smooth signals
    signal1 = butterworth_filter(signal1, sampling_frequency, cutoff_frequency, order);
    signal2 = butterworth_filter(signal2, sampling_frequency, cutoff_frequency, order);
     
    % Compute angular velocity (derivative over time)
    vel1 = gradient(signal1);
    vel2 = gradient(signal2);
    
    %% Signals
    switch compute_type
        case "norm"
            signal1_norm = (signal1 - min(signal1)) / (max(signal1) - min(signal1)) * 2 - 1;
            signal2_norm = (signal2 - min(signal2)) / (max(signal2) - min(signal2)) * 2 - 1;
            vel1_norm = (vel1 - min(vel1)) / (max(vel1) - min(vel1)) * 2 - 1;
            vel2_norm = (vel2 - min(vel2)) / (max(vel2) - min(vel2)) * 2 - 1;
            phase1 = atan2(vel1_norm, signal1_norm);
            phase2 = atan2(vel2_norm, signal2_norm);
        case "notnorm"
            transformed_signal1 = (signal1 - mean(signal1)) / std(signal1);
            transformed_signal2 = (signal2 - mean(signal2)) / std(signal2);
            vel1_norm = (vel1 - mean(vel1)) / std(vel1);
            vel2_norm = (vel2 - mean(vel2)) / std(vel2);
            phase1 = atan2(vel1_norm, transformed_signal1);
            phase2 = atan2(vel2_norm, transformed_signal2);
        case "hilbert"
            transformed_signal1 = hilbert(signal1);  % Analytic signal for elbow
            transformed_signal2 = hilbert(signal2);  % Analytic signal for shoulder
            phase1 = angle(transformed_signal1);     % Instantaneous phase in radians
            phase2 = angle(transformed_signal2);     % Instantaneous phase in radians
            vel1_norm = vel1;
        otherwise
            disp('other value')
    end
    %% CRP
    crp = rad2deg(phase1 - phase2);
    crp = mod(crp + 180, 360) - 180;  % Wrap to [-180, 180]


    %% Plot
    figure;
    
    % Left subplot: Angle-Velocity Phase Plane for Elbow
    subplot(1, 2, 1); % 1 row, 2 columns, first plot
    hold on; grid on;
    
    % Plot trajectory as blue dots
    plot(transformed_signal1, vel1_norm, 'b.', 'MarkerSize', 12);
    % Mark start and end points
    plot(transformed_signal1(1), vel1_norm(1), 'go', 'MarkerSize', 10, 'LineWidth', 2); % Start
    plot(transformed_signal1(end), vel1_norm(end), 'ro', 'MarkerSize', 10, 'LineWidth', 2); % End
    % Axis labels and title
    xlabel('Angle');
    ylabel('Velocity');
    title('Angle-Velocity Phase Plane (Elbow)');
    
    % Legend
    legend({'Trajectory', 'Start', 'End'}, 'Location', 'best');
    
    % Add annotation for max velocity point
    [~, idx] = max(abs(vel1_norm));
    x_annot = transformed_signal1(idx);
    y_annot = transformed_vel1_norm(idx);
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
    title('CRP:' + name_signal_1 + ' vs. ' + name_signal_2 + ' Shoulder Flexion/Extension');
    
    % Legend
    legend({'CRP'}, 'Location', 'best');
    
    hold off;
    
    % Adjust figure layout
    sgtitle(name_signal_1 + ' Motion Analysis'); % Optional: Add a super-title for the entire figure
    set(gcf, 'Position', [100, 100, 1200, 400]); % Adjust figure size for better visibility
end