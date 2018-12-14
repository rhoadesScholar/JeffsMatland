function x = find_Track_to_matrix(Tracks,field,relationship1,linker,relationship2)

if(nargin<4)
    track_idx_frame_idx = find_Track(Tracks,field,relationship1);
else
    track_idx_frame_idx = find_Track(Tracks,field,relationship1,linker,relationship2);
end

x = zeros(length(Tracks), max_struct_array(Tracks,'Frames'),'single');

if(isempty(track_idx_frame_idx))
    return;
end

for(q=1:length(track_idx_frame_idx))
    i = track_idx_frame_idx(q).track_idx;
    
    for(p=1:length(track_idx_frame_idx(q).frame_idx))
        j = track_idx_frame_idx(q).frame_idx(p);
        x(i, Tracks(i).Frames(j)) = 1; 
    end
    
end

return;
end

