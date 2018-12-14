function revSpeed_vector = create_revSpeed_vector(Track)

% default value of NaN; no reversal speed unless reversing, after all
revSpeed_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isnan(Track.Reorientations(i).startRev))
            if(isnan(Track.Reorientations(i).startTurn))
                revSpeed_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).end) = Track.Reorientations(i).revSpeed;
            else
                revSpeed_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).startTurn-1) = Track.Reorientations(i).revSpeed;
            end
        end
    end
end

return;

end
