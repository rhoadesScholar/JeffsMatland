function [summary_matrix_bindata_array_mean, summary_matrix_bindata_array_stddev, summary_matrix_bindata_array_n, stimsummary_length]  =  bindata_array_to_summary_matrix(BinData_array, stimulus, fieldnames)
% [summary_matrix_bindata_array_mean, summary_matrix_bindata_array_stddev, summary_matrix_bindata_array_n, stimsummary_length]  =  bindata_array_to_summary_matrix(BinData_array, stimulus, fieldnames)

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<1)
    disp('usage: [summary_matrix_bindata_array_mean, summary_matrix_bindata_array_stddev, summary_matrix_bindata_array_n]  =  bindata_array_to_summary_matrix(BinData_array, stimulus, fieldnames)')
    return;
end

if(nargin<3)
    fieldnames = [];
end

if(nargin>1)
    if(isempty(stimulus))
        stimulus = 'all';
    end
    if(~isnumeric(stimulus))
        if(strcmpi(stimulus,'time') || strcmpi(stimulus,'all'))
            stimulus = 'all';
        end
        if(strcmpi(stimulus,'staring') || strcmpi(stimulus,'stare'))
            stimulus = 'staring';
        end
    end
end


if(isempty(fieldnames))
    fieldnames = Prefs.fieldnames;
end

BinData_array_length = length(BinData_array);

[values, stddev, errors, n] = stimulus_summary_stats(BinData_array(1), stimulus, 'speed');
stimsummary_length = length(values(1,:));


summary_matrix_bindata_array_mean = zeros(BinData_array_length, length(fieldnames)*stimsummary_length) + NaN;
summary_matrix_bindata_array_stddev = summary_matrix_bindata_array_mean;
summary_matrix_bindata_array_n = summary_matrix_bindata_array_mean;

for(i=1:BinData_array_length)
    k=1;
    for(f=1:length(fieldnames))
        
        [values, stddev, errors, n] = stimulus_summary_stats(BinData_array(i), stimulus, fieldnames{f});
        
        for(j=1:stimsummary_length)
            summary_matrix_bindata_array_mean(i,k) = values(j);
            summary_matrix_bindata_array_stddev(i,k) = stddev(j);
            summary_matrix_bindata_array_n(i,k) = n(j);
            k=k+1;
        end
        
    end
end

return;
end
