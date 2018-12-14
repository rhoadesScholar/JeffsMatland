function outBinData = update_old_BinData(BinData)

if(length(BinData)>1)
    for(i=1:length(BinData))
        outBinData(i) = update_old_BinData(BinData(i));
    end
    return;
end

% pir to reori
if(isfield(BinData,'pir_freq'))
    BinData.reori_freq = BinData.pir_freq;
    BinData.reori_freq_s = BinData.pir_freq_s;
    BinData.reori_freq_err = BinData.pir_freq_err;
    
    BinData.frac_reori = BinData.frac_pir;
    BinData.frac_reori_s = BinData.frac_pir_s;
    BinData.frac_reori_err = BinData.frac_pir_err;
end


% turn fields to upsilon
if(isfield(BinData,'omegaTurn_freq'))
    BinData.ecc_omegaupsilon = BinData.ecc_omegaturn;
    BinData.ecc_omegaupsilon_s = BinData.ecc_omegaturn_s;
    BinData.ecc_omegaupsilon_err = BinData.ecc_omegaturn_err;
    BinData.n_omegaupsilon = BinData.n_omegaturn;
    
    old_turn_fields = {'nonOmegaTurn', 'pure_nonOmegaTurn', ...
        'omegaTurn', 'pure_omegaTurn', ...
        'lRevTurn','sRevTurn','RevOmegaTurn'};
    
    new_turn_fields = {'upsilon','pure_upsilon', ...
        'omegaUpsilon', 'pure_omegaUpsilon', ...
        'lRevUpsilon','sRevUpsilon','RevOmegaUpsilon'};
    
    fields_to_rm = {'num','numfreq','pir_freq','pir_freq_s','pir_freq_err','frac_pir','frac_pir_s','frac_pir_err', 'ecc_omegaturn', 'ecc_omegaturn_s', 'ecc_omegaturn_err', 'n_omegaturn'};
    
    
    for(i=1:length(old_turn_fields))
        fn = sprintf('%s_freq', old_turn_fields{i});
        if(isfield(BinData, fn))
            fn_old = sprintf('%s_freq', old_turn_fields{i});
            fn_old_s = sprintf('%s_freq_s', old_turn_fields{i});
            fn_old_err = sprintf('%s_freq_err', old_turn_fields{i});
            
            fn_new = sprintf('%s_freq', new_turn_fields{i});
            fn_new_s = sprintf('%s_freq_s', new_turn_fields{i});
            fn_new_err = sprintf('%s_freq_err', new_turn_fields{i});
            
            BinData.(fn_new) = BinData.(fn_old);
            BinData.(fn_new_s) = BinData.(fn_old_s);
            BinData.(fn_new_err) = BinData.(fn_old_err);
            
            fields_to_rm = [fields_to_rm fn_old fn_old_s fn_old_err];
            
            fn_old = sprintf('frac_%s', old_turn_fields{i});
            fn_old_s = sprintf('frac_%s_s', old_turn_fields{i});
            fn_old_err = sprintf('frac_%s_err', old_turn_fields{i});
            
            fn_new = sprintf('frac_%s', new_turn_fields{i});
            fn_new_s = sprintf('frac_%s_s', new_turn_fields{i});
            fn_new_err = sprintf('frac_%s_err', new_turn_fields{i});
            
            BinData.(fn_new) = BinData.(fn_old);
            BinData.(fn_new_s) = BinData.(fn_old_s);
            BinData.(fn_new_err) = BinData.(fn_old_err);
            
            fields_to_rm = [fields_to_rm fn_old fn_old_s fn_old_err];
            
        end
    end

    outBinData = rmfield(BinData, fields_to_rm);
    
else
    outBinData = rmfield(BinData, {'num','numfreq','pir_freq','pir_freq_s','pir_freq_err','frac_pir','frac_pir_s','frac_pir_err'});
end

if(~isfield(outBinData,'num_movies'))
    outBinData.num_movies=1;
end
if(length(outBinData.num_movies)>1)
    outBinData.num_movies = sum(outBinData.num_movies);
end
if(outBinData.num_movies==0)
    outBinData.num_movies=1;
end
if(isempty(outBinData.num_movies))
    outBinData.num_movies=1;
end

% old files don't have these fields, so set them to NaN arrays
if(~isfield(outBinData,'uncorr_speed'))
    outBinData.uncorr_speed = zeros(1, length(outBinData.time)) + NaN;
    outBinData.uncorr_speed_s = outBinData.uncorr_speed;
    outBinData.uncorr_speed_err = outBinData.uncorr_speed;
end
if(~isfield(outBinData,'uncorr_ecc'))    
    outBinData.uncorr_ecc = zeros(1, length(outBinData.time)) + NaN;
    outBinData.uncorr_ecc_s = outBinData.uncorr_ecc;
    outBinData.uncorr_ecc_err = outBinData.uncorr_ecc;
end

if(~isfield(outBinData,'P_F_to_F'))
    states = {'F','P','R','O','U'};
    for(i=1:length(states))
        for(j=1:length(states))
            trans_probab_field = sprintf('P_%s_to_%s',states{i},states{j});
            err_field = sprintf('%s_err',trans_probab_field);
            s_field = sprintf('%s_s',trans_probab_field);
            
            outBinData.(trans_probab_field) = zeros(1, length(outBinData.time)) + NaN;
            outBinData.(err_field) = outBinData.(trans_probab_field);
            outBinData.(s_field) = outBinData.(trans_probab_field);
        end
    end
end

if(~isfield(outBinData,'revlength_bodybends'))
    outBinData.revlength_bodybends  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.revlength_bodybends_s  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.revlength_bodybends_err  = zeros(1, length(outBinData.time)) + NaN;
    
    outBinData.delta_dir_rev  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.delta_dir_rev_s  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.delta_dir_rev_err  = zeros(1, length(outBinData.time)) + NaN;
    
    outBinData.delta_dir_omegaupsilon  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.delta_dir_omegaupsilon_s  = zeros(1, length(outBinData.time)) + NaN;
    outBinData.delta_dir_omegaupsilon_err  = zeros(1, length(outBinData.time)) + NaN;
end


% nonUpsilon_reori
if(~isfield(outBinData,'nonUpsilon_reori_freq'))
    
    outBinData.frac_nonUpsilon_reori = outBinData.frac_reori - outBinData.frac_upsilon;
    outBinData.frac_nonUpsilon_reori_s = sqrt(outBinData.frac_nonUpsilon_reori.*(1-outBinData.frac_nonUpsilon_reori));
    outBinData.frac_nonUpsilon_reori_err = outBinData.frac_nonUpsilon_reori_s./sqrt(outBinData.n);
    
    outBinData.nonUpsilon_reori_freq = outBinData.reori_freq - outBinData.pure_upsilon_freq;
    outBinData.nonUpsilon_reori_freq_s = (outBinData.reori_freq_s + outBinData.pure_upsilon_freq_s)/2;
    outBinData.nonUpsilon_reori_freq_err = (outBinData.reori_freq_err + outBinData.pure_upsilon_freq_err)/2;
    
end


return;
end
