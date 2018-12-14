function BinData = bin_and_average_all_tracks(Tracks, stimulus, starttime, endtime)
% BinData = bin_and_average_all_tracks(Tracks, stimulus)

global Prefs;

multistim_flag=0;
if(nargin<2)
    stimulus=[];
end

if(~isempty(stimulus))
    i=1;
    while(i<=length(stimulus(:,1)))
        if(abs(stimulus(i,2) - stimulus(i,1)) < 1e-4)
            stimulus(i,:)=[];
        else
            i=i+1;
        end
    end
    
    prevstim=0;
    for(i=1:length(stimulus(:,1)))
        if(stimulus(i,3) > 0)
            if(prevstim==0)
                prevstim=stimulus(i,3);
            else
                if(prevstim~=stimulus(i,3))
                    multistim_flag=1;
                end
                if((stimulus(i,3)-stimulus(i,2))<=1)
                    multistim_flag=1;
                end
            end
        end
    end
end

Tracks = make_double(Tracks);

total_num_frames = 0;
for(i=1:length(Tracks))
    total_num_frames = total_num_frames + Tracks(i).NumFrames;
end

original_num_frames = total_num_frames;
original_num_tracks = length(Tracks);

disp([sprintf('Binning %d wormframes from %d tracks\t%s',original_num_frames, original_num_tracks, timeString())])

if(total_num_frames==0 || isempty(Tracks))
    BinData = initialize_BinData;
    return;
end

if(nargin==4)
    BinData = actual_bin_tracks(Tracks, starttime, endtime);
    return;
end

%if(isempty(stimulus) || multistim_flag==1)
    BinData = actual_bin_tracks(Tracks);
    return;
%end

BinData = initialize_BinData;
secs_per_frame = 1/Tracks(1).FrameRate;

starttime = min_struct_array(Tracks,'Time');
BinA = actual_bin_tracks(Tracks, starttime, stimulus(1,1)-secs_per_frame);
BinData = hookup_BinData(BinData, BinA); clear('BinA');

for(i=1:length(stimulus(:,1)))
    endstim = stimulus(i,2);
    while(endstim - stimulus(i,1) <= Prefs.BinSize)
        endstim = endstim + secs_per_frame;
    end
    
    BinA = actual_bin_tracks(Tracks, stimulus(i,1), endstim);
    BinData = hookup_BinData(BinData, BinA); clear('BinA');
    
    if(i==length(stimulus(:,1)))
        endtime = max_struct_array(Tracks,'Time');
    else
        endtime = stimulus(i+1,1)-secs_per_frame;
    end
    
    
    if(endstim+secs_per_frame < endtime)
        BinA = actual_bin_tracks(Tracks, endstim+secs_per_frame, endtime);
        BinData = hookup_BinData(BinData, BinA); clear('BinA');
    end
end

BinData = trim_bins(BinData);

return;
end

function BinData = actual_bin_tracks(Tracks, starttime, endtime)
% BinData = actual_bin_tracks(Tracks, starttime, endtime)

global Prefs;

FrameRate = Tracks(1).FrameRate;

epsilon=1e-4;

if(nargin<=2)
    starttime = min_struct_array(Tracks,'Time');
    endtime = max_struct_array(Tracks,'Time');
end

% starttime = custom_round(starttime,0.01);
% endtime = custom_round(endtime,0.01);


ringmiss_state_code = num_state_convert('ringmiss');
fwdstate_state_code = num_state_convert('fwd_state');

pause_state_code = num_state_convert('pause');
depause_state_code = num_state_convert('fwd');

sRev_state_code = num_state_convert('sRev');
lRev_state_code = num_state_convert('lRev');
upsilon_state_code = num_state_convert('upsilon');
omega_state_code = num_state_convert('omega');

lRevOmega_state_code = num_state_convert('lRevOmega');
sRevOmega_state_code = num_state_convert('sRevOmega');
lRevUpsilon_state_code = num_state_convert('lRevUpsilon');
sRevUpsilon_state_code = num_state_convert('sRevUpsilon');

OmegalRev_state_code = num_state_convert('OmegalRev');
OmegasRev_state_code = num_state_convert('OmegasRev');
UpsilonlRev_state_code = num_state_convert('UpsilonlRev');
UpsilonsRev_state_code = num_state_convert('UpsilonsRev');


pure_lRev_state_code = num_state_convert('pure_lRev');
pure_sRev_state_code = num_state_convert('pure_sRev');
pure_omega_state_code = num_state_convert('pure_omega');
pure_upsilon_state_code = num_state_convert('pure_upsilon');

if(Prefs.swim_flag == 1)
    liquid_omega_state_code = num_state_convert('liquid_omega');
end

NumTracks = length(Tracks);

num_wormFrames = 0;
for(i=1:length(Tracks))
    num_wormFrames = num_wormFrames + length(Tracks(i).Time);
end


Tracks = sort_tracks_by_starttime(Tracks);

SpeedEccBinSize = Prefs.SpeedEccBinSize;
FreqBinSize = Prefs.FreqBinSize;

BinData = initialize_BinData;

% linear arrays containing all the info in the Tracks structure, for all Tracks
% array = [x1 x2 x3 x4 y1 y2 y3 z1 z2 z3 z4 z5 z6] for tracks x, y, and z

fwd_fields = {'speed', 'angspeed',  'ecc', 'curv', 'body_angle' 'head_angle' 'tail_angle'};
rev_fields = {'revlength','revSpeed','revlength_bodybends','delta_dir_rev'};
omegaupsilon_fields = {'ecc_omegaupsilon','delta_dir_omegaupsilon'};
universal_fields = {};

if(isfield(Tracks(1),'custom_metric'))
    fwd_fields = [fwd_fields 'custom_metric'];
end
if(isfield(Tracks(1),'odor_distance'))
    fwd_fields = [fwd_fields 'odor_distance'];
end
if(isfield(Tracks(1),'odor_angle'))
    fwd_fields = [fwd_fields 'odor_angle'];
end
if(isfield(Tracks(1),'model_odor_conc'))
    fwd_fields = [fwd_fields 'model_odor_conc'];
end
if(isfield(Tracks(1),'model_odor_gradient'))
    fwd_fields = [fwd_fields 'model_odor_gradient'];
end
     

if(Prefs.swim_flag == 1)
    universal_fields = {'body_bends_per_sec'};
end

u=1;
while(u<=length(universal_fields))
    if(~isfield(Tracks(1),universal_fields{u}))
        universal_fields(u) = [];
    else
        u=u+1;
    end
end

universal_fields = [universal_fields {'uncorr_speed','uncorr_ecc'}];

instantaneous_fields = [fwd_fields, rev_fields omegaupsilon_fields universal_fields];
mvt_fields = {  'lRev', 'pure_lRev', 'sRev', 'pure_sRev', 'Rev', 'pure_Rev', ...
    'omega', 'pure_omega', 'upsilon', 'pure_upsilon', 'omegaUpsilon','pure_omegaUpsilon', ...
    'lRevOmega', 'sRevOmega', 'lRevUpsilon', 'sRevUpsilon', 'RevOmega', 'RevOmegaUpsilon', 'reori',  ...
    'pause','depause'};

if(Prefs.swim_flag == 1)
    mvt_fields{length(mvt_fields)+1} = 'liquid_omega';
end


for(f=1:length(mvt_fields))
    freq_fields{f} = sprintf('%s_freq', mvt_fields{f});
    frac_fields{f} = sprintf('frac_%s', mvt_fields{f});
end



all_fields = [instantaneous_fields freq_fields frac_fields];

for(f=1:length(all_fields))
    cmd = sprintf('%s = []; %s_s = []; %s_err = [];', all_fields{f}, all_fields{f}, all_fields{f});
    eval(cmd);
end

% sprintf('Analysing %d tracks',NumTracks)

time = zeros(1,num_wormFrames); % [];
state = zeros(1,num_wormFrames,'single'); % [];

j=1;
for tr = 1:NumTracks
    trlength = length(Tracks(tr).Time);
    time(j:j+trlength-1) = double(Tracks(tr).Time);
    state(j:j+trlength-1) = Tracks(tr).State;
    j=j+trlength;
end

% sort arrays by time .. makes searching much much much faster
[time, idx] = sort(time);
state = state(idx);

del_idx = find(time < (starttime-epsilon) | time > (endtime+epsilon));
time(del_idx) = [];
state(del_idx) = [];
[time, idx] = sort(time);
state = state(idx);

state_actual = state;
state_floor = floor(state);

% average the instantaneous values for each equivalent frame in all tracks
timelist = starttime:1/FrameRate:endtime; 
% timelist = custom_round(timelist, 0.01);
timelist_length = length(timelist);
time_length = length(time);
tt = 1;

for t = 1:timelist_length
    
    % timeindex is an array of array-indicies where the time equals timelist(t)
    % timeindex = find(time <= timelist(t) + epsilon &  time >= timelist(t) - epsilon);
    [timeindex, tt] = find_timeindex(tt, timelist(t), epsilon, time, time_length);
    
    
    % lists of  animals that are moving forward and not affected by the ring
    clear('fwdindex');  fwdindex=[];
    clear('not_ring_index'); not_ring_index=[];
    clear('rev_index'); rev_index=[];
    clear('reori_index'); reori_index=[];
    clear('omega_and_upsilon_index'); omega_and_upsilon_index=[];
    
    j=1; k=1; r=1; p=1; ot=1;
    for(q=1:length(timeindex))
        if(state_floor(timeindex(q)) < ringmiss_state_code)  % not in a ring or missing
            
            not_ring_index(k) = timeindex(q);  % this frame is not affected by the ring or is not otherwise missing
            k=k+1;
            if(state_floor(timeindex(q)) <= fwdstate_state_code)  % 1 forward state
                fwdindex(j) = timeindex(q);
                j=j+1;
            else % non-forward ... ie: a reorientation of some sort
                reori_index(p) = timeindex(q);
                p=p+1;
                if(abs(state_floor(timeindex(q)) - sRev_state_code)<=epsilon || abs(state_floor(timeindex(q)) - lRev_state_code)<=epsilon)
                    rev_index(r) = timeindex(q);
                    r=r+1;
                else % if not reversing, it must be an omega or turn
                    omega_and_upsilon_index(ot) = timeindex(q);
                    ot = ot+1;
                end
            end
        end
    end
    
    n(t) = length(not_ring_index); % number of animals at time t not affected by the ring
    
    if(n(t)<=1) % avoid divide by zeros
        n(t)=0;
        
        for(f=1:length(mvt_fields))
            cmd = sprintf('frac_%s(t)=NaN;', mvt_fields{f});
            eval(cmd);
        end
    else
        
        % fraction of ring-free animals at time t in a particular non-forward state
        
        frac_pause(t) = length(find(abs(state_actual(fwdindex) - pause_state_code)<=epsilon) )/n(t);
        frac_depause(t) = length(find(abs(state_actual(fwdindex) - depause_state_code)<=epsilon) )/n(t);
        
        frac_omegaUpsilon(t) =  length(omega_and_upsilon_index)/n(t);
        frac_omega(t) = length(find(abs(state_floor(omega_and_upsilon_index) - omega_state_code)<=epsilon) )/n(t);
        frac_upsilon(t) = length(find(abs(state_floor(omega_and_upsilon_index) - upsilon_state_code)<=epsilon) )/n(t);
        
        frac_Rev(t) =   length(rev_index)/n(t);
        frac_lRev(t) =  length(find(abs(state_floor(rev_index) - lRev_state_code)<=epsilon) )/n(t);
        frac_sRev(t) =  length(find(abs(state_floor(rev_index) - sRev_state_code)<=epsilon) )/n(t);
        
        frac_lRevOmega(t) = length(find(abs(state_actual(reori_index) - lRevOmega_state_code)<=epsilon)) + length(find(abs(state_actual(reori_index) - OmegalRev_state_code)<=epsilon));
        frac_sRevOmega(t) = length(find(abs(state_actual(reori_index) - sRevOmega_state_code)<=epsilon)) + length(find(abs(state_actual(reori_index) - OmegasRev_state_code)<=epsilon));
        frac_lRevUpsilon(t) = length(find(abs(state_actual(reori_index) - lRevUpsilon_state_code)<=epsilon)) + length(find(abs(state_actual(reori_index) - UpsilonlRev_state_code)<=epsilon));
        frac_sRevUpsilon(t) = length(find(abs(state_actual(reori_index) - sRevUpsilon_state_code)<=epsilon)) + length(find(abs(state_actual(reori_index) - UpsilonsRev_state_code)<=epsilon));
        
        frac_RevOmega(t) = frac_lRevOmega(t) + frac_sRevOmega(t);
        frac_RevOmegaUpsilon(t) = frac_lRevOmega(t) + frac_sRevOmega(t) + frac_lRevUpsilon(t) + frac_sRevUpsilon(t);
        
        frac_lRevOmega(t) = frac_lRevOmega(t)/n(t);
        frac_sRevOmega(t) = frac_sRevOmega(t)/n(t);
        frac_lRevUpsilon(t) = frac_lRevUpsilon(t)/n(t);
        frac_sRevUpsilon(t) = frac_sRevUpsilon(t)/n(t);
        frac_RevOmega(t) = frac_RevOmega(t)/n(t);
        frac_RevOmegaUpsilon(t) = frac_RevOmegaUpsilon(t)/n(t);
        
        frac_pure_lRev(t) = length(find(abs(state_actual(rev_index) - pure_lRev_state_code)<=epsilon));
        frac_pure_sRev(t) = length(find(abs(state_actual(rev_index) - pure_sRev_state_code)<=epsilon));
        frac_pure_omega(t) = length(find(abs(state_actual(omega_and_upsilon_index) - pure_omega_state_code)<=epsilon));
        frac_pure_upsilon(t) = length(find(abs(state_actual(omega_and_upsilon_index) - pure_upsilon_state_code)<=epsilon));
        frac_pure_Rev(t) = frac_pure_lRev(t) + frac_pure_sRev(t);
        frac_pure_omegaUpsilon(t) = frac_pure_omega(t) + frac_pure_upsilon(t);
        
        frac_pure_lRev(t) = frac_pure_lRev(t)/n(t);
        frac_pure_sRev(t) = frac_pure_sRev(t)/n(t);
        frac_pure_omega(t) = frac_pure_omega(t)/n(t);
        frac_pure_upsilon(t) = frac_pure_upsilon(t)/n(t);
        frac_pure_Rev(t) = frac_pure_Rev(t)/n(t);
        frac_pure_omegaUpsilon(t) = frac_pure_omegaUpsilon(t)/n(t);
        
        frac_reori(t) = length(reori_index)/n(t);
        
        if(Prefs.swim_flag == 1)
            frac_liquid_omega(t) =  length(find(abs(state_floor(reori_index) - liquid_omega_state_code)<=epsilon) )/n(t);
        end
    end
end
clear('timeindex');
clear('fwdindex');
clear('not_ring_index');
clear('rev_index');
clear('reori_index');
clear('omega_and_upsilon_index');

clear('time');
clear('state_actual');
clear('state');
clear('state_floor');


% std dev and errors for fraction states
errdenom = sqrt(n);
for(f=1:length(mvt_fields))
    cmd = sprintf('frac_%s_s = sqrt(frac_%s.*(1-frac_%s));', mvt_fields{f}, mvt_fields{f}, mvt_fields{f}); eval(cmd);
    cmd = sprintf('frac_%s_err = frac_%s_s./errdenom;',mvt_fields{f}, mvt_fields{f}); eval(cmd);
end

% bin, average, and propagate errors for instantaneous values
% create an array spaced every SpeedEccBinSize seconds from starttime to endtime

bins = starttime:SpeedEccBinSize:endtime; 
% bins = custom_round(bins, 0.01);

tt=1;
for i = 1:length(bins)
    % timeindex is an array of frame indicies where the time is within the bin of interest
    
    [timeindex, tt] = find_timeindex(tt, bins(i), SpeedEccBinSize, timelist, timelist_length);
    
    BinData.time(i) = nanmean(timelist(timeindex));
    
    BinData.n(i) = nanmean(n(timeindex)); % average number of non-ring affected animals in the bin
    
    fieldnames = [frac_fields];
    
    cmd = '';
    for(p=1:length(fieldnames))
        fn = char(fieldnames{p});
        cmd = [cmd  sprintf('BinData = calc_and_propagate_BinData_error(BinData, i, timeindex, ''%s'', %s, %s_s, %s_err); ', fn, fn, fn, fn) ];
    end
    eval(cmd);
    clear('cmd');
    
end
clear('timeindex');
clear('n');
clear('fieldnames');

time_vector = starttime:(1/FrameRate):endtime; 
% time_vector = custom_round(time_vector, 0.01);

state = create_attribute_matrix_from_Tracks(Tracks, 'State',starttime,endtime);
state = matrix_replace(state,'>=',ringmiss_state_code,NaN);
state_floor = floor(state);

fwd_state = matrix_replace(state_floor,'>',fwdstate_state_code, NaN); % replace non-fwd w/ NaN
fwd_state(~isnan(fwd_state)) = 1;

curv_state = zeros(size(state)) + NaN;
curv_state(find(state <= fwdstate_state_code)) = 1;
curv_state(find(abs(state - pure_upsilon_state_code)<=epsilon)) = 1;
curv_state(find(abs(state - pure_omega_state_code)<=epsilon)) = 1;



rev_state = zeros(size(state_floor)) + NaN;
rev_state(find(abs(state_floor - lRev_state_code)<=epsilon)) = 1;
rev_state(find(abs(state_floor - sRev_state_code)<=epsilon)) = 1;

omegaupsilon_state  = zeros(size(state_floor)) + NaN;
omegaupsilon_state(find(abs(state_floor - omega_state_code)<=epsilon)) = 1;
omegaupsilon_state(find(abs(state_floor - upsilon_state_code)<=epsilon)) = 1;

univ_state = matrix_replace(state_floor,'>=',num_state_convert('ring'), NaN); % replace ring and missing w/ NaN
univ_state(univ_state < num_state_convert('ring')) = 1; % non-ring/non-missing are 1


speed_all = create_attribute_matrix_from_Tracks(Tracks, 'Speed',starttime,endtime);
angspeed_all = create_attribute_matrix_from_Tracks(Tracks, 'AngSpeed',starttime,endtime);
ecc_all = create_attribute_matrix_from_Tracks(Tracks, 'Eccentricity',starttime,endtime);
curv_all = create_attribute_matrix_from_Tracks(Tracks, 'Curvature',starttime,endtime);
body_angle_all = create_attribute_matrix_from_Tracks(Tracks, 'body_angle',starttime,endtime);
head_angle_all = create_attribute_matrix_from_Tracks(Tracks, 'head_angle',starttime,endtime);
tail_angle_all = create_attribute_matrix_from_Tracks(Tracks, 'tail_angle',starttime,endtime);
revlength_all = create_attribute_matrix_from_Tracks(Tracks, 'revlength',starttime,endtime);
revSpeed_all = create_attribute_matrix_from_Tracks(Tracks, 'revSpeed',starttime,endtime);
ecc_omegaupsilon_all = create_attribute_matrix_from_Tracks(Tracks, 'ecc_omegaupsilon',starttime,endtime);

revlength_bodybends_all = create_attribute_matrix_from_Tracks(Tracks, 'revlength_bodybends',starttime,endtime);
delta_dir_rev_all = abs(create_attribute_matrix_from_Tracks(Tracks, 'delta_dir_rev',starttime,endtime));
delta_dir_omegaupsilon_all = abs(create_attribute_matrix_from_Tracks(Tracks, 'delta_dir_omegaupsilon',starttime,endtime));

if(isfield(Tracks(1),'custom_metric'))
    custom_metric_all = create_attribute_matrix_from_Tracks(Tracks, 'custom_metric',starttime,endtime);
end
if(isfield(Tracks(1),'odor_distance'))
    odor_distance_all = create_attribute_matrix_from_Tracks(Tracks, 'odor_distance',starttime,endtime);
end
if(isfield(Tracks(1),'odor_angle'))
    odor_angle_all = create_attribute_matrix_from_Tracks(Tracks, 'odor_angle',starttime,endtime);
end
if(isfield(Tracks(1),'model_odor_conc'))
    model_odor_conc_all = create_attribute_matrix_from_Tracks(Tracks, 'model_odor_conc',starttime,endtime);
end
if(isfield(Tracks(1),'model_odor_gradient'))
    model_odor_gradient_all = create_attribute_matrix_from_Tracks(Tracks, 'model_odor_gradient',starttime,endtime);
end
    


for(u=1:length(universal_fields))
    if(isfield(Tracks(1),universal_fields{u}))
        cmd = sprintf('%s_all = create_attribute_matrix_from_Tracks(Tracks, ''%s'',starttime,endtime);', universal_fields{u}, universal_fields{u});
        eval(cmd);
    end
end

uncorr_speed_all = speed_all;
uncorr_ecc_all = ecc_all;

% these matrix multiplications effectively get rid of irrelevant values for
% these attributes
speed_all = speed_all.*fwd_state;
ecc_all = ecc_all.*fwd_state;
angspeed_all = abs(angspeed_all.*fwd_state);

curv_all = (curv_all.*curv_state);
if(~isfield(Tracks(1),'custom_metric'))
    curv_all = abs(curv_all);
end

body_angle_all = abs(body_angle_all.*fwd_state);
head_angle_all = abs(head_angle_all.*fwd_state);
tail_angle_all = abs(tail_angle_all.*fwd_state);

if(isfield(Tracks(1),'custom_metric'))
    custom_metric_all = abs(custom_metric_all.*fwd_state);
end
if(isfield(Tracks(1),'odor_distance'))
    odor_distance_all = abs(odor_distance_all.*fwd_state);
end
if(isfield(Tracks(1),'odor_angle'))
    odor_angle_all = abs(odor_angle_all.*fwd_state);
end
if(isfield(Tracks(1),'model_odor_conc'))
    model_odor_conc_all = abs(model_odor_conc_all.*fwd_state);
end
if(isfield(Tracks(1),'model_odor_gradient'))
    model_odor_gradient_all = abs(model_odor_gradient_all.*fwd_state);
end
    

revlength_all = revlength_all.*rev_state;
revSpeed_all = revSpeed_all.*rev_state;
revlength_bodybends_all = revlength_bodybends_all.*rev_state;
delta_dir_rev_all = delta_dir_rev_all.*rev_state;

ecc_omegaupsilon_all = ecc_omegaupsilon_all.*omegaupsilon_state;
delta_dir_omegaupsilon_all = delta_dir_omegaupsilon_all.*omegaupsilon_state;


fieldnames = [instantaneous_fields];
for(p=1:length(fieldnames))
    fn = char(fieldnames{p});
    fn_s = sprintf('%s_s',fn);
    fn_err = sprintf('%s_err',fn);
    
    BinData.(fn) = zeros(1,length(bins),'single') +NaN;
    BinData.(fn_s) = zeros(1,length(bins),'single') +NaN;
    BinData.(fn_err) = zeros(1,length(bins),'single') +NaN;
end

max_dim = max(size(state));

for(t=1:length(bins)-1)
    BinData.time(t) = (bins(t) + bins(t+1))/2;
    
    for(p=1:length(fieldnames))
        fn = char(fieldnames{p});
        eval(sprintf('%s = [];',fn));
    end
    
    idx = find(time_vector >= (bins(t)-epsilon) & time_vector <= (bins(t+1)+epsilon));
    
    while(idx(end)>max_dim)
        idx(end)=[];
        if(length(idx)==0)
            break;
        end
    end
   
    
    %     if(length(idx)==0)
    %         find(time_vector >= (bins(t)-epsilon) & time_vector <= (bins(t+1)+epsilon))
    %         max_dim
    %         t
    %         BinData.time(t)
    %         bins(t)
    %         bins(t+1)
    %         (bins(t)-epsilon)
    %         (bins(t+1)+epsilon)
    %     end
    
    % fwd fields
    BinData.n_fwd(t) = 0;
    BinData.n_rev(t) = 0;
    BinData.n(t) = 0;
    BinData.n_omegaupsilon(t) = 0;
    if(length(idx)>0)
        local_matrix = fwd_state(:,idx);
        
        local_nan_sum = sum(isnan(local_matrix')); % find rows that contain a NaN
        del_idx = find(local_nan_sum > 0);
        local_matrix(del_idx,:)=[];
        
        BinData.n_fwd(t) = length(local_matrix(:,1));
        
        
        cmd='';
        for(p=1:length(fwd_fields))
            fn = char(fwd_fields{p});
            cmd = [cmd sprintf('local_%s = %s_all(:,idx); local_%s(del_idx,:)=[]; %s = (mean(local_%s, 2) + median(local_%s, 2))/2; clear(''local_%s''); ', fn, fn, fn, fn, fn, fn, fn)];
        end
        eval(cmd);
        clear('cmd');
        
        if(BinData.n_fwd(t)>0)
            for(p=1:length(fwd_fields))
                fn = char(fwd_fields{p});
                fn_s = sprintf('%s_s',fn);
                fn_err = sprintf('%s_err',fn);
                
                BinData.(fn)(t) = eval(sprintf('nanmean(%s);',fn));
                BinData.(fn_s)(t) = eval(sprintf('nanstd(%s);',fn));
                BinData.(fn_err)(t) = BinData.(fn_s)(t)/sqrt(BinData.n_fwd(t));
                
                eval(sprintf('clear(''%s'');',fn));
            end
        end
        clear('local_matrix');
        
        
        % rev fields
        local_matrix = rev_state(:,idx);
        
        local_nan_sum = sum(isnan(local_matrix')); % find rows that contain a NaN
        del_idx = find(local_nan_sum > 0);
        local_matrix(del_idx,:)=[];
        
        BinData.n_rev(t) = length(local_matrix(:,1));
        
        cmd='';
        for(p=1:length(rev_fields))
            fn = char(rev_fields{p});
            cmd = [cmd sprintf('local_%s = %s_all(:,idx); local_%s(del_idx,:)=[]; %s = (mean(local_%s, 2) + median(local_%s, 2))/2; clear(''local_%s'');', fn, fn, fn, fn, fn, fn, fn)];
        end
        eval(cmd);
        clear('cmd');
        
        if(BinData.n_rev(t)>0)
            for(p=1:length(rev_fields))
                fn = char(rev_fields{p});
                fn_s = sprintf('%s_s',fn);
                fn_err = sprintf('%s_err',fn);
                
                BinData.(fn)(t) = eval(sprintf('nanmean(%s);',fn));
                BinData.(fn_s)(t) = eval(sprintf('nanstd(%s);',fn));
                BinData.(fn_err)(t) = BinData.(fn_s)(t)/sqrt(BinData.n_rev(t));
                
                eval(sprintf('clear(''%s'');',fn));
            end
        end
        clear('local_matrix');
        
        % omegaupsilon fields
        local_matrix = omegaupsilon_state(:,idx);
        
        local_nan_sum = sum(isnan(local_matrix')); % find rows that contain a NaN
        del_idx = find(local_nan_sum > 0);
        local_matrix(del_idx,:)=[];
        
        BinData.n_omegaupsilon(t) = length(local_matrix(:,1));
        
        cmd='';
        for(p=1:length(omegaupsilon_fields))
            fn = char(omegaupsilon_fields{p});
            cmd = [cmd sprintf('local_%s = %s_all(:,idx); local_%s(del_idx,:)=[]; %s = (mean(local_%s, 2) + median(local_%s, 2))/2; clear(''local_%s'');', fn, fn, fn, fn, fn, fn, fn)];
        end
        eval(cmd);
        clear('cmd');
        
        if(BinData.n_omegaupsilon(t)>0)
            for(p=1:length(omegaupsilon_fields))
                fn = char(omegaupsilon_fields{p});
                fn_s = sprintf('%s_s',fn);
                fn_err = sprintf('%s_err',fn);
                
                BinData.(fn)(t) = eval(sprintf('nanmean(%s);',fn));
                BinData.(fn_s)(t) = eval(sprintf('nanstd(%s);',fn));
                BinData.(fn_err)(t) = BinData.(fn_s)(t)/sqrt(BinData.n_omegaupsilon(t));
                
                eval(sprintf('clear(''%s'');',fn));
            end
        end
        clear('local_matrix');
        
        % universal fields
        local_matrix = univ_state(:,idx);
        
        local_nan_sum = sum(isnan(local_matrix')); % find rows that contain a NaN
        del_idx = find(local_nan_sum > 0);
        local_matrix(del_idx,:)=[];
        
        BinData.n(t) = length(local_matrix(:,1));
        
        cmd='';
        for(p=1:length(universal_fields))
            fn = char(universal_fields{p}); 
            cmd = [cmd sprintf('local_%s = %s_all(:,idx); local_%s(del_idx,:)=[]; %s = (mean(local_%s, 2) + median(local_%s, 2))/2; clear(''local_%s'');', fn, fn, fn, fn, fn, fn, fn)];
        end
        eval(cmd);
        clear('cmd');
        
        if(BinData.n(t)>0)
            for(p=1:length(universal_fields))
                fn = char(universal_fields{p});
                fn_s = sprintf('%s_s',fn);
                fn_err = sprintf('%s_err',fn);
                
                BinData.(fn)(t) = eval(sprintf('nanmean(%s);',fn));
                BinData.(fn_s)(t) = eval(sprintf('nanstd(%s);',fn));
                BinData.(fn_err)(t) = BinData.(fn_s)(t)/sqrt(BinData.n(t));
                
                eval(sprintf('clear(''%s'');',fn));
            end
        end
        clear('local_matrix');
    end
    
end
clear('time');
clear('state');
clear('state_floor');

t = length(bins);
BinData.time(t) = bins(t);

BinData.n(t) = BinData.n(t-1);
BinData.n_fwd(t) = BinData.n_fwd(t-1);
BinData.n_rev(t) = BinData.n_rev(t-1);
BinData.n_omegaupsilon(t) = BinData.n_omegaupsilon(t-1);
for(p=1:length(fieldnames))
    fn = char(fieldnames{p});
    fn_s = sprintf('%s_s',fn);
    fn_err = sprintf('%s_err',fn);
    
    BinData.(fn)(t) = BinData.(fn)(t-1);
    BinData.(fn_s)(t) = BinData.(fn_s)(t-1);
    BinData.(fn_err)(t) = BinData.(fn_err)(t-1);
end

% state transition probabilities
reduced_state_code = {'F','P','U','R','O'}; % matrix state n vs state n+1
state_transition_probab_matrix=[]; std_matrix=[]; err_matrix=[];
if(Prefs.swim_flag==0)
    [state_transition_probab_matrix, std_matrix, err_matrix] = state_transition_probab_matrix_generate(Tracks, SpeedEccBinSize, starttime, endtime);
end
for(p=1:length(reduced_state_code))
    for(q=1:length(reduced_state_code))
        fn = sprintf('P_%c_to_%c',reduced_state_code{p},reduced_state_code{q});
        fn_s = sprintf('%s_s',fn);
        fn_err = sprintf('%s_err',fn);
        
        BinData.(fn) = zeros(1,length(BinData.time)) + NaN;
        BinData.(fn_s) = BinData.(fn);
        BinData.(fn_err) = BinData.(fn);
        if(~isempty(state_transition_probab_matrix))
            BinData.(fn) = state_transition_probab_matrix(:,p,q)';
            BinData.(fn_s) = std_matrix(:,p,q)';
            BinData.(fn_err) = err_matrix(:,p,q)';
        end
    end
end
clear('state_transition_probab_matrix');
clear('std_matrix');
clear('err_matrix');


% frequency of mvt initiation
bins = starttime:FreqBinSize:endtime; 
% bins = custom_round(bins, 0.01);

for(p=1:length(freq_fields))
    fn = char(freq_fields{p});
    fn_s = sprintf('%s_s',fn);
    fn_err = sprintf('%s_err',fn);
    
    BinData.(fn) = zeros(1,length(bins),'single') +NaN;
    BinData.(fn_s) = zeros(1,length(bins),'single') +NaN;
    BinData.(fn_err) = zeros(1,length(bins),'single') +NaN;
end


init_mvt_matrix  = create_init_mvt_matrix(Tracks,starttime,endtime);

for(t=1:length(bins)-1)
    BinData.freqtime(t) = (bins(t) + bins(t+1))/2;
    
    for(p=1:length(freq_fields))
        fn = char(freq_fields{p});
        eval(sprintf('%s = [];',fn));
    end
    
    idx = find(time_vector >= (bins(t)-epsilon) & time_vector <= (bins(t+1)+epsilon));
    
    BinData.n_freq(t) = 0;
    if(~isempty(idx))
                
        local_matrix = init_mvt_matrix(:,idx);
        dt = (time_vector(idx(end)) - time_vector(idx(1)))/60; % time in secs divide by 60 to get per min freqs
        
        % remove tracks that contain a ring or missing frame within this time period
        local_nan_sum = sum(isnan(local_matrix')); % find rows that contain a NaN
        del_idx = find(local_nan_sum > 0);
        local_matrix(del_idx,:)=[];
        
        BinData.n_freq(t) = length(local_matrix(:,1));
        
        for(j=1:BinData.n_freq(t))
            
            pause_freq(j) = length(find(abs(local_matrix(j,:) - pause_state_code)<=epsilon ));
            depause_freq(j) = length(find(abs(local_matrix(j,:) - depause_state_code)<=epsilon));
            
            lRev_freq(j) = length(find(abs(floor(local_matrix(j,:)) - lRev_state_code)<=epsilon ));
            sRev_freq(j) = length(find(abs(floor(local_matrix(j,:)) - sRev_state_code)<=epsilon ));
            Rev_freq(j) = lRev_freq(j) + sRev_freq(j);
            
            omega_freq(j) = length(find(abs(floor(local_matrix(j,:)) - omega_state_code)<=epsilon ));
            upsilon_freq(j) = length(find(abs(floor(local_matrix(j,:)) - upsilon_state_code)<=epsilon ));
            omegaUpsilon_freq(j) = omega_freq(j) + upsilon_freq(j);
            
            lRevOmega_freq(j) = length(find(abs(local_matrix(j,:) - lRevOmega_state_code)<=epsilon));
            sRevOmega_freq(j) = length(find(abs(local_matrix(j,:) - sRevOmega_state_code)<=epsilon));
            lRevUpsilon_freq(j) =  length(find(abs(local_matrix(j,:) - lRevUpsilon_state_code)<=epsilon));
            sRevUpsilon_freq(j) =  length(find(abs(local_matrix(j,:) - sRevUpsilon_state_code)<=epsilon));
            
            RevOmega_freq(j) = lRevOmega_freq(j) + sRevOmega_freq(j);
            RevOmegaUpsilon_freq(j) = lRevOmega_freq(j) + sRevOmega_freq(j) + lRevUpsilon_freq(j) + sRevUpsilon_freq(j);
            
            pure_lRev_freq(j) = length(find(abs(local_matrix(j,:) - pure_lRev_state_code)<=epsilon));
            pure_sRev_freq(j) = length(find(abs(local_matrix(j,:) - pure_sRev_state_code)<=epsilon));
            pure_omega_freq(j) = length(find(abs(local_matrix(j,:) - pure_omega_state_code)<=epsilon));
            pure_upsilon_freq(j) = length(find(abs(local_matrix(j,:) - pure_upsilon_state_code)<=epsilon));
            pure_Rev_freq(j) = pure_lRev_freq(j) + pure_sRev_freq(j);
            pure_omegaUpsilon_freq(j) = pure_omega_freq(j) + pure_upsilon_freq(j);
            
            reori_freq(j) = length(find(local_matrix(j,:) > fwdstate_state_code));
            
            if(Prefs.swim_flag == 1)
                liquid_omega_freq(j) = length(find(abs(local_matrix(j,:) - liquid_omega_state_code)<=epsilon ));
            end
        end
        
        if(BinData.n_freq(t)>0)
            for(p=1:length(freq_fields))
                fn = char(freq_fields{p});
                fn_s = sprintf('%s_s',fn);
                fn_err = sprintf('%s_err',fn);
                
                BinData.(fn)(t) = eval(sprintf('nanmean(%s)/dt;',fn));
                BinData.(fn_s)(t) = eval(sprintf('nanstd(%s)/dt;',fn));
                BinData.(fn_err)(t) = BinData.(fn_s)(t)/sqrt(BinData.n_freq(t));
                
                eval(sprintf('clear(''%s'');',fn));
            end
        end
        
        local_matrix=[];
        
    end
    
end
clear('local_matrix');
clear('time_vector');
clear('init_mvt_matrix');

t = length(bins);

BinData.freqtime(t) = bins(t);
BinData.n_freq(t) = BinData.n_freq(t-1);
for(p=1:length(freq_fields))
    fn = char(freq_fields{p});
    fn_s = sprintf('%s_s',fn);
    fn_err = sprintf('%s_err',fn);
    
    BinData.(fn)(t) = BinData.(fn)(t-1);
    BinData.(fn_s)(t) = BinData.(fn_s)(t-1);
    BinData.(fn_err)(t) = BinData.(fn_err)(t-1);
end

% clear memory
for(f=1:length(all_fields))
    cmd = sprintf('clear(''%s''); clear(''%s_s''); clear(''%s_err'');', all_fields{f}, all_fields{f}, all_fields{f});
    eval(cmd);
end

% nonUpsilon_reori
    BinData.frac_nonUpsilon_reori = BinData.frac_reori - BinData.frac_upsilon;
    BinData.frac_nonUpsilon_reori_s = sqrt(BinData.frac_nonUpsilon_reori.*(1-BinData.frac_nonUpsilon_reori));
    BinData.frac_nonUpsilon_reori_err = BinData.frac_nonUpsilon_reori_s./sqrt(BinData.n);
    
    BinData.nonUpsilon_reori_freq = BinData.reori_freq - BinData.pure_upsilon_freq;
    BinData.nonUpsilon_reori_freq_s = (BinData.reori_freq_s + BinData.pure_upsilon_freq_s)/2;
    BinData.nonUpsilon_reori_freq_err = (BinData.reori_freq_err + BinData.pure_upsilon_freq_err)/2;


clear('instantaneous_fields');
clear('mvt_fields');
clear('freq_fields');
clear('frac_fields');
clear('all_fields');
clear('universal_fields');

% get rid of the first and last bins due to edge effects
if(nargin==1)
    BinData = trim_bins(BinData);
end


BinData = smooth_BinData(BinData, Prefs.BinData_smoothing_size);

BinData = make_single(BinData);

return;
end

function BinData = trim_bins(BinData)

fn = fieldnames(BinData);

for(i=1:length(fn))
    if(strcmp(fn{i},'Name')==0)
        BinData.(fn{i}) = trim_array_ends(BinData.(fn{i}));
    end
end

clear('fn');

return;
end

function [timeindex, tt] = find_timeindex(tt, target, binsize, time, time_length)

clear('timeindex');
timeindex=[];
if(tt>=time_length)
    timeindex(1) = time_length;
    return;
end
while(target - time(tt) >= binsize  ) % walk up to the start of the bin
    tt = tt + 1;
    if(tt>=time_length)
        timeindex(1) = time_length;
        return;
    end
end
ti = 1;
while(abs(target - time(tt)) <= binsize) % get indicies in the bin
    timeindex(ti) = tt;
    tt = tt + 1;
    ti = ti + 1;
    if(tt>time_length)
        break;
    end
end

return;
end
