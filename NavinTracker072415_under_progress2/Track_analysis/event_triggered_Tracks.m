function [event_triggered_psthTracks, event_triggered_BinData, mean_eventlength] = event_triggered_Tracks(inTracks, event_type, starttime, endtime)
% [event_triggered_psthTracks, event_triggered_BinData, mean_eventlength] = event_triggered_Tracks(inTracks, event_type, starttime, endtime)
% events of type event_type initiate between starttime and endttime (if defined)

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;

Prefs.ethogram_orientation = 'vertical';
    
psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;

eventcode1 = num_state_convert(event_type);
floor_eventcode1 = floor(eventcode1);
eventcode2=[];
if(~are_these_equal(floor(eventcode1), eventcode1))
    eventcode2 = 10*(eventcode1-floor(eventcode1)) + floor(eventcode1)/10;
else
    if(length(eventcode1)>1)
        eventcode2 = eventcode1(2);
        eventcode1 = eventcode1(1);
        floor_eventcode1 = eventcode1;
    end
end

if(nargin<4)
    starttime = min_struct_array(inTracks,'Time');
    endtime = max_struct_array(inTracks,'Time'); 
end

[startframe, endframe] = starttime_endtime_to_startframe_endframe(inTracks, starttime, endtime);

Tracks = inTracks; 
for(i=1:length(Tracks))
    Tracks(i).stimulus_vector=[];
    Tracks(i).stimulus_vector = zeros(1,length(Tracks(i).Frames));
    
    if(abs(eventcode1 - floor_eventcode1)>0.01)
        idx = find(abs(Tracks(i).State - eventcode1)<=1e-4);
        Tracks(i).stimulus_vector(idx) = floor_eventcode1;
        
        if(~isempty(eventcode2))
            idx = find(abs(Tracks(i).State - eventcode2)<=1e-4);
            Tracks(i).stimulus_vector(idx) = floor_eventcode1;
        end
    else
        idx = find(abs(floor(Tracks(i).State) - eventcode1)<=1e-4);
        Tracks(i).stimulus_vector(idx) = floor_eventcode1;
        if(~isempty(eventcode2))
            idx = find(abs(Tracks(i).State - eventcode2)<=1e-4);
            Tracks(i).stimulus_vector(idx) = floor_eventcode1;
        end
    end
    
    del_idx = find(Tracks(i).Frames < startframe | Tracks(i).Frames > endframe);
    Tracks(i).stimulus_vector(del_idx) = 0;

end


[event_triggered_psthTracks, mean_eventlength] = make_psth_Tracks(Tracks, psth_pre_stim_period, psth_post_stim_period, [0 floor_eventcode1]);

clear('Tracks');

stimulus = [0, mean_eventlength, floor_eventcode1];

event_triggered_BinData = bin_and_average_all_tracks(event_triggered_psthTracks, stimulus);

Prefs = OPrefs;

return;
end
