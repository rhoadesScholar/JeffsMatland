function analyze_optogen_chemotaxis_tracks_in_ROI(chemotaxis_tracks, stimulusfile, pre_stim_period, post_stim_period, region_polygon)
% analyze_optogen_chemotaxis_tracks_in_ROI(chemotaxis_tracks, stimulusfile, region_polygon)
% region_polygon = region of interest (ROI); if not defined or is empty,
% will launch GUI for user to identify
% stimulusfile can be either the stimulus file or a pre-loaded stmulus matrix

if(nargin < 3)
    pre_stim_period = 10;
end
if(nargin < 4)
    post_stim_period = 100;
end

global Prefs;
Prefs = define_preferences(Prefs);
Prefs = CalcPixelSizeDependencies(Prefs, chemotaxis_tracks(1).PixelSize);

OPrefs = Prefs;
Prefs.FreqBinSize = 2;

if(nargin < 5)
    region_polygon = [];
end

if(ischar(stimulusfile))
    stimulus = load_stimfile(stimulusfile);
else
    stimulus = stimulusfile;
end
stimlength = [];
for(i=1:size(stimulus,1))
    stimlength = [stimlength  (stimulus(i,2) - stimulus(i,1))];
end
stimlength = max(stimlength);


opto_channel = stimulus(1,3);
transition_vector = [0 opto_channel];

[~, prefix] = fileparts(chemotaxis_tracks(1).Name);

regionfile = sprintf('%s.region_polygon.mat',prefix);
if(isempty(region_polygon))
    if(file_existence(regionfile))
        disp(sprintf('%s exists ... loading\t%s',regionfile,timeString));
        load(regionfile);
    end
end
[Tracks, region_polygon] = identify_tracks_in_region(chemotaxis_tracks, region_polygon);
save(regionfile,'region_polygon');

Tracks = attach_stimulus_vector_to_tracks(Tracks, stimulus);

close all
pause(0.1);

% find tracks that contain a stimulus and have at least
% pre_stim_period sec before stimulus onset
stim_tracks = [];
for(i=1:length(Tracks))
    idx = find(Tracks(i).stimulus_vector == opto_channel);
    
    if(~isempty(idx))
        j=1;
        while(j<length(idx))
            k = find_end_of_contigious_stretch(idx, j);
            
            % move back pre_stim_period sec
            % start_idx = max(1, (idx(j) - pre_stim_period*Tracks(i).FrameRate));
            start_idx = (idx(j) - pre_stim_period*Tracks(i).FrameRate);
            
            % must have at least pre_stim_period sec preceeding the stimulus
            if(start_idx >= 1)
                
                end_idx = min(length(Tracks(i).Frames), idx(k)+post_stim_period*Tracks(i).FrameRate);
                
                if(end_idx-start_idx+1 > Tracks(i).FrameRate)
                    wt = extract_track_segment(Tracks(i), start_idx, end_idx);
                    if(~isempty(wt))
                        stim_tracks = [stim_tracks wt];
                    end
                end
            end
            
            j = k+1;
        end
    end
 end


% identify tracks that are moving toward the odor in the
% pre_stim_period sec prior to stimulus onset
toward_tracks = []; local_prefix = sprintf('%s.toward',prefix);
for(i=1:length(stim_tracks))
    stim_idx = find(stim_tracks(i).stimulus_vector == opto_channel);
    prestim_end_idx = stim_idx(1) - 1;
   if(mean_direction(stim_tracks(i).odor_angle(1:prestim_end_idx)) <= 60)
        wt = stim_tracks(i);
        zerotime = wt.Time(stim_idx(1));
        wt.Time = wt.Time - zerotime;
        wt.Frames = 1:length(wt.Frames);
        toward_tracks = [toward_tracks wt];
   end
end
toward_BinData = bin_and_average_all_tracks(toward_tracks, [0 stimlength opto_channel]);
plot_data(toward_BinData, toward_tracks, [0 stimlength opto_channel], '', local_prefix);
save_Tracks(sprintf('%s.Tracks.mat',local_prefix),toward_tracks);
save_BinData(toward_BinData, '', local_prefix);

% identify tracks that are moving perpendicular the odor in the
% pre_stim_period sec prior to stimulus onset
perpendicular_tracks = []; local_prefix = sprintf('%s.perpendicular',prefix);
for(i=1:length(stim_tracks))
    stim_idx = find(stim_tracks(i).stimulus_vector == opto_channel);
    prestim_end_idx = stim_idx(1) - 1;
   if(mean_direction(stim_tracks(i).odor_angle(1:prestim_end_idx)) > 60 && mean_direction(stim_tracks(i).odor_angle(1:prestim_end_idx)) < 120)
        wt = stim_tracks(i);
        zerotime = wt.Time(stim_idx(1));
        wt.Time = wt.Time - zerotime;
        wt.Frames = 1:length(wt.Frames);
        perpendicular_tracks = [perpendicular_tracks wt];
   end
end
perpendicular_BinData = bin_and_average_all_tracks(perpendicular_tracks, [0 stimlength opto_channel]);
plot_data(perpendicular_BinData, perpendicular_tracks, [0 stimlength opto_channel], '', local_prefix);
save_Tracks(sprintf('%s.Tracks.mat',local_prefix),perpendicular_tracks);
save_BinData(perpendicular_BinData, '', local_prefix);

% identify tracks that are moving perpendicular the odor in the
% pre_stim_period sec prior to stimulus onset
away_tracks = []; local_prefix = sprintf('%s.away',prefix);
for(i=1:length(stim_tracks))
    stim_idx = find(stim_tracks(i).stimulus_vector == opto_channel);
    prestim_end_idx = stim_idx(1) - 1;
   if(mean_direction(stim_tracks(i).odor_angle(1:prestim_end_idx)) >= 120)
        wt = stim_tracks(i);
        zerotime = wt.Time(stim_idx(1));
        wt.Time = wt.Time - zerotime;
        wt.Frames = 1:length(wt.Frames);
        away_tracks = [away_tracks wt];
   end
end
away_BinData = bin_and_average_all_tracks(away_tracks, [0 stimlength opto_channel]);
plot_data(away_BinData, away_tracks, [0 stimlength opto_channel], '', local_prefix);
save_Tracks(sprintf('%s.Tracks.mat',local_prefix),away_tracks);
save_BinData(away_BinData, '', local_prefix);

Prefs = OPrefs;

return;
end
