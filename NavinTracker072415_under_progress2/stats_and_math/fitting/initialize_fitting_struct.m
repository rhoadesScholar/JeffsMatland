function fitting_struct = initialize_fitting_struct(BinData, stimulus, starttime, endtime)

if(nargin<4)
    starttime = min_struct_array(BinData,'time');
    endtime = max_struct_array(BinData,'time');
end

fitting_struct.name = BinData.Name;
fitting_struct.t = BinData.time;
fitting_struct.t_freq = BinData.freqtime;
fitting_struct.un_norm_simulated_fit_matrix = []; 
fitting_struct.simulated_fit_matrix = []; 
fitting_struct.m_avg=[];
fitting_struct.k_avg=[];
fitting_struct.k_std=[];
fitting_struct.un_norm_m_std=[];
fitting_struct.un_norm_m_avg=[];
fitting_struct.is_best_flag=0;
fitting_struct.model = '';

t_on = stimulus(1);
t_off = stimulus(2);
t0 = starttime;
t_end = endtime;

fitting_struct.t_on = t_on;
fitting_struct.t_off = t_off;
fitting_struct.t0 = t0;
fitting_struct.t_end = t_end;

instantaneous_fieldnames = {'speed','body_angle','head_angle','tail_angle','ecc_omegaupsilon','revlength'}; % 'ecc',body_angle

% 'pause_freq', 
freq_fieldnames = {'pure_lRev_freq','pure_sRev_freq','pure_omega_freq','pure_upsilon_freq', ...
    'lRevUpsilon_freq','lRevOmega_freq','sRevUpsilon_freq','sRevOmega_freq'};

fieldnames = [instantaneous_fieldnames freq_fieldnames];

fitting_struct.num_instantaneous_fields = length(instantaneous_fieldnames);
fitting_struct.num_freq_fields = length(freq_fieldnames);

[t_v, y_v] = BinData_to_vector(BinData, fieldnames, starttime, endtime);
fitting_struct.un_norm_y = y_v;
clear('t_v'); clear('y_v');

normalizedBinData = normalize_BinData(BinData);
[t_v, y_v] = BinData_to_vector(normalizedBinData, fieldnames, starttime, endtime);
fitting_struct.y = y_v;
fitting_struct.t_v = t_v;
clear('y_v'); clear('t_v');

% initial guesses
t_half_1 = [];
t_half_2 = [];
t_half_3 = [];
t_half_4 = [];

dd=0;
k0_matrix=[];
for(f=1:2)
    
    if(f==1) % instantaneous
        t = fitting_struct.t;
        fn = instantaneous_fieldnames;
    else % freqs
        t = fitting_struct.t_freq;
        fn = freq_fieldnames;
    end
    
    binwidth = t(3)-t(2);
    
    % pre-stim
    idx0 = find(t >= t0 & t <= t_on);
    % stim
    idx1 = find(t >= t_on & t <= t_off);
    % first half of stim
    idx1_25 = find( ( t <= ( t_on + (t_off-t_on)/2 ) ) & ( t >= t_on ) );
    % last half of stim
    idx1_5 = find( ( t >= ( t_on + (t_off-t_on)/2 ) ) & ( t <= t_off ) );
    % off-stim
    idx2 = find(t >= t_off & t <= t_end);
    % first half of off-time
    idx2_25 = find( ( t <= ( t_off + (t_end-t_off)/2 ) ) & ( t >= t_off ) );
    % last half of off-time
    idx2_5 = find( ( t >= ( t_off + (t_end-t_off)/2 ) ) & ( t <= t_end ) );
    
    for(i=1:length(fn))
        dd = dd +1;
        fitting_struct.data(dd).inst_freq_code = f;
        fitting_struct.data(dd).fieldname = fn{i};
        fitting_struct.data(dd).un_norm_y = BinData.(fn{i});
        fitting_struct.data(dd).y = normalizedBinData.(fn{i});
        
        errfield = sprintf('%s_err',fn{i});
        stdfield = sprintf('%s_s',fn{i});
        fitting_struct.data(dd).un_norm_y_err = BinData.(errfield);
        fitting_struct.data(dd).y_std = normalizedBinData.(errfield);
        
        fitting_struct.data(dd).y_fit = [];
        fitting_struct.data(dd).un_norm_y_fit = [];
        fitting_struct.data(dd).un_norm_avg_y_fit = [];
        fitting_struct.data(dd).gamma = [];
        fitting_struct.data(dd).k=[];
        fitting_struct.data(dd).k0=[];
        
        fitting_struct.data(dd).un_norm_gamma_avg=[];
        fitting_struct.data(dd).un_norm_gamma_std=[];
        fitting_struct.data(dd).un_norm_avg_y_fit=[];
        fitting_struct.data(dd).un_norm_y_fit_std=[];
        fitting_struct.data(dd).model_index = 1;
        fitting_struct.data(dd).aic = 0;
        
        y = fitting_struct.data(dd).y;

        [t_stim_on, stimOn_index] = find_closest_value_in_array(t_on, t);
        [t_stim_off, stimOff_index] = find_closest_value_in_array(t_off, t);
        
        % pre-stim
        preStimPlateau = nanmean(y(idx0));
        preStimPlateau_std = nanstd(y(idx0));
        
        % on-response
        on_max_min_flag='max';
        maxOnResponse_idx = stimOn_index;
        on_resp_mean  = nanmean(y(idx1_25));
        if(on_resp_mean >= preStimPlateau)
            maxval = max(y(idx1)); maxval = maxval(1); 
            realMaxOnResponse = maxval; realMaxOnResponse_std = BinData.(errfield)(find(y == max(y(idx1)))); realMaxOnResponse_std=realMaxOnResponse_std(1);
            maxOnResponse = preStimPlateau + (maxval -  preStimPlateau);
            while(y(maxOnResponse_idx) < maxval)
                maxOnResponse_idx=maxOnResponse_idx+1;
            end
        else
            on_max_min_flag='min';
            maxval = min(y(idx1)); maxval = maxval(1); 
            realMaxOnResponse = maxval; realMaxOnResponse_std = BinData.(errfield)(find(y == min(y(idx1)))); realMaxOnResponse_std=realMaxOnResponse_std(1);
            maxOnResponse = preStimPlateau - (preStimPlateau - maxval);
            while(y(maxOnResponse_idx) > maxval)
                maxOnResponse_idx=maxOnResponse_idx+1;
            end
        end
        if(maxOnResponse_idx >= stimOff_index)
            maxOnResponse_idx = stimOff_index - 1;
        end
        t_maxOnResponse = t(maxOnResponse_idx); 
        
        
        % on plateau
        onPlateau = nanmean(y(idx1_5));
        onPlateau_std  = nanstd(y(idx1_5));
        
%         fitting_struct.data(dd).fieldname
%         nanmean(fitting_struct.data(dd).un_norm_y(idx1_5))
        
        % time on plateau is reached
        p = maxOnResponse_idx;
        if(maxOnResponse > onPlateau)
            while(y(p) > onPlateau)
                p=p+1;
                if(p>=length(y))
                    p=stimOff_index-1;
                    break;
                end
            end
        else
            while(y(p) < onPlateau)
                p=p+1;
                if(p>=length(y))
                    p=stimOff_index-1;
                    break;
                end
            end
        end
        if(p > stimOff_index)
            p = stimOff_index;
        end
        t_on_plateau = t(p);
        
        
        % off-response
        off_resp_mean  = nanmean(y(idx2_25));
        maxOffResponse_idx = stimOff_index;
        off_max_min_flag='max';
        while(isnan(y(maxOffResponse_idx)))
            maxOffResponse_idx = maxOffResponse_idx+1;
        end
        if(off_resp_mean >= onPlateau)
            maxval = max(y(idx2)); maxval = maxval(1); 
            realMaxOffResponse = maxval; realMaxOffResponse_std = BinData.(errfield)(find(y == max(y(idx2)))); realMaxOffResponse_std=realMaxOffResponse_std(1);
            maxOffResponse = onPlateau + (max(y(idx2)) - onPlateau);
            while(y(maxOffResponse_idx) < maxval)
                maxOffResponse_idx = maxOffResponse_idx+1;
            end
        else
            off_max_min_flag='min';
            maxval = min(y(idx2)); maxval = maxval(1); 
            realMaxOffResponse = maxval; realMaxOffResponse_std = BinData.(errfield)(find(y == min(y(idx2)))); realMaxOffResponse_std=realMaxOffResponse_std(1);
            maxOffResponse = onPlateau - (onPlateau - min(y(idx2)));
            while(y(maxOffResponse_idx) > maxval)
                maxOffResponse_idx = maxOffResponse_idx+1;
            end
        end
        t_maxOffResponse = t(maxOffResponse_idx);
        
        
        % off plateau
        offPlateau = nanmean(y(idx2_5));
        offPlateau_std = nanstd(y(idx2_5));
        
        % time off plateau is reached
        p = maxOffResponse_idx;
        if(maxOffResponse > offPlateau)
            while(y(p) > offPlateau)
                p=p+1;
                if(p>=length(y))
                    p=length(y)-1;
                    break;
                end
            end
        else
            while(y(p) < offPlateau)
                p=p+1;
                if(p>=length(y))
                    p=length(y)-1;
                    break;
                end
            end
        end
        t_off_plateau = t(p);
        
                
        fitting_struct.data(dd).gamma0(1) = preStimPlateau;
        fitting_struct.data(dd).gamma0(2) = maxOnResponse;
        fitting_struct.data(dd).gamma0(3) = onPlateau;
        fitting_struct.data(dd).gamma0(4) = maxOffResponse;
        fitting_struct.data(dd).gamma0(5) = offPlateau;
        
        fitting_struct.data(dd).gamma = fitting_struct.data(dd).gamma0;
        
        if(t_maxOnResponse <= t_on)
            t_maxOnResponse = t_on + binwidth;
        end
        if(t_on_plateau <= t_maxOnResponse)
            t_on_plateau = t_maxOnResponse + binwidth;
        end
        if(t_maxOffResponse <= t_off)
            t_maxOffResponse = t_off + binwidth;
        end
        if(t_off_plateau <= t_maxOffResponse)
            t_off_plateau = t_maxOffResponse + binwidth;
        end
        
        fitting_struct.data(dd).k0(1) = log(2)/((t_maxOnResponse - t_on)/2);
        fitting_struct.data(dd).k0(2) = log(2)/((t_on_plateau - t_maxOnResponse)/2);
        fitting_struct.data(dd).k0(3) = log(2)/((t_maxOffResponse - t_off)/2);
        fitting_struct.data(dd).k0(4) = log(2)/((t_off_plateau - t_maxOffResponse)/2);
        

        
        t_half_1 = [t_half_1 (t_maxOnResponse - t_on)/2  ];
        t_half_2 = [t_half_2 (t_on_plateau - t_maxOnResponse)/2 ];
        t_half_3 = [t_half_3 (t_maxOffResponse - t_off)/2 ];
        t_half_4 = [t_half_4 (t_off_plateau - t_maxOffResponse)/2 ];
        
        
        % also store un-normalized data
        fitting_struct.data(dd).maxval = max(fitting_struct.data(dd).un_norm_y);
        fitting_struct.data(dd).un_norm_median_std = nanmedian(fitting_struct.data(dd).un_norm_y_err);
        fitting_struct.data(dd).minval = min(fitting_struct.data(dd).un_norm_y);
        fitting_struct.data(dd).range = max(fitting_struct.data(dd).un_norm_y) - fitting_struct.data(dd).minval;
    
        fitting_struct.data(dd).un_norm_gamma0 = fitting_struct.data(dd).range*fitting_struct.data(dd).gamma0 + fitting_struct.data(dd).minval;
        fitting_struct.data(dd).un_norm_gamma = fitting_struct.data(dd).un_norm_gamma0;    
        
        % deal w/ intial guesses that give negative "real" gammas
        idx = find(fitting_struct.data(dd).un_norm_gamma0<0);
        if(~isempty(idx))
            fitting_struct.data(dd).gamma0(idx) = (1e-4 - fitting_struct.data(dd).minval)/fitting_struct.data(dd).range;
            fitting_struct.data(dd).un_norm_gamma0(idx) = 1e-4;
            fitting_struct.data(dd).gamma(idx) = fitting_struct.data(dd).gamma0(idx);
            fitting_struct.data(dd).un_norm_gamma(idx) = fitting_struct.data(dd).un_norm_gamma0(idx);
        end
        
        % store the real initial gammas
        fitting_struct.data(dd).un_norm_gamma0(1) = preStimPlateau;
        fitting_struct.data(dd).un_norm_gamma0(2) = realMaxOnResponse;
        fitting_struct.data(dd).un_norm_gamma0(3) = onPlateau;
        fitting_struct.data(dd).un_norm_gamma0(4) = realMaxOffResponse;
        fitting_struct.data(dd).un_norm_gamma0(5) = offPlateau;
        fitting_struct.data(dd).un_norm_gamma0 = fitting_struct.data(dd).range*fitting_struct.data(dd).gamma0 + fitting_struct.data(dd).minval;
        fitting_struct.data(dd).un_norm_gamma = fitting_struct.data(dd).un_norm_gamma0;    
                
        fitting_struct.data(dd).un_norm_gamma0_std(1) = preStimPlateau_std;
        fitting_struct.data(dd).un_norm_gamma0_std(2) = realMaxOnResponse_std;
        fitting_struct.data(dd).un_norm_gamma0_std(3) = onPlateau_std;
        fitting_struct.data(dd).un_norm_gamma0_std(4) = realMaxOffResponse_std;
        fitting_struct.data(dd).un_norm_gamma0_std(5) = offPlateau_std;
        
        fitting_struct.data(dd).usage_vector = ones(1,length(fitting_struct.data(dd).gamma));
        fitting_struct.data(dd).k_usage_vector = ones(1,4);
        
        
        fitting_struct = fit_single_fitting_struct_data_five_state_on_off(fitting_struct, dd);
        fitting_struct.data(dd).k0 = fitting_struct.data(dd).k;
        fitting_struct.data(dd).gamma0 = fitting_struct.data(dd).gamma;
        fitting_struct.data(dd).un_norm_gamma0 = fitting_struct.data(dd).un_norm_gamma;
        
        
        for(p=1:4)
            k0_matrix(p,dd) = fitting_struct.data(dd).k0(p);
        end
        
        fitting_struct.data(dd).gamma0_original = fitting_struct.data(dd).gamma0;
        fitting_struct.data(dd).un_norm_gamma0_original = fitting_struct.data(dd).un_norm_gamma0;
        
        clear('y');
    end
end
clear('f');

fitting_struct.A=[];  fitting_struct.B=[]; fitting_struct.C=[]; fitting_struct.D=[]; fitting_struct.E=[]; 

fitting_struct.k0(1) = log(2)/((nanmedian(t_half_1) + nanmean(t_half_1))/2);
fitting_struct.k0(2) = log(2)/((nanmedian(t_half_2) + nanmean(t_half_2))/2);
fitting_struct.k0(3) = log(2)/((nanmedian(t_half_3) + nanmean(t_half_3))/2);
fitting_struct.k0(4) = log(2)/((nanmedian(t_half_4) + nanmean(t_half_4))/2);

for(p=1:4)
    fitting_struct.k0(p) = nanmedian(k0_matrix(p,:));
end
clear('k0_matrix');

fitting_struct.k = fitting_struct.k0;
fitting_struct.k0_original = fitting_struct.k0;

fitting_struct.k0_std(1) = log(2)/((nanstd(t_half_1)));
fitting_struct.k0_std(2) = log(2)/((nanstd(t_half_2)));
fitting_struct.k0_std(3) = log(2)/((nanstd(t_half_3)));
fitting_struct.k0_std(4) = log(2)/((nanstd(t_half_4)));

fitting_struct.m0(1) = fitting_struct.k0(1); % 1.0; % fitting_struct.k0(1);
fitting_struct.m0(2) = fitting_struct.k0(2); % 0.5; % fitting_struct.k0(2);
fitting_struct.m0(3) = fitting_struct.k0(3); % 1.0; % fitting_struct.k0(3);
fitting_struct.m0(4) = fitting_struct.k0(4); % 0.5; % fitting_struct.k0(4);

fitting_struct.usage_vector = [1 1 1 1];
fitting_struct.un_norm_m0 = fitting_struct.m0;
i=5;
for(d=1:length(fitting_struct.data))
    for(q=1:5)
        fitting_struct.m0(i) = fitting_struct.data(d).gamma0(q);
        fitting_struct.usage_vector = [fitting_struct.usage_vector 1];
        fitting_struct.un_norm_m0(i) = fitting_struct.data(d).un_norm_gamma0(q);
        i=i+1;
    end
    %disp([fitting_struct.data(d).fieldname, ' ',num2str(fitting_struct.data(d).gamma0)])
end
fitting_struct = calc_deg_freedom_fitting_struct(fitting_struct);

fitting_struct.f.param = {'k1','k2','k3','k4'};
i=5;
for(d=1:length(fitting_struct.data))
    for(q=1:5)
        if(fitting_struct.usage_vector(i) == 1)
            dummystring = sprintf('%s_gamma_%d',fitting_struct.data(d).fieldname,q);
        else
            dummystring = sprintf('%s_gamma_%d_ignore',fitting_struct.data(d).fieldname,q);
        end
        fitting_struct.f.param = [fitting_struct.f.param dummystring];
        i=i+1;
    end
end


return;
end

