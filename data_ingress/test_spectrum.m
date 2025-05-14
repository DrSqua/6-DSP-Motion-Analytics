tsv_data = readtable("../10Ax1.tsv", "FileType","text",'Delimiter', '\t');

raw_x = tsv_data{:,1};
input_data_spectrum_analysis(raw_x, 300, 150);