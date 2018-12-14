function outBinData = extract_BinData(inputBinData, start_time, end_time, start_freqtime, end_freqtime)
% outBinData = extract_BinData(inputBinData, start_time, end_time, start_freqtime, end_freqtime)

outBinData = inputBinData;

if(isfield(inputBinData,'xlabel'))
    if(~isempty(inputBinData.xlabel)) % is not time
        return;
    end
end

if(nargin<3)
    start_time=[];
    end_time=[];
end

if(isempty(start_time))
    outBinData = inputBinData;
    return;
end

if(nargin<5)
    start_freqtime = start_time;
    end_freqtime = end_time;
end

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(inputBinData);

inst_index = find(inputBinData.time >= start_time  &  inputBinData.time <= end_time);
freq_index = find(inputBinData.freqtime >= start_freqtime  &  inputBinData.freqtime <= end_freqtime);

outBinData.time = outBinData.time(inst_index);
outBinData.freqtime = outBinData.freqtime(freq_index);


for(a = 1:length(inst_n_fields))
    attribute = inst_n_fields{a};
    outBinData.(attribute) = outBinData.(attribute)(inst_index);
end

for(a = 1:length(freq_n_fields))
    attribute = freq_n_fields{a};
    outBinData.(attribute) = outBinData.(attribute)(freq_index);
end

for(a = 1:length(instantaneous_fieldnames))
    attribute = instantaneous_fieldnames{a};
    s_field = sprintf('%s_s',attribute);
    err_field = sprintf('%s_err',attribute);
    
    outBinData.(attribute) = outBinData.(attribute)(inst_index);
    outBinData.(s_field) = outBinData.(s_field)(inst_index);
    outBinData.(err_field) = outBinData.(err_field)(inst_index);
end

for(a = 1:length(freq_fieldnames))
    attribute = freq_fieldnames{a};
    s_field = sprintf('%s_s',attribute);
    err_field = sprintf('%s_err',attribute);
    
    outBinData.(attribute) = outBinData.(attribute)(freq_index);
    outBinData.(s_field) = outBinData.(s_field)(freq_index);
    outBinData.(err_field) = outBinData.(err_field)(freq_index);
end



return;
end
