function normBinData = normalize_BinData(BinData)
% function BinData = normalize_BinData(BinData)
% normalizes the datafields between 0 and 1
% normalizes the errorfields with respect to the datafield limits

normBinData = BinData;

[instantaneous_fieldnames, freq_fieldnames] = get_BinData_fieldnames(BinData);
fieldnames = [instantaneous_fieldnames freq_fieldnames];

for(i=1:length(fieldnames))
    err_field = sprintf('%s_err',fieldnames{i});
    std_field = sprintf('%s_s',fieldnames{i});
    
    minval = min(BinData.(fieldnames{i}));
    range = max(BinData.(fieldnames{i})) -  minval;
    
    normBinData.(fieldnames{i}) = (BinData.(fieldnames{i}) - minval)/range;
    
    normBinData.(err_field) = (BinData.(err_field)./BinData.(fieldnames{i})).*normBinData.(fieldnames{i});
    normBinData.(std_field) = (BinData.(std_field)./BinData.(fieldnames{i})).*normBinData.(fieldnames{i});
end

return;
end
