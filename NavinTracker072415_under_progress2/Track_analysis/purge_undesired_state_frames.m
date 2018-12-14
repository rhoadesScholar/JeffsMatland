function edited_Tracks = purge_undesired_state_frames(Tracks, desired_state)
% edited_Tracks = purge_undesired_state_frames(Tracks, desired_state)
% replaces frames of ~desired_state w/ ring so these will be ignored when
% binning data

desired_state = num_state_convert(desired_state);
ring_code = num_state_convert('ring');

edited_Tracks = Tracks;
for(i=1:length(Tracks))
   desired_idx = find(edited_Tracks(i).State == desired_state);
   idx_vector = zeros(1,length(edited_Tracks(i).State))+ring_code; % all are ring
   idx_vector(desired_idx)=desired_state; % replace desired state frames w/ correct state code
   edited_Tracks(i).State = idx_vector; % replace State vector
end

return;
end
