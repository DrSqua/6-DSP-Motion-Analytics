%% Load Data

tsv_data = readtable("10Ax1.tsv", "FileType","text",'Delimiter', '\t');

%[b,a] = butter(4,fc/(fs/2));

HR_data = tsv_data{:,1:3};
disp('Nu komt HR data')
HR_x = HR_data(:,1);
HR_y = HR_data(:,2);
HR_z = HR_data(:,3);


%% Plot
plot3(HR_x, HR_y, HR_z)
axis equal
xlabel("X Space")
ylabel("Y Space")
zlabel("Z Space")

%%
%% Load marker data
data = readtable("10Ax1_view.xlsx");

% Veronderstel dat we markers hebben zoals: SCAP1_x, SCAP1_y, SCAP1_z, HUM1_x, ...
% Zet ze om naar matrices (positie in tijd: Nx3)
SCAP1 = data{:, {'SCAP1_x', 'SCAP1_y', 'SCAP1_z'}};
SCAP2 = data{:, {'SCAP2_x', 'SCAP2_y', 'SCAP2_z'}};
SCAP3 = data{:, {'SCAP3_x', 'SCAP3_y', 'SCAP3_z'}};

HUM1 = data{:, {'HUM1_x', 'HUM1_y', 'HUM1_z'}};
HUM2 = data{:, {'HUM2_x', 'HUM2_y', 'HUM2_z'}};
HUM3 = data{:, {'HUM3_x', 'HUM3_y', 'HUM3_z'}};



