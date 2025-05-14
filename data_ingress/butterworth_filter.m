function FilteredOutput = butterworth_filter(y, sampling_frequency, cutoff_frequency, order)
% @Input cutoff_frequency: Cutoff frequency (Hz)    
% @Input sampling_frequency: Sampling frequency (Hz)
% @Input order: Filter order    

% Normalize cutoff to Nyquist frequency
Wn = cutoff_frequency / (sampling_frequency/2);

% Defining Butterworth filter parameters
% Zero-phase filtering (recommended for analysis)
[b, a] = butter(order, Wn);

% Making sure array is valid
y_clean = y(isfinite(y));

FilteredOutput = filtfilt(b, a, y_clean);
end