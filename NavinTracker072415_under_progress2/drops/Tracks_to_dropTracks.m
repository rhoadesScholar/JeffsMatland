function dropTracks = Tracks_to_dropTracks(Tracks, strain_names, drop_x, drop_y)

num_drops = length(drop_x);

for(j=1:num_drops)
    dropTracks(j).drop_number = j;
    dropTracks(j).track_fragments = [];
end

for(i=1:length(Tracks))
    mindist = 1e6;
    dropnum = 0;
    [track_centroid_x, track_centroid_y] = Track_centroid(Tracks(i));
    
    for(j=1:num_drops)
        dist = ( track_centroid_x - drop_x(j) )^2 + ( track_centroid_y -  drop_y(j) )^2;
        if(dist < mindist)
           mindist = dist;
           dropnum = j;
        end
    end
    
    dropTracks(dropnum).track_fragments = [dropTracks(dropnum).track_fragments Tracks(i)];
    
end

for(j=1:num_drops)
    dropTracks(j).Name = strain_names{j};
    dropTracks(j).track_fragments = sort_tracks_by_starttime(dropTracks(j).track_fragments);
    dropTracks(j).linkedTracks = collapse_tracks(dropTracks(j).track_fragments, 'interpolate');
    
%     dropTracks(j).linkedTracks = dropTracks(j).track_fragments(1);
%     for(i=2:length(dropTracks(j).track_fragments))
%         dropTracks(j).linkedTracks = append_track(dropTracks(j).linkedTracks, dropTracks(j).track_fragments(i));
%     end
    
end

return;
end
