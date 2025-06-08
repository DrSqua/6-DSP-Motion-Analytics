function fig = plot_angles(tsv,local_frame)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 10; % Cutoff frequency (Hz)

switch local_frame
    case "upper_arm"
        ELR = tsv{:,25:27}; % Elleboog
        EMR = tsv{:,28:30}; % Elleboog binnen
        PMR = tsv{:,40:42}; % Pols
        PLR = tsv{:,43:45}; % Pols binnen
        
        nFrames = size(ELR,1);

        R_upp_arm = zeros(3,3,nFrames);
        R_upp_arm_child = zeros(3,3,nFrames);

        jointAngles_arm = zeros(nFrames,3);  % [flexion, abduction, rotation]
        
        for i = 1:nFrames
          % 3a) Attitude matrices (local→global)
          R_upp_arm(:,:,i) = attitude_matrix( AR(i,:)', ELR(i,:)', EMR(i,:)' );
          R_upp_arm_child(:,:,i) = attitude_matrix(AR(1,:)',ELR(1,:)',EMR(1,:)');
        
          % 3b) Relative rotation (humerus relative to scapula)
          R_rel_arm = rel_rotation_matrix(R_upp_arm(:,:,i), R_upp_arm_child(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f,a,r] = Euler_Cardan_angles(R_rel_arm);
          jointAngles_arm(i,:) = [f, a, r];
        end

        anglesFilt_arm(:,1) = butterworth_filter(jointAngles_arm(:,1), Fs, cutoff, order); 
        anglesFilt_arm(:,2) = butterworth_filter(jointAngles_arm(:,2), Fs, cutoff, order); 
        anglesFilt_arm(:,3) = butterworth_filter(jointAngles_arm(:,3), Fs, cutoff, order); 

        t = (1:nFrames)/Fs;  % time vector in seconds

        fig = figure;
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

    case 'lower_arm'
        positions = [EMR, PLR, PMR];
    case 'thorax'
        positions = [AR, MS, AL, PX];
    case 'pelvis'
        positions = [SIPSR, SIPSL, SIASL, SIASR];
    case 'tigh'
        positions = [CLL, SIPSL, SIASL];
    case 'shin'
        positions = [CLL, MLL, MML];
    otherwise
        disp('other value')
end
end