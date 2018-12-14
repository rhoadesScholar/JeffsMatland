function Track = ring_effects(Track)

if(~isfield(Track,'Reorientations'))
    return;
end

RingEffect = calc_RingEffect_vector(Track);

ringcode = num_state_convert('ring');

if(isfield(Track,'State'))
    for(i=1:length(Track.Frames))
        if(RingEffect(i) == 1)
            Track.State(i) = ringcode;
        end
    end
end

if(isfield(Track,'Reorientations'))
    for(i=1:length(Track.Reorientations))
        if(are_these_equal(Track.State(Track.Reorientations(i).start), ringcode)) % this reorientation is probably ring-related
            if(isempty(findstr(Track.Reorientations(i).class,'ring')))
                Track.Reorientations(i).class = sprintf('%s.ring',Track.Reorientations(i).class);
            end
            % for reorientations that started during a ring time
            RingEffect(Track.Reorientations(i).start:Track.Reorientations(i).end) = 1;
            Track.State(Track.Reorientations(i).start:Track.Reorientations(i).end) = ringcode;
        end
    end
end

return;
end

function RingEffect = calc_RingEffect_vector(Track)

global Prefs;

if(~isempty(strfind(Prefs.Ringtype,'food')))
    Prefs.RingDistanceCutoffPixels = Prefs.FoodRingDistanceCutoff/Track.PixelSize;
end

RingEffect = zeros(1, length(Track.Frames));

for(i=1:length(Track.Reorientations))

    if(~isnan(Track.Reorientations(i).startRev))    % Cu ring responses always include a reversal
        % if the animal starts either the reversal or the turn/omega part
        % (if it exists) within Prefs.RingDistanceCutoffPixels of the ring, the
        % animal is officially in a ring state

        j = Track.Reorientations(i).start;
        if(~isnan(Track.Reorientations(i).startTurn))
            k = Track.Reorientations(i).startTurn;
        else
            k=j;
        end
        if(Track.RingDistance(j)<= Prefs.RingDistanceCutoffPixels || Track.RingDistance(k)<= Prefs.RingDistanceCutoffPixels)
            RingEffect(Track.Reorientations(i).start:Track.Reorientations(i).end) = 1; % reorientation is ring
            
            % next Prefs.RingEffectDurationFrames frames are also ring
            RingEffect( (Track.Reorientations(i).end+1) : min( (length(Track.Frames)), (Track.Reorientations(i).end+Prefs.RingEffectDurationFrames) )) = 1;
        end

    end

end

return;
end
