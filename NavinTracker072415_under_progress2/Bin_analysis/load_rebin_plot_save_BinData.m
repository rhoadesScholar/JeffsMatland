function BinDataAlt = load_rebin_plot_save_BinData(localpath, binwidth, freq_binwidth, prefix)

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<4)
    prefix = prefix_from_path(localpath);
end

filename = sprintf('%s%s%s.BinData.mat',localpath, filesep, prefix);
if(file_existence(filename))
    load(filename);
else
   error('Cannot find %s', filename);
   return;
end

BinDataAlt = alternate_binwidth_BinData(BinData, binwidth, freq_binwidth);

prefix = sprintf('%s_%d_%d',prefix, binwidth, freq_binwidth);

save_BinData(BinDataAlt, localpath, prefix);

plot_data(BinDataAlt, [], [], localpath, prefix)

return;
end
