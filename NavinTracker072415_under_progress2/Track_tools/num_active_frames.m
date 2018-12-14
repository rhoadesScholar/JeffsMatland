function n = num_active_frames(Track)

ring_code = num_state_convert('ring');
miss_code = num_state_convert('miss');

% ring = 99, miss = 100, food-sansFood joining junction = 200
if(isfield(Track,'State'))
    n = length(find(Track.State < ring_code)) + length(find(Track.State > miss_code));
else
    n = length(Track.Frames);
end

return;
end
