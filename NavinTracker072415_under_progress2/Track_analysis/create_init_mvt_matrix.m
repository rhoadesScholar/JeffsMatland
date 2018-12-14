function init_mvt_matrix = create_init_mvt_matrix(Tracks, starttime, endtime)

epsilon=1e-4;

if(nargin > 1)
    first = min_struct_array(Tracks,'Time');
    last = max_struct_array(Tracks,'Time');
    
    timevector = first:1/Tracks(1).FrameRate:last;
    
    if(are_these_equal(starttime, first) && are_these_equal(endtime, last))
        del_idx=[];
    else
        del_idx = find(timevector < (starttime-epsilon) | timevector > (endtime+epsilon));
    end
end

num_frames = max_struct_array(Tracks,'Frames');
num_tracks = length(Tracks);

init_mvt_matrix = zeros(num_tracks, num_frames,'single');
init_mvt_matrix = init_mvt_matrix + NaN;

for(i=1:num_tracks)
    init_mvt_matrix(i,Tracks(i).Frames(1):Tracks(i).Frames(end)) = Tracks(i).mvt_init;
end

init_mvt_matrix = matrix_replace(init_mvt_matrix,'>=',num_state_convert('ringmiss'),NaN);

if(nargin > 1)
    init_mvt_matrix(:,del_idx) = [];
end

return;
end
