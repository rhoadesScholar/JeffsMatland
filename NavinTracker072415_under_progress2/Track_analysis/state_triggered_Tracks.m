function [state_triggered_psthTracks, state_triggered_BinData, mean_statelength] = state_triggered_Tracks(inTracks, state_type, time)
% [state_triggered_psthTracks, state_triggered_BinData, mean_statelength] = state_triggered_Tracks(inTracks, state_type, time)
% outputs tracks that have state_type at time

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;

Prefs.ethogram_orientation = 'vertical';
    
psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;

statecode1 = num_state_convert(state_type);
floor_statecode1 = floor(statecode1);
statecode2=[];
if(~are_these_equal(floor(statecode1), statecode1))
    statecode2 = 10*(statecode1-floor(statecode1)) + floor(statecode1)/10;
end


[startframe, endframe] = starttime_endtime_to_startframe_endframe(inTracks, time-inTracks(1).FrameRate, time);

Tracks = inTracks; 
for(i=1:length(Tracks))
    Tracks(i).stimulus_vector=[];
    Tracks(i).stimulus_vector = zeros(1,length(Tracks(i).Frames));
    
    if(abs(statecode1 - floor_statecode1)>0.01)
        idx = find(abs(Tracks(i).State - statecode1)<=1e-4);
        Tracks(i).stimulus_vector(idx) = floor_statecode1;
        
        if(~isempty(statecode2))
            idx = find(abs(Tracks(i).State - statecode2)<=1e-4);
            Tracks(i).stimulus_vector(idx) = floor_statecode1;
        end
    else
        idx = find(abs(floor(Tracks(i).State) - statecode1)<=1e-4);
        Tracks(i).stimulus_vector(idx) = floor_statecode1;
    end
    
    del_idx = find(Tracks(i).Frames < startframe | Tracks(i).Frames > endframe);
    Tracks(i).stimulus_vector(del_idx) = 0;

end


[state_triggered_psthTracks, mean_statelength] = make_psth_Tracks(Tracks, psth_pre_stim_period, psth_post_stim_period, [0 floor_statecode1]);

clear('Tracks');

stimulus = [0, mean_statelength, floor_statecode1];

state_triggered_BinData = bin_and_average_all_tracks(state_triggered_psthTracks, stimulus);

Prefs = OPrefs;

return;
end
