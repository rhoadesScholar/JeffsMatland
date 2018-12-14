function delta_dir_omegaupsilon_vector = create_delta_dir_omegaupsilon_vector(Track)

% default value of NaN; no reversal length unless reversing, after all
delta_dir_omegaupsilon_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isempty(Track.Reorientations(i).startTurn))
            if(~isnan(Track.Reorientations(i).startTurn) && isnan(Track.Reorientations(i).revLen))
                delta_dir_omegaupsilon_vector(Track.Reorientations(i).startTurn:Track.Reorientations(i).end) = Track.Reorientations(i).turn_delta_dir;
            end
        end
    end
end

return;

end
