function State = AssignLocomotionState(Track)

global Prefs;
Prefs = define_preferences(Prefs);

fwd_code = num_state_convert('fwd');
pause_code = num_state_convert('pause');

State = zeros(1,Track.NumFrames) + fwd_code; % fwd state by default

for(k=1:length(Track.Reorientations))
    
    % is ring ... events are saved as blah.ring
    ee =length(Track.Reorientations(k).class);
    if(Track.Reorientations(k).class(ee) =='g' && Track.Reorientations(k).class(ee-1) =='n' && Track.Reorientations(k).class(ee-2) =='i')
        ee=ee-5;
    end
    
    % rev only
    if(~isnan(Track.Reorientations(k).startRev) && isnan(Track.Reorientations(k).startTurn))
        State(Track.Reorientations(k).startRev:Track.Reorientations(k).end) = num_state_convert(Track.Reorientations(k).class(1:ee));
    else
        % turn/omega only
        if(isnan(Track.Reorientations(k).startRev) && ~isnan(Track.Reorientations(k).startTurn))
            State(Track.Reorientations(k).startTurn:Track.Reorientations(k).end) = num_state_convert(Track.Reorientations(k).class(1:ee));
        else % rev omeg/upsilon
            revtype = Track.Reorientations(k).class(1:4);
            turntype = Track.Reorientations(k).class(5:ee);
            
            State(Track.Reorientations(k).startRev:Track.Reorientations(k).startTurn-1) = num_state_convert(Track.Reorientations(k).class(1:ee));
            State(Track.Reorientations(k).startTurn:Track.Reorientations(k).end) = num_state_convert([turntype revtype]);
            
        end
    end
    
end

% pauses for animals formally in a forward state, loop
for(i=1:Track.NumFrames) 
    if(State(i) == fwd_code)
        if(Track.Speed(i) < Prefs.pauseSpeedThresh)
            State(i) = pause_code;
        end
    end
end

% over-write ring-frames in ring_effects function

return;
end

