% returns the continious indices between Track.Time t1 and t2 that do not
% contain missing or ring frames

function idx = ringmiss_filter_Track_Frames_index(Track, t1, t2)

ringmiss_state_code = num_state_convert('ringmiss');

idx = find(Track.Time > t1 & Track.Time <= t2);

ringmiss_idx = find(Track.State(idx) < ringmiss_state_code);

% all ring or missing
if(isempty(ringmiss_idx))
    idx=[];
    return;
end

% no missing or ring frames
if(length(idx) == length(ringmiss_idx))
    return;
end

[i, j] = find_longest_contigious_stretch_in_array(ringmiss_idx);

idx = idx(ringmiss_idx(i):ringmiss_idx(j));

return;
end
