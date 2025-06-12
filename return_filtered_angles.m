function [flexion, abduction, axialRot] = return_filtered_angles(tsv,local_frame)
Fs = 300;   % Sampling frequency (Hz)
order = 4;  % Filter order
cutoff = 10; % Cutoff frequency (Hz)
switch local_frame
    case "upper arm_m1"
        % SHOULDER motion based on R_rel_UT (m1 = method1 = no PLR)
        ELR = tsv{:,25:27}; % Elleboog
        EMR = tsv{:,28:30}; % Elleboog binnen
        PMR = tsv{:,40:42}; % Pols
        PLR = tsv{:,43:45}; % Pols binnen
        AR  = tsv{:,16:18}; % Schouder Rechts

        MS  = tsv{:,10:12};  % Thorax
        PX  = tsv{:,13:15};
        AL  = tsv{:,19:21};
        
        nFrames = size(ELR,1);
        
        R_thorax_child = [MS(1,:)', PX(1,:)', AR(1,:)', AL(1,:)'];

        % Init
        R_att_thorax = zeros(3,3,nFrames);
        R_upp_arm = zeros(3,3,nFrames);
        R_thorax = zeros(3,4,nFrames);
        jointAngles_UT = zeros(nFrames,3);  % [flexion, abduction, rotation]

        for i = 1:nFrames
          % 3a) Attitude matrices (local→global)
          R_thorax(:,:,i) = [MS(i,:)', PX(i,:)', AR(i,:)', AL(i,:)'];
          R_att_thorax(:,:,i) = rel_rot_for_N_points(R_thorax(:,:,i) ,R_thorax_child);

          R_upp_arm(:,:,i) = attitude_matrix( AR(i,:)', ELR(i,:)', EMR(i,:)' );
        
          % 3b) Relative rotation (humerus relative to scapula)
          % upper arm relative to the thorax. The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the upper arm
          % (=child) is relative to the thorax (=parent)
          R_rel_UT = rel_rotation_matrix(R_att_thorax(:,:,i), R_upp_arm(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f,a,r] = Euler_Cardan_angles(R_rel_UT);
          jointAngles_UT(i,:) = [f, a, r];
        end

        anglesFilt_arm(:,1) = butterworth_filter(jointAngles_UT(:,1), Fs, cutoff, order); 
        anglesFilt_arm(:,2) = butterworth_filter(jointAngles_UT(:,2), Fs, cutoff, order); 
        anglesFilt_arm(:,3) = butterworth_filter(jointAngles_UT(:,3), Fs, cutoff, order); 

        flexion = anglesFilt_arm(:,1);
        abduction = anglesFilt_arm(:,2);
        axialRot = anglesFilt_arm(:,3);

    case "upper arm_m2"
        % SHOULDER motion based on R_rel_UT (m2 = method2 = PLR)
        ELR = tsv{:,25:27}; % Elleboog
        EMR = tsv{:,28:30}; % Elleboog binnen
        PMR = tsv{:,40:42}; % Pols
        PLR = tsv{:,43:45}; % Pols binnen
        AR  = tsv{:,16:18}; % Schouder Rechts

        MS  = tsv{:,10:12};  % Thorax
        PX  = tsv{:,13:15};
        AL  = tsv{:,19:21};
        
        nFrames = size(ELR,1);
        
        R_thorax_child = [MS(1,:)', PX(1,:)', AR(1,:)', AL(1,:)'];
        R_upp_arm_child = [AR(1,:)', ELR(1,:)', EMR(1,:)', PLR(1,:)'];

        % Init
        R_att_thorax = zeros(3,3,nFrames);
        R_att_upp_arm = zeros(3,3,nFrames);
        R_upp_arm = zeros(3,4,nFrames);
        R_thorax = zeros(3,4,nFrames);
        jointAngles_UT = zeros(nFrames,3);  % [flexion, abduction, rotation]

        for i = 1:nFrames
          % 3a) Attitude matrices (local→global)
          R_thorax(:,:,i) = [MS(i,:)', PX(i,:)', AR(i,:)', AL(i,:)'];
          R_upp_arm(:,:,i) = [AR(i,:)', ELR(i,:)', EMR(i,:)', PLR(i,:)'];
          R_att_thorax(:,:,i) = rel_rot_for_N_points(R_thorax(:,:,i) ,R_thorax_child);
          R_att_upp_arm(:,:,i) = rel_rot_for_N_points(R_upp_arm(:,:,i) ,R_upp_arm_child);

          %R_upp_arm(:,:,i) = attitude_matrix( AR(i,:)', ELR(i,:)', EMR(i,:)' );
        
          % 3b) Relative rotation (humerus relative to scapula)
          % upper arm relative to the thorax. The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the upper arm
          % (=child) is relative to the thorax (=parent)
          R_rel_UT = rel_rotation_matrix(R_att_thorax(:,:,i), R_att_upp_arm(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f,a,r] = Euler_Cardan_angles(R_rel_UT);
          jointAngles_UT(i,:) = [f, a, r];
        end

        anglesFilt_arm(:,1) = butterworth_filter(jointAngles_UT(:,1), Fs, cutoff, order); 
        anglesFilt_arm(:,2) = butterworth_filter(jointAngles_UT(:,2), Fs, cutoff, order); 
        anglesFilt_arm(:,3) = butterworth_filter(jointAngles_UT(:,3), Fs, cutoff, order); 

        flexion = anglesFilt_arm(:,1);
        abduction = anglesFilt_arm(:,2);
        axialRot = anglesFilt_arm(:,3);

    case 'lower arm'
        % ELBOW motion based on R_rel_FU 
        PLR = tsv{:,43:45}; % Pols binnen
        EMR = tsv{:,28:30}; % Elleboog binnen
        PMR = tsv{:,40:42}; % Pols

        ELR = tsv{:,25:27}; % Elleboog
        EMR = tsv{:,28:30}; % Elleboog binnen
        PMR = tsv{:,40:42}; % Pols
        PLR = tsv{:,43:45}; % Pols binnen
        AR  = tsv{:,16:18}; % Schouder Rechts

        nFrames = size(PLR,1);
        R_upp_arm = zeros(3,3,nFrames);
        R_low_arm = zeros(3,3,nFrames);
        R_low_arm_child = zeros(3,3,nFrames);

        jointAngles_low_arm = zeros(nFrames,3);  % [flexion, abduction, rotation]
        
        for i = 1:nFrames
          % 3a) Attitude matrices (local→global)
          R_upp_arm(:,:,i) = attitude_matrix( AR(i,:)', ELR(i,:)', EMR(i,:)' ); 
          R_low_arm(:,:,i) = attitude_matrix( EMR(i,:)', PMR(i,:)', PLR(i,:)' );
        
          % 3b) Relative rotation (humerus relative to scapula)
          % lower arm relative to the upper arm. The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the lower arm
          % (=child) is relative to the upper arm (=parent)
          R_rel_FU = rel_rotation_matrix(R_upp_arm(:,:,i), R_low_arm(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f,a,r] = Euler_Cardan_angles(R_rel_FU);
          jointAngles_low_arm(i,:) = [f, a, r];
        end

        anglesFilt_low_arm(:,1) = butterworth_filter(jointAngles_low_arm(:,1), Fs, cutoff, order); 
        anglesFilt_low_arm(:,2) = butterworth_filter(jointAngles_low_arm(:,2), Fs, cutoff, order); 
        anglesFilt_low_arm(:,3) = butterworth_filter(jointAngles_low_arm(:,3), Fs, cutoff, order); 

        flexion = anglesFilt_low_arm(:,1);
        abduction = anglesFilt_low_arm(:,2);
        axialRot = anglesFilt_low_arm(:,3);

    case 'core motion'
        % CORE motion (thorax relative to pelvis) based on R_rel_TP
        MS = tsv{:,10:12};  % humerus markers
        PX  = tsv{:,13:15}; % Middenrif
        AR  = tsv{:,16:18}; % Schouder Rechts
        AL  = tsv{:,19:21}; % Schouder Links

        SIPSR = tsv{:,61:63};
        SIPSL = tsv{:,64:66};
        SIASL = tsv{:,67:69};
        SIASR = tsv{:,70:72};

        nFrames = size(MS,1);

        P_pelvis_ref = [SIPSR(1,:)', SIPSL(1,:)', SIASL(1,:)', SIASR(1,:)'];
        P_thorax_ref = [MS(1,:)', PX(1,:)', AR(1,:)', AL(1,:)'];

        R_pelvis_att = zeros(3,3,nFrames);
        R_thorax_att = zeros(3,3,nFrames);

        jointAngles_thorax = zeros(nFrames,3);  % [flexion, abduction, rotation]

        for i = 1:nFrames

          P_pelvis = [SIPSR(i,:)', SIPSL(i,:)', SIASL(i,:)', SIASR(i,:)'];
          P_thorax = [MS(i,:)', PX(i,:)', AR(i,:)', AL(i,:)'];

          R_pelvis_att(:,:,i) = rel_rot_for_N_points(P_pelvis, P_pelvis_ref);   % pelvis attitude
          R_thorax_att(:,:,i) = rel_rot_for_N_points(P_thorax, P_thorax_ref);   % thorax attitude
          
          % thorax relative to the pelvis. The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the thorax
          % (=child) is relative to the pelvis (=parent)

          R_rel_TP = rel_rotation_matrix(R_pelvis_att(:,:,i), R_thorax_att(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f3,a3,r3] = Euler_Cardan_angles(R_rel_TP);
          jointAngles_thorax(i,:) = [f3,a3,r3];
        end

        anglesFilt_thorax(:,1) = butterworth_filter(jointAngles_thorax(:,1), Fs, cutoff, order); 
        anglesFilt_thorax(:,2) = butterworth_filter(jointAngles_thorax(:,2), Fs, cutoff, order); 
        anglesFilt_thorax(:,3) = butterworth_filter(jointAngles_thorax(:,3), Fs, cutoff, order); 

        
        flexion = anglesFilt_thorax(:,1);
        abduction = anglesFilt_thorax(:,2);
        axialRot = anglesFilt_thorax(:,3);
    
    case 'thorax'
        % THORAX motion (thorax motion within the global fram) based on the 
        % attitude matrix T
        MS = tsv{:,10:12};  % humerus markers
        PX  = tsv{:,13:15}; % Middenrif
        AR  = tsv{:,16:18}; % Schouder Rechts
        AL  = tsv{:,19:21}; % Schouder Links

        SIPSR = tsv{:,61:63};
        SIPSL = tsv{:,64:66};
        SIASL = tsv{:,67:69};
        SIASR = tsv{:,70:72};

        nFrames = size(MS,1);

        P_pelvis_ref = [SIPSR(1,:)', SIPSL(1,:)', SIASL(1,:)', SIASR(1,:)'];
        P_thorax_ref = [MS(1,:)', PX(1,:)', AR(1,:)', AL(1,:)'];

        R_pelvis_att = zeros(3,3,nFrames);
        R_thorax_att = zeros(3,3,nFrames);

        jointAngles_thorax = zeros(nFrames,3);  % [flexion, abduction, rotation]

        for i = 1:nFrames
          P_thorax = [MS(i,:)', PX(i,:)', AR(i,:)', AL(i,:)'];
          R_thorax_att(:,:,i) = rel_rot_for_N_points(P_thorax, P_thorax_ref);   % thorax attitude
          
          % thorax relative to the attitude matrix of the thorax (on frame 1). The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the thorax
          % (=child) is relative to the attitude matrix T (=parent)

          R_rel_TP = rel_rotation_matrix(R_thorax_att(:,:,1), R_thorax_att(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f3,a3,r3] = Euler_Cardan_angles(R_rel_TP);
          jointAngles_thorax(i,:) = [f3,a3,r3];
        end

        anglesFilt_thorax(:,1) = butterworth_filter(jointAngles_thorax(:,1), Fs, cutoff, order); 
        anglesFilt_thorax(:,2) = butterworth_filter(jointAngles_thorax(:,2), Fs, cutoff, order); 
        anglesFilt_thorax(:,3) = butterworth_filter(jointAngles_thorax(:,3), Fs, cutoff, order); 

        flexion = anglesFilt_thorax(:,1);
        abduction = anglesFilt_thorax(:,2);
        axialRot = anglesFilt_thorax(:,3);

    case 'pelvis'
        % PELVIS motion (pelvis motion within the global frame) based on the 
        % attitude matrix 
        SIPSR = tsv{:,61:63};
        SIPSL = tsv{:,64:66};
        SIASL = tsv{:,67:69};
        SIASR = tsv{:,70:72};

        nFrames = size(SIPSR,1);

        P_ref_pelvis = [SIPSR(1,:)', SIPSL(1,:)', SIASL(1,:)', SIASR(1,:)'];  % 3x4
        P_curr_pelvis = zeros(3, 4, nFrames);
        R_pelvis_att = zeros(3, 3, nFrames);  % Attitude matrix at each frame

        jointAngles_pelvis = zeros(nFrames,3);  % [flexion, abduction, rotation]

        for i = 1:nFrames
          P_curr_pelvis(:,:,i) = [SIPSR(i,:)', SIPSL(i,:)', SIASL(i,:)', SIASR(i,:)'];
          R_pelvis_att(:,:,i) = rel_rot_for_N_points(P_curr_pelvis(:,:,i), P_ref_pelvis);  % attitude matrix

         
          
          % pelvis relative to the attitude matrix of the pelvis (on frame 1). The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the pelvis
          % (=child) is relative to the attitude matrix of the pelvis (=parent)

          R_rel_pelvis = rel_rotation_matrix(R_pelvis_att(:,:,1), R_pelvis_att(:,:,i));

          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f3,a3,r3] = Euler_Cardan_angles(R_rel_pelvis);
          jointAngles_pelvis(i,:) = [f3,a3,r3];
        end

        anglesFilt_pelvis(:,1) = butterworth_filter(jointAngles_pelvis(:,1), Fs, cutoff, order); 
        anglesFilt_pelvis(:,2) = butterworth_filter(jointAngles_pelvis(:,2), Fs, cutoff, order); 
        anglesFilt_pelvis(:,3) = butterworth_filter(jointAngles_pelvis(:,3), Fs, cutoff, order); 
       
        flexion = anglesFilt_pelvis(:,1);
        abduction = anglesFilt_pelvis(:,2);
        axialRot = anglesFilt_pelvis(:,3);

    case 'left knee'
        % LEFT KNEE motion based on R_rel_STL
        CLL = tsv{:,82:84};
        SIPSL = tsv{:,64:66};
        SIASL = tsv{:,67:69};
        MML = tsv{:,94:96};
        MLL = tsv{:,97:99};

        nFrames = size(CLL,1);

        R_thigh = zeros(3,3,nFrames);
        R_shin = zeros(3,3,nFrames);
        R_thigh_att = zeros(3,3,nFrames);
        R_shin_att = zeros(3,3,nFrames);

        P_tigh_ref = [CLL(1,:)', SIPSL(1,:)', SIASL(1,:)'];
        P_shin_ref = [CLL(1,:)', MLL(1,:)', MML(1,:)'];

        nFrames = size(CLL,1);

        jointAngles_tigh = zeros(nFrames,3);  % [flexion, abduction, rotation]
        
        for i = 1:nFrames
          P_tigh = [CLL(i,:)', SIPSL(i,:)', SIASL(i,:)'];
          P_shin = [CLL(i,:)', MLL(i,:)', MML(i,:)'];

          % 3a) Attitude matrices (local→global)
          R_thigh(:,:,i) = attitude_matrix( CLL(i,:)', SIPSL(i,:)', SIASL(i,:)' );
          R_shin(:,:,i) = attitude_matrix( CLL(i,:)', MLL(i,:)', MML(i,:)' );

          %R_thigh_att(:,:,i) = rel_rot_for_N_points(P_tigh, P_tigh_ref);
          %R_shin_att(:,:,i) = rel_rot_for_N_points(P_shin, P_shin_ref);

          % 3b) Relative rotation (humerus relative to scapula)
          % shank relative to the tigh. The function
          % rel_rotation_matrix takes as inputs (parent, child) with the
          % child being relative to the parent. So here the shank
          % (=child) is relative to the tigh (=parent)

          R_rel_tigh = rel_rotation_matrix(R_thigh(:,:,i), R_shin(:,:,i));
        
          % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
          [f,a,r] = Euler_Cardan_angles(R_rel_tigh);
          jointAngles_tigh(i,:) = [f, a, r];
        end

        anglesFilt_tigh(:,1) = butterworth_filter(jointAngles_tigh(:,1), Fs, cutoff, order); 
        anglesFilt_tigh(:,2) = butterworth_filter(jointAngles_tigh(:,2), Fs, cutoff, order); 
        anglesFilt_tigh(:,3) = butterworth_filter(jointAngles_tigh(:,3), Fs, cutoff, order); 
      
        flexion = anglesFilt_tigh(:,1);
        abduction = anglesFilt_tigh(:,2);
        axialRot = anglesFilt_tigh(:,3);
        
    % case 'shin'
    %     CLL = tsv{:,82:84};
    %     MML = tsv{:,94:96};
    %     MLL = tsv{:,97:99};
    % 
    %     nFrames = size(CLL,1);
    % 
    %     R_shin = zeros(3,3,nFrames);
    %     R_shin_child = zeros(3,3,nFrames);
    % 
    %     jointAngles_shin = zeros(nFrames,3);  % [flexion, abduction, rotation]
    % 
    %     for i = 1:nFrames
    %       % 3a) Attitude matrices (local→global)
    %       R_shin(:,:,i) = attitude_matrix( CLL(i,:)', MML(i,:)', MLL(i,:)' );
    %       R_shin_child(:,:,i) = attitude_matrix(CLL(1,:)',MML(1,:)',MLL(1,:)');
    % 
    %       % 3b) Relative rotation (humerus relative to scapula)
    %       R_rel_shin = rel_rotation_matrix(R_shin(:,:,i), R_shin_child(:,:,i));
    % 
    %       % 3c) Cardan (X–Y–Z) angles in deg: [flexion, abduction, axialRot]
    %       [f,a,r] = Euler_Cardan_angles(R_rel_shin);
    %       jointAngles_shin(i,:) = [f, a, r];
    %     end
    % 
    %     anglesFilt_shin(:,1) = butterworth_filter(jointAngles_shin(:,1), Fs, cutoff, order); 
    %     anglesFilt_shin(:,2) = butterworth_filter(jointAngles_shin(:,2), Fs, cutoff, order); 
    %     anglesFilt_shin(:,3) = butterworth_filter(jointAngles_shin(:,3), Fs, cutoff, order); 
    % 
    %     t = (1:nFrames)/Fs;  % time vector in seconds
    % 
    %     fig = figure;
    %     sgtitle("shin")
    %     subplot(3,1,1)
    %    plot(ax, t, anglesFilt_shin(:,1))
    %     ylabel('Flexion (°)')
    %     title('Glenohumeral Joint Angles')
    % 
    %     subplot(3,1,2)
    %    plot(ax, t, anglesFilt_shin(:,2))
    %     ylabel('Abduction (°)')
    % 
    %     subplot(3,1,3)
    %    plot(ax, t, anglesFilt_shin(:,3))
    %     ylabel('Axial Rot. (°)')
    %     xlabel('Time (s)')

    otherwise
        disp('other value')
end
end