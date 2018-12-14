function curve_fit_staring(dirname)

% BinData = join_food_sansFood_staring_BinData(dirname);

load N2/N2.BinData.mat

altBinData  = alternate_binwidth_BinData(BinData, 60, 60);

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(altBinData);
all_names = [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields];
% repeat the on-food segment to an hour
idx = find(altBinData.time<0);
altBinData.time = [ -3569:60:-329 altBinData.time] ;
altBinData.freqtime = [ -3569:60:-329 altBinData.freqtime] ;
for(i=1:length(all_names))
    altBinData.(all_names{i}) = [altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i}) ];
    errname = sprintf('%s_err',all_names{i});
    stdname = sprintf('%s_s',all_names{i});
    
    if(isfield(altBinData, errname))
    
    altBinData.(errname) = [altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname) ];

    altBinData.(stdname) = [altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname) ];
    end
    
end

fit_double_sigmoid(altBinData.freqtime,altBinData.RevOmegaUpsilon_freq ,altBinData.RevOmegaUpsilon_freq_err,180)

hold on


load eat4/eat4.BinData.mat

altBinData  = alternate_binwidth_BinData(BinData, 60, 60);

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(altBinData);
all_names = [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields];
% repeat the on-food segment to an hour
idx = find(altBinData.time<0);
altBinData.time = [ -3569:60:-329 altBinData.time] ;
altBinData.freqtime = [ -3569:60:-329 altBinData.freqtime] ;
for(i=1:length(all_names))
    altBinData.(all_names{i}) = [altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i})(idx) altBinData.(all_names{i}) ];
    errname = sprintf('%s_err',all_names{i});
    stdname = sprintf('%s_s',all_names{i});
    
    if(isfield(altBinData, errname))
    
    altBinData.(errname) = [altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname)(idx) altBinData.(errname) ];

    altBinData.(stdname) = [altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname)(idx) altBinData.(stdname) ];
    end
    
end

fit_double_sigmoid(altBinData.freqtime,altBinData.RevOmegaUpsilon_freq ,altBinData.RevOmegaUpsilon_freq_err,180)


return;
end

