function Tracks = values_to_track_custom_metric(Tracks, value)

if(~isfield(Tracks(1),value))
   error(sprintf('Error in values_to_track_custom_metric: %s is not a field of Tracks', value))
end

for(t=1:length(Tracks))
    Tracks(t).custom_metric = Tracks(t).(value);
end

return;
end
