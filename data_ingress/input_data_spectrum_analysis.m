function fig = input_data_spectrum_analysis(raw_x, fs, max_f)
    % Input validation
    if ~isvector(raw_x) || isempty(raw_x)
        error('Input signal x must be a non-empty vector.');
    end
    if ~isscalar(fs) || fs <= 0
        error('Sampling frequency fs must be a positive scalar.');
    end

    % Normalize to max amplitude 1
    % raw_x = raw_x / max(abs(raw_x));
    raw_x = raw_x./ 1000;

    % Helper variables for spectogram func
    % Amount of lines:      
    %       Increasing L (more overlap, smaller hop size).
    %       Decreasing M (shorter window, more segments).
    M = 41;
    L = 30;
    g = bartlett(M);
    Ndft = 1024;
    
    % Spectogram
    [s,f,t] = spectrogram(raw_x,g,L,Ndft,fs);
    
    % Limit frequency range
    % idx = f <= max_f; % Keep frequencies between f_min and f_max
    % f = f(idx);
    % s = s(idx,:);

    % Converting to dB
    power = abs(s)'.^2;
    power = 20*log(power + eps); % add eps to avoid log(0)

    fig = figure; % Create figure (which will be returned)

    % Waterfall plot
    waterfall(f,t, power)
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
    zlabel('Power (dB)')

    % Add colorbar to show log scale
    colorbar;
end