function Tracks = body_contour_stuff(inputTracks)

for(i=1:length(inputTracks))
    
    tr = inputTracks(i);
    
    % reassign the state, getting rid of the ring edits
    tr.State = AssignLocomotionState(tr);
    
    % assign head, tail, etc
    % head vs tail requires the unedited state
    tr = worm_head_tail(tr);
    
    tr.body_angle = worm_body_angle(tr);
    
    % Ring Effect stuff - re modify the state to take the ring into account
    tr = ring_effects(tr);
    tr.mvt_init = mvt_init_vector(tr);
    
    Tracks(i) = tr;
    clear('tr');
end

return;
end

