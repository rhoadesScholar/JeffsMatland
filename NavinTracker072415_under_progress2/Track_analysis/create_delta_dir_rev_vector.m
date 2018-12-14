function delta_dir_rev_vector = create_delta_dir_rev_vector(Track)

% default value of NaN; no reversal length unless reversing, after all
delta_dir_rev_vector(1:Track.NumFrames) = NaN;

if (~isempty(Track.Reorientations))
    for (i=1:length(Track.Reorientations))
        if(~isnan(Track.Reorientations(i).startRev))
            if(isnan(Track.Reorientations(i).startTurn))
                delta_dir_rev_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).end) = Track.Reorientations(i).delta_dir;
            else
                delta_dir_rev_vector(Track.Reorientations(i).startRev:Track.Reorientations(i).startTurn-1) = Track.Reorientations(i).delta_dir;
            end
        end
    end
end

return;

end