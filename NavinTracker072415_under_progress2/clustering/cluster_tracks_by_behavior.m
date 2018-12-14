function outTracks = cluster_tracks_by_behavior(Tracks, starttime, endtime)

if(nargin<3)
    starttime = floor(min_struct_array(Tracks,'Time'));
    endtime = ceil(max_struct_array(Tracks,'Time'));
end

Tracks = sort_tracks_by_length(Tracks);

% edit to deal with  mis-identified superlong reversals
pause_code = num_state_convert('pause');
lRev_code = num_state_convert('lRev');
sRev_code = num_state_convert('sRev');
fwd_code = num_state_convert('fwd');
for(i=1:length(Tracks))
    Tracks(i).numActiveFrames = num_active_frames(Tracks(i));
end
del_idx=[];
for(i=1:length(Tracks))
    idx = find(floor(Tracks(i).State) == lRev_code);
    if(~isempty(idx))
        [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
        if(best_len > 25*Tracks(i).FrameRate)
            Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
        end
    end
    idx = find(floor(Tracks(i).State) == sRev_code);
    if(~isempty(idx))
        [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
        if(best_len > 25*Tracks(i).FrameRate)
            Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
        end
    end
end
if(length(Tracks)>1)
    if(length(del_idx) < length(Tracks))
        Tracks(del_idx) = [];
    end
end
clear('del_idx');


tr = extract_track_segment(Tracks,starttime, endtime,'time');

state_matrix = track_field_to_matrix(tr, 'State',0);
state_matrix(state_matrix==pause_code)=num_state_convert('fwd');
state_matrix(state_matrix>=num_state_convert('ring'))=0;

method = sprintf('euclidean');
Y = pdist(state_matrix, method);
Z = linkage(Y, 'average');

figure(101); [~,~, cluster_idx] = dendrogram(Z,0); close(101);
cluster_idx = cluster_idx(end:-1:1);


outTracks = Tracks(cluster_idx);

return;
end
