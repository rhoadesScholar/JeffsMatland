function outBinData = initialize_BinData

global Prefs;
Prefs = define_preferences(Prefs);

BinData.Name='';
BinData.num_movies=0;
BinData.time=[];
BinData.n=[];
BinData.n_fwd=[];
BinData.n_rev=[];
BinData.n_omegaupsilon=[];
BinData.freqtime=[];
BinData.n_freq=[];


mvt = {'Rev','lRev','sRev','omegaUpsilon','omega','upsilon','reori', 'nonUpsilon_reori', ...
        'lRevOmega','sRevOmega', 'lRevUpsilon','sRevUpsilon', 'RevOmega', 'RevOmegaUpsilon', ...
        'pause','depause', 'pure_lRev', 'pure_sRev', 'pure_Rev', 'pure_omega', 'pure_upsilon', 'pure_omegaUpsilon'};

if(Prefs.swim_flag == 1)
    mvt{length(mvt)+1} = 'liquid_omega';
end
    
k=0;
for(p=1:length(mvt))
   k=k+1;
   fields{k} = sprintf('%s_freq',mvt{p});
   k=k+1;
   fields{k} = sprintf('frac_%s',mvt{p});
end

k=k+1;
fields{k} = 'speed';
k=k+1;
fields{k} = 'angspeed';
k=k+1;
fields{k} = 'ecc';
k=k+1;
fields{k} = 'curv';
k=k+1;
fields{k} = 'revlength';
k=k+1;
fields{k} = 'revSpeed';
k=k+1;
fields{k} = 'ecc_omegaupsilon';
k=k+1;
fields{k} = 'body_angle';
k=k+1;
fields{k} = 'head_angle';
k=k+1;
fields{k} = 'tail_angle';
k=k+1;
fields{k} = 'uncorr_speed';
k=k+1;
fields{k} = 'uncorr_ecc';

k=k+1;
fields{k} = 'revlength_bodybends';
k=k+1;
fields{k} = 'delta_dir_rev';
k=k+1;
fields{k} = 'delta_dir_omegaupsilon';

if(Prefs.swim_flag == 1)
    k=k+1;
    fields{k} = 'body_bends_per_sec';
end


%  transition_probabs = {'P_F_to_F','P_F_to_O','P_F_to_P','P_F_to_R','P_F_to_U','P_O_to_F',...
%      'P_O_to_O','P_O_to_P','P_O_to_R','P_O_to_U','P_P_to_F','P_P_to_O','P_P_to_P','P_P_to_R',...
%      'P_P_to_U','P_R_to_F','P_R_to_O','P_R_to_P','P_R_to_R','P_R_to_U','P_U_to_F','P_U_to_O','P_U_to_P',...
%      'P_U_to_R','P_U_to_U'};
                      
               
for(p=1:length(fields))
    s_str = sprintf('%s_s',fields{p});
    err_str = sprintf('%s_err',fields{p});

    BinData.(fields{p}) = [];
    BinData.(s_str) = [];
    BinData.(err_str) = [];
end

states = {'F','P','R','O','U'};
for(i=1:length(states))
    for(j=1:length(states))
        fieldname = sprintf('P_%s_to_%s',states{i},states{j}); 
        s_str = sprintf('%s_s',fieldname);
        err_str = sprintf('%s_err',fieldname);
        
        BinData.(fieldname) = [];
        BinData.(s_str) = [];
        BinData.(err_str) = [];
    end
end

outBinData = orderfields(update_old_BinData(BinData));

return;
end
