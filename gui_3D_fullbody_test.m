tsv = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');

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
% 73:75 CLR	
% 76:78 CMR	
% 79:81 CML	
CLL = tsv{:,82:84};
% 85:87 MLR
% 88:90 MMR
% 91:93 MMR
MML = tsv{:,94:96};
MLL = tsv{:,97:99};

% Rechtervoorarm : EMR PMR PLR
% Rechterbovenarm: AR ELR EMR
% Torso: AR MS PX AL

% Initialize figure
fig = figure('Name', '3D Skeleton Animation');
axis equal; grid on; rotate3d on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);

for t = 1:10:200
    cla;  % Clear current figure
    hold on;

    % Upper arm
    positions_upper_arm = [AR(t, :); ELR(t, :); EMR(t, :); AR(t, :)];
    x = positions_upper_arm(:, 1);
    y = positions_upper_arm(:, 2);
    z = positions_upper_arm(:, 3);
    plot3(x, y, z, '-ro')
  
    % Lower arm
    positions_lower_arm = [EMR(t, :); PLR(t, :); PMR(t, :); EMR(t, :)];
    x = positions_lower_arm(:, 1);
    y = positions_lower_arm(:, 2);
    z = positions_lower_arm(:, 3);
    plot3(x, y, z, '-go')
    
    % Thorax
    positions_thorax = [AR(t, :); MS(t, :); AL(t, :); PX(t, :); AR(t, :)];
    x = positions_thorax(:, 1);
    y = positions_thorax(:, 2);
    z = positions_thorax(:, 3);
    plot3(x, y, z, '-bo')
    
    % Heup (pelvis)
    positions_pelvis = [SIPSR(t, :); SIPSL(t, :); SIASL(t, :); SIASR(t, :); SIPSR(t, :)];
    x = positions_pelvis(:, 1);
    y = positions_pelvis(:, 2);
    z = positions_pelvis(:, 3);
    plot3(x, y, z, '-ko')
    
    % Linker dijbeen
    positions_thigh = [CLL(t, :); SIPSL(t, :); SIASL(t, :); CLL(t, :)];
    x = positions_thigh(:, 1);
    y = positions_thigh(:, 2);
    z = positions_thigh(:, 3);
    plot3(x, y, z, '-mo')
    
    % Linker scheenbeen
    positions_thigh = [CLL(t, :); MLL(t, :); MML(t, :); CLL(t, :)];
    x = positions_thigh(:, 1);
    y = positions_thigh(:, 2);
    z = positions_thigh(:, 3);
    plot3(x, y, z, '-yo')

    % Update title and draw
    title(sprintf('3D Skeleton - Frame t = %d | Press any key to continue', t));
    drawnow;

    % Wait for any key to continue
    waitforbuttonpress;
end

%% 
clc; clear;
tsv = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');
gui_3D_fullbody(tsv, 1)