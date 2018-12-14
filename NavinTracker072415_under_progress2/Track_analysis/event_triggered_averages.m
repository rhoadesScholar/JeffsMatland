function [event_triggered_psthTracks, event_triggered_BinData, mean_eventlength] = event_triggered_averages(Tracks, event_type, time_vector, path, prefix)
% event_triggered_averages(Tracks, event_type, time_vector, path, prefix)
% time_vector = [starttime endtime] window of when event_type events occur

if(nargin<1)
    disp('event_triggered_averages(Tracks, event_type, time_vector, path, prefix)')
    disp('time_vector = [starttime endtime] window of when event_type events occur')
    return;
end

global Prefs;
Prefs = [];
Prefs = define_preferences(Prefs);

if(nargin<3)
    time_vector(1) = min_struct_array(Tracks,'Time');
    time_vector(2) = max_struct_array(Tracks,'Time');
end

if(nargin<5)
    path = '';
    prefix = '';
end


[event_triggered_psthTracks, event_triggered_BinData, mean_eventlength] = event_triggered_Tracks(Tracks, event_type, time_vector(1), time_vector(2));


    close all;  % [0, mean_eventlength, 10]
    plot_data(event_triggered_BinData, event_triggered_psthTracks, [0 1 10], path, prefix);


return;
end
