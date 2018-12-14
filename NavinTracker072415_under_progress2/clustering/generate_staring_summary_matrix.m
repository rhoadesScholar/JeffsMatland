function [summary_matrix, strainnames] = generate_staring_summary_matrix(dirlistfilename)

strainnames = read_list_file(dirlistfilename);
num_strains = length(strainnames);

for(i=1:num_strains)
    BinData = join_food_sansFood_staring_BinData(strainnames(i));
    BinDataArray(i) = alternate_binwidth_BinData(BinData, 10, 60, -300, 3600);
    
    clear('BinData');
end

[instantaneous_fieldnames, freq_fieldnames] = get_BinData_fieldnames(BinDataArray(1));
all_fieldnames = [instantaneous_fieldnames, freq_fieldnames];

inst_idx = find(BinDataArray(1).time < 0 | BinDataArray(1).time >= 180);
freq_idx = find(BinDataArray(1).freqtime < 0 | BinDataArray(1).freqtime >= 180);

for(i=1:num_strains)
    summary_matrix(i,:) = horzcat(  ... % BinDataArray(i).speed(inst_idx), BinDataArray(i).ecc(inst_idx), ...
                            BinDataArray(i).sRev_freq(freq_idx), BinDataArray(i).lRev_freq(freq_idx), ...
                            BinDataArray(i).upsilon_freq(freq_idx), BinDataArray(i).omega_freq(freq_idx), ...
                            BinDataArray(i).RevOmega_freq(freq_idx), BinDataArray(i).RevOmegaUpsilon_freq(freq_idx));

end

summary_matrix = nan_to_zero(summary_matrix);
 
return;
end
