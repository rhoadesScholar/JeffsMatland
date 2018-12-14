function revlength_vector = create_reversal_length_vector(Track)

% default value of NaN; no reversal length unless reversing, after all
revlength_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isnan(Track.Reorientations(i).startRev))
            if(isnan(Track.Reorientations(i).startTurn))
                revlength_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).end) = Track.Reorientations(i).revLen;
            else
                revlength_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).startTurn-1) = Track.Reorientations(i).revLen;
            end
        end
    end
end

return;

end