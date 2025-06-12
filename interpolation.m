function [interpolated_data] = interpolation(data)
% The input is the .tsv data, and it will return the .tsv file again but
% with missing data interpolated.

data_interp = data;
for col = 1:width(data)
    % processes numerical columns
    if isnumeric(data{:,col})
        % Interpolate missing values
        data_interp{:,col} = fillmissing(data{:,col}, 'linear');
    end
end

interpolated_data = data_interp;

end