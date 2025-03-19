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
