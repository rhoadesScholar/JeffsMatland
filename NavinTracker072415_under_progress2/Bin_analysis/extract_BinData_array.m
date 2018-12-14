function outBinData_array = extract_BinData_array(inputBinData_array, start_time, end_time)
% outBinData_array = extract_BinData_array(inputBinData_array, start_time, end_time)

len_bindata_array = length(inputBinData_array);

if(nargin<3)
    start_time = [];
    end_time = [];
end

if(len_bindata_array==1)
    outBinData_array = extract_BinData(inputBinData_array, start_time, end_time);
    return;
end

% if the elements inputBinData_array have different lengths, truncate so
% all have the same length
mintime_vector = [];
maxtime_vector = [];
minfreqtime_vector = [];
maxfreqtime_vector = [];
for(i=1:len_bindata_array)
    time_idx = 1:length(inputBinData_array(i).time);
    freqtime_idx = 1:length(inputBinData_array(i).freqtime);
    
    if(~isempty(start_time))
        time_idx = find(inputBinData_array(i).time >= start_time & inputBinData_array(i).time <= end_time);
        freqtime_idx = find(inputBinData_array(i).freqtime >= start_time & inputBinData_array(i).freqtime <= end_time);
    end
    
    mintime_vector = [mintime_vector min(inputBinData_array(i).time(time_idx))];
    maxtime_vector = [maxtime_vector max(inputBinData_array(i).time(time_idx))];
    
    minfreqtime_vector = [minfreqtime_vector min(inputBinData_array(i).freqtime(freqtime_idx))];
    maxfreqtime_vector = [maxfreqtime_vector max(inputBinData_array(i).freqtime(freqtime_idx))];
end
max_mintime = max(mintime_vector);
min_maxtime = min(maxtime_vector);
max_minfreqtime = max(minfreqtime_vector);
min_maxfreqtime = min(maxfreqtime_vector);
clear('mintime_vector');
clear('maxtime_vector');
clear('minfreqtime_vector');
clear('maxfreqtime_vector');
for(i=1:len_bindata_array)
    outBinData_array(i) = extract_BinData(inputBinData_array(i), max_mintime, min_maxtime, max_minfreqtime, min_maxfreqtime);
end

return;
end
