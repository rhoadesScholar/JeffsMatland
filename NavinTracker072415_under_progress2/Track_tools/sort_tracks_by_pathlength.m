function outTracks = sort_tracks_by_pathlength(Tracks)

pathlength_array = [];
for(i=1:length(Tracks))
    pathlength_array = [pathlength_array, -track_path_length(Tracks(i))];
end


[s, idx] = sort(pathlength_array);
outTracks = Tracks(idx);

return;
end
