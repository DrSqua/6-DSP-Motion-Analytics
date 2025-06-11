function gui_3D_fullbody(tsv, t, ax)
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
    CLL = tsv{:,82:84};
    MML = tsv{:,94:96};
    MLL = tsv{:,97:99};

    % Initialize figure
    cla(ax);
    hold(ax, 'on');
    grid(ax, 'on');
    axis(ax, 'equal');
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    zlabel(ax, 'Z');
    view(ax, 3);

    % Upper arm Methode 1
    positions_upper_arm = [AR(t, :); ELR(t, :); EMR(t, :); AR(t, :)];
    x = positions_upper_arm(:, 1);
    y = positions_upper_arm(:, 2);
    z = positions_upper_arm(:, 3);
    plot3(ax, x, y, z, '-ro')
    hold(ax, 'on');

    % Upper arm Methode 2
    positions_upper_arm = [AR(t, :); ELR(t, :); EMR(t, :); PLR(t, :); AR(t, :)];
    x = positions_upper_arm(:, 1);
    y = positions_upper_arm(:, 2);
    z = positions_upper_arm(:, 3);
    plot3(ax, x, y, z, '-mo')
    hold(ax, 'on');
  
    % Lower arm
    positions_lower_arm = [EMR(t, :); PLR(t, :); PMR(t, :); EMR(t, :)];
    x = positions_lower_arm(:, 1);
    y = positions_lower_arm(:, 2);
    z = positions_lower_arm(:, 3);
    plot3(ax, x, y, z, '-go')
    hold(ax, 'on');
    
    % Thorax
    positions_thorax = [AR(t, :); MS(t, :); AL(t, :); PX(t, :); AR(t, :)];
    x = positions_thorax(:, 1);
    y = positions_thorax(:, 2);
    z = positions_thorax(:, 3);
    plot3(ax, x, y, z, '-bo')
    hold(ax, 'on');
    
    % Heup (pelvis)
    positions_pelvis = [SIPSR(t, :); SIPSL(t, :); SIASL(t, :); SIASR(t, :); SIPSR(t, :)];
    x = positions_pelvis(:, 1);
    y = positions_pelvis(:, 2);
    z = positions_pelvis(:, 3);
    plot3(ax, x, y, z, '-ko')
    hold(ax, 'on');
    
    % Linker dijbeen
    positions_thigh = [CLL(t, :); SIPSL(t, :); SIASL(t, :); CLL(t, :)];
    x = positions_thigh(:, 1);
    y = positions_thigh(:, 2);
    z = positions_thigh(:, 3);
    plot3(ax, x, y, z, '-co')
    hold(ax, 'on');
    
    % Linker scheenbeen
    positions_thigh = [CLL(t, :); MLL(t, :); MML(t, :); CLL(t, :)];
    x = positions_thigh(:, 1);
    y = positions_thigh(:, 2);
    z = positions_thigh(:, 3);
    plot3(ax, x, y, z, '-yo')
    hold(ax, 'off');
end
