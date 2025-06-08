function [fig] = gui_localframe_3d_lifetime(tsv, local_frame)
    %GUI_3D_FULLBODY plots skeleton frame for a given t value
    MS  = tsv{:,10:12}; % Nek?
    PX  = tsv{:,13:15}; % Middenrif
    AR  = tsv{:,16:18}; % Schouder Rechts
    AL  = tsv{:,19:21}; % Schouder Links
    ELR = tsv{:,25:27}; % Elleboog
    EMR = tsv{:,28:30}; % Elleboog binnen
    PMR = tsv{:,40:42}; % Pols
    PLR = tsv{:,43:45}; % Pols binnen
    
    SIPSR = tsv{:,61:63};
    SIPSL = tsv{:,64:66};
    SIASL = tsv{:,67:69};
    SIASR = tsv{:,70:72};
    CLR = tsv{:,73:75};
    % 76:78 CMR	
    % 79:81 CML	
    CLL = tsv{:,82:84};
    % 85:87 MLR
    MMR = tsv{:,88:90};
    MLR = tsv{:,91:93};
    MML = tsv{:,94:96};
    MLL = tsv{:,97:99};
    
    switch local_frame
        case "upper_arm"
            positions = [AR, ELR, EMR];
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
            disp('other value')
    end
    
    % Initialize figure
    fig = figure('Name', '3D Skeleton for ' + local_frame);
    axis equal; grid on; rotate3d on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(3);
    
    % Colors
    colors = ['r', 'y', 'b', 'g'];
    
    % Moving frame throughout
    for i = 1:(length(positions(1, :)) / 3)
        index = 3*(i-1);
        plot3(positions(:, 1 + index), positions(:, 2 + index), positions(:, 3 + index), colors(i));
        hold on;
    end
    
    % Local frame on first and last position
    % Upper arm
    pos1 = [AR(1, :); ELR(1, :); EMR(1, :); AR(1, :)];
    pos2 = [AR(end, :); ELR(end, :); EMR(end, :); AR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Lower arm
    pos1 = [EMR(1, :); PLR(1, :); PMR(1, :); EMR(1, :)];
    pos2 = [EMR(end, :); PLR(end, :); PMR(end, :); EMR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Thorax
    pos1 = [AR(1, :); MS(1, :); AL(1, :); PX(1, :); AR(1, :)];
    pos2 = [AR(end, :); MS(end, :); AL(end, :); PX(end, :); AR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Heup (pelvis)
    pos1 = [SIPSR(1, :); SIPSL(1, :); SIASL(1, :); SIASR(1, :); SIPSR(1, :)];
    pos2 = [SIPSR(end, :); SIPSL(end, :); SIASL(end, :); SIASR(end, :); SIPSR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Linker dijbeen
    pos1 = [CLL(1, :); SIPSL(1, :); SIASL(1, :); CLL(1, :)];
    pos2 = [CLL(end, :); SIPSL(end, :); SIASL(end, :); CLL(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Linker scheenbeen
    pos1 = [CLL(1, :); MLL(1, :); MML(1, :); CLL(1, :)];
    pos2 = [CLL(end, :); MLL(end, :); MML(end, :); CLL(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Rechter dijbeen
    pos1 = [CLR(1, :); SIPSR(1, :); SIASR(1, :); CLR(1, :)];
    pos2 = [CLR(end, :); SIPSR(end, :); SIASR(end, :); CLR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    % Rechter scheenbeen
    pos1 = [CLR(1, :); MLR(1, :); MMR(1, :); CLR(1, :)];
    pos2 = [CLR(end, :); MLR(end, :); MMR(end, :); CLR(end, :)];
    plot3(pos1(:, 1), pos1(:, 2), pos1(:, 3), '-k')
    plot3(pos2(:, 1), pos2(:, 2), pos2(:, 3), '-k')
    
    hold off;