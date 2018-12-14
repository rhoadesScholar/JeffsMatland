function results = strainBimodalities(allFinalTracks, date, bin, strains)
    if ~exist('strains', 'var')
        strains = fields(allFinalTracks);
    end

    for s=1:length(strains)%all strains
       results.(strains{s}) = checkBimodality_normalized(allFinalTracks.(strains{s}), date, strains{s}, bin);
    end
    return
end
