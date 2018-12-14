function outBinData = smooth_BinData(BinData, WinSize)
% outBinData = smooth_BinData(BinData, smoothwindow) % smooths with smoothwindow

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(BinData);
datafields = [instantaneous_fieldnames]; % , freq_fieldnames];
n_fields = [inst_n_fields]; % , freq_n_fields];

outBinData = BinData;

if(WinSize == 0)
    return;
end


for(j=1:length(datafields))
    outBinData.(datafields{j}) = RecSlidingWindow(outBinData.(datafields{j}),WinSize);
end

for(j=1:length(n_fields))
    outBinData.(n_fields{j}) = round(RecSlidingWindow(outBinData.(n_fields{j}),WinSize));
end

return;
end
