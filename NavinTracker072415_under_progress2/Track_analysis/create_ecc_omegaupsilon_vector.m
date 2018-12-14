function ecc_omegaupsilon_vector = create_ecc_omegaupsilon_vector(Track)

% default value of NaN; no reversal length unless reversing, after all
ecc_omegaupsilon_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isnan(Track.Reorientations(i).startTurn))
            ecc_omegaupsilon_vector(Track.Reorientations(i).startTurn:Track.Reorientations(i).end) = Track.Reorientations(i).ecc;
        end
    end
end

return;

end
