function revlength_vector = create_reversal_length_bodybends_vector(Track)

% default value of NaN; no reversal length unless reversing, after all
revlength_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isnan(Track.Reorientations(i).startRev))
            if(isnan(Track.Reorientations(i).startTurn))
                revlength_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).end) = Track.Reorientations(i).revLenBodyBends;
            else
                revlength_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).startTurn-1) = Track.Reorientations(i).revLenBodyBends;
            end
        end
    end
end

return;

end