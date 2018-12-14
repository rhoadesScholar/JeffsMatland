function [BinData, custom_metric_vector, attribute_matrix, attribute_stddev_matrix, attribute_sem_matrix, n_vector] = attribute_vs_custom_metric(inputTracks, metric_label, custom_metric_binwidth, custom_metric_function_handle, vargin)
% custom_metric_function_handle is handle to a function that takes Tracks
% argument and appends "custom_metric" to each track

attributes = parse_BinData_fields;

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = 1;
Prefs.BinSize = 1;
Prefs.SpeedEccBinSize = 1;

if(nargin<4)
    custom_metric_function_handle = [];
end

% provide function to make custom_metric
if(~isempty(custom_metric_function_handle))
    if(nargin<5)
        Tracks = custom_metric_function_handle(inputTracks);
    else
        Tracks = custom_metric_function_handle(inputTracks, vargin);
    end
else
    Tracks = inputTracks; % inputTracks already has custom_metric
    if(~isfield(Tracks(1),'custom_metric'))
        disp('usage: [BinData, custom_metric_vector, attribute_matrix, attribute_stddev_matrix, attribute_sem_matrix, n_vector] = attribute_vs_custom_metric(inputTracks, metric_label, custom_metric_binwidth, custom_metric_function_handle, vargin)');
        error('attribute_vs_custom_metric requires inputTracks to have custom_metric if custom_metric_function_handle is not defined');
    end
end
clear('inputTracks');


min_custom_metric = floor(min_struct_array(Tracks,'custom_metric'));
max_custom_metric = ceil(max_struct_array(Tracks,'custom_metric'));

if(length(custom_metric_binwidth)==1)
    if(custom_metric_binwidth > abs(max_custom_metric-min_custom_metric))
        custom_metric_binwidth = abs(max_custom_metric-min_custom_metric)/5;
    end
    
    metric_bins = min_custom_metric:custom_metric_binwidth:(max_custom_metric+(custom_metric_binwidth/2));
else
    metric_bins = custom_metric_binwidth; % bin edges inputed
end

attribute_matrix = zeros(length(attributes), length(metric_bins)-1) + NaN;
attribute_stddev_matrix = attribute_matrix;
attribute_sem_matrix = attribute_matrix;
n_vector = zeros(1,length(metric_bins)-1);
    
for(m=1:length(metric_bins)-1)
    
    custom_metric_vector(m) = (metric_bins(m) + metric_bins(m+1))/2;
    
    %     % use psth_Tracks as an intermediate - not good for attributes!!!
    %     for(i=1:length(Tracks))
    %         idx = find(Tracks(i).custom_metric >= metric_bins(m) & Tracks(i).custom_metric <= metric_bins(m+1));
    %         Tracks(i).stimulus_vector = zeros(1, length(Tracks(i).Frames));
    %         Tracks(i).stimulus_vector(idx) = 1;
    %     end
    %     [psth_Tracks, stimlength] = make_psth_Tracks(Tracks, 3*Prefs.FreqBinSize, 3*Prefs.FreqBinSize, [0 1]);
    %     stimlength = 10;
    %     psth_BinData = bin_and_average_all_tracks(psth_Tracks, [0 stimlength 1]);
    %     for(a=1:length(attributes))
    %         [attribute_matrix(a,m), attribute_stddev_matrix(a,m), attribute_sem_matrix(a,m), n_vector(m)] = segment_statistics(psth_BinData, attributes{a}, 'mean', 0, stimlength);
    %     end
    
    
    workingTracks = [];
    for(i=1:length(Tracks))
        % split each track into contigious segments within the custom_metric bin of interest
        
        % find frames with  custom_metric in the bin of interest
        idx = find(Tracks(i).custom_metric >= metric_bins(m) & Tracks(i).custom_metric <= metric_bins(m+1));
        
        
        if(~isempty(idx))
            
            j=1;
            while(j<length(idx))
                k = find_end_of_contigious_stretch(idx, j);
                
                % redundant if odor info is defined as pre-event for ALL
                % reorientations
                % if j or k are during a reorientation event, move them so
                % the entire event is captured
                for(q=1:length(Tracks(i).Reorientations))
                    if(idx(j) >  Tracks(i).Reorientations(q).start && idx(j) < Tracks(i).Reorientations(q).end)
                        idx(j) = Tracks(i).Reorientations(q).start;
                    end
                    if(idx(k) >  Tracks(i).Reorientations(q).start && idx(k) < Tracks(i).Reorientations(q).end)
                        idx(k) = Tracks(i).Reorientations(q).end;
                    end
                end
                
                if(k-j+1 > Tracks(i).FrameRate)
                    % wt = extract_track_segment(Tracks(i), max(1,idx(j)-2*Tracks(i).FrameRate), min(length(Tracks(i).Frames),idx(k)+2*Tracks(i).FrameRate));
                    wt = extract_track_segment(Tracks(i), idx(j), idx(k));
                    workingTracks = [workingTracks wt];
                end
                
                j = k+1;
            end
        end
    end
    
    %     if(60>=metric_bins(m) && 60<=metric_bins(m+1))
    %         [custom_metric_vector(m)  metric_bins(m)   metric_bins(m+1)]
    %         workingTracks = sort_tracks_by_length(workingTracks);
    %         WormPlayer(workingTracks)
    %         return;
    %     end
    
    if(length(workingTracks)>2)
        workingTracks = reframe_Track(workingTracks);
        BinData = bin_and_average_all_tracks(workingTracks);
        
        for(a=1:length(attributes))
            
            [attribute_matrix(a,m), attribute_stddev_matrix(a,m), attribute_sem_matrix(a,m), n_vector(m)] = event_freq_in_bin(workingTracks, attributes{a});
            if(isnan(attribute_matrix(a,m)))
                [attribute_matrix(a,m), attribute_stddev_matrix(a,m), attribute_sem_matrix(a,m), n_vector(m)] = segment_statistics(BinData, attributes{a}, 'weighted_mean');
            end
        end
    end
    
    clear('BinData');
    clear('workingTracks');
    
end

Prefs = OPrefs;


% convert to BinData with time fields replaced by custom_metric_vector
BinData = initialize_BinData;
BinData.Name = Tracks(1).Name;
BinData.num_movies = 0;
BinData.time = custom_metric_vector;
BinData.n = n_vector;
BinData.n_fwd = BinData.n;
BinData.n_rev = BinData.n;
BinData.n_omegaupsilon = BinData.n;
BinData.freqtime = custom_metric_vector;
BinData.n_freq = n_vector;
BinData.xlabel = metric_label;
for(a=1:length(attributes))
    BinData.(attributes{a}) = attribute_matrix(a,:);
    BinData.(sprintf('%s_s',attributes{a})) = attribute_stddev_matrix(a,:);
    BinData.(sprintf('%s_err',attributes{a})) = attribute_sem_matrix(a,:);
end

return;
end

function [attrib, attrib_s, attrib_err, n] = event_freq_in_bin(workingTracks, attribute)

persistent freq_fieldnames;

attrib = NaN; attrib_s = NaN;  attrib_err = NaN;
n = length(workingTracks);

if(isempty(freq_fieldnames))
    [~, freq_fieldnames] = get_BinData_fieldnames;
end

if(~isempty(strfind(attribute, 'depause')) || sum(strcmp(freq_fieldnames,attribute))==0)
    return;
end

% freq attribute

state_codes = num_state_convert(attribute(1:end-5));

freqs = [];
for(i=1:length(workingTracks))
    
    num_events=0;
    for(s = 1:length(state_codes))
        state_code = state_codes(s);
        
        mvt_init_vector = workingTracks(i).mvt_init;
        
        % generic event sRev, lRev omega
        if(abs(state_code - floor(state_code)) < 1e-4)
            mvt_init_vector =  floor(mvt_init_vector);
        end
        
        idx = find(abs(mvt_init_vector - state_code) < 1e-4);
        
        num_events = num_events + length(idx);
    end
    
    freqs = [freqs num_events/length(workingTracks(i).Frames)];
end

freqs = (workingTracks(1).FrameRate*60)*freqs;

attrib = nanmean(freqs);
attrib_s = nanstd(freqs);
attrib_err = nanstderr(freqs);

return;
end


