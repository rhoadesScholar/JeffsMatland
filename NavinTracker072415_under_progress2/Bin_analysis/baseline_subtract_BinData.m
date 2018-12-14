function outBinData = baseline_subtract_BinData(BinData, baseline_time_vector)
% outBinData = baseline_subtract_BinData(BinData, baseline_time_vector)
% subtracts the mean from t=baseline_time_vector(1) to
% t=baseline_time_vector(2) for each datafield in BinData; also propagates
% errors

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(BinData);
timefields = {'time','freqtime'};
n_fields = [inst_n_fields freq_n_fields];
datafields = [instantaneous_fieldnames, freq_fieldnames];

outBinData = BinData;

for(j=1:length(datafields))
    s_field = sprintf('%s_s',datafields{j});
    err_field = sprintf('%s_err',datafields{j});
    
    [value, stddev, error, n] = segment_statistics(BinData, datafields{j}, 'mean', baseline_time_vector(1), baseline_time_vector(2));

    
    outBinData.(datafields{j}) = BinData.(datafields{j}) - value ;
    outBinData.(s_field) = sqrt( BinData.(s_field).^2 + stddev^2 );
    outBinData.(err_field) = sqrt( BinData.(err_field).^2 + error^2 );
end

return;
end
