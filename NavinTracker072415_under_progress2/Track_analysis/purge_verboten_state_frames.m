function edited_Tracks = purge_verboten_state_frames(Tracks, verboten_state)
% edited_Tracks = purge_verboten_state_frames(Tracks, verboten_state)
% replaces frames of verboten_state w/ ring so these will be ignored when
% binning data

verboten_state_code = num_state_convert(verboten_state);
ring_code = num_state_convert('ring');

edited_Tracks = Tracks;
for(i=1:length(edited_Tracks))
   verboten_idx = find(edited_Tracks(i).State == verboten_state_code);
   edited_Tracks(i).State(verboten_idx) = ring_code;
end

return;
end
