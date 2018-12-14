function full_Tracks = reconstruct_full_Tracks(collapseTracks, Tracks)

for(i=1:length(collapseTracks))
    full_Tracks(i) = Tracks(collapseTracks(i).original_track_indicies(1));
    for(j=2:length(collapseTracks(i).original_track_indicies))
        full_Tracks(i) = append_track(full_Tracks(i), Tracks(collapseTracks(i).original_track_indicies(j)));
    end
end

return;
end
