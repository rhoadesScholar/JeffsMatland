function [cntrlTracks, cntrlMat] = showCalCntrls(calTracks, medWindow, combine, indie, stepSize, strainInc)
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    if iscell(calTracks)
        allCals = calTracks;
    end
    c = length(calTracks);    
    
    cntrlTracks = struct();
    
    for d = 1:c
        calTracks = allCals{d};
        strains = fields(calTracks);
        strains = strains(contains(strains, strainInc));
        for s = 1:length(strains)
            for w = 1:length(calTracks.(strains{s}))
                if contains(calTracks.(strains{s})(w).name, 'cntrl', 'IgnoreCase', true)                   
                    try
                        cntrlTracks.(strains{s})(end + 1) = calTracks.(strains{s})(w);
                    catch
                        cntrlTracks.(strains{s})(1) = calTracks.(strains{s})(w);
                    end
                    fprintf('%s added.\n', calTracks.(strains{s})(w).name);
                end
            end
        end
    end
    if combine && ~isempty(fields(cntrlTracks))
        conds = fields(cntrlTracks);
        for s = 1:length(strainInc)
            for c = 2:length(conds)
                if contains(conds{c}, strainInc{s})
                    try
                        allOptos.(sprintf('%scntrl', strainInc{s})) = [allOptos.(sprintf('%scntrl', strainInc{s})) cntrlTracks.(conds{c})];
                    catch
                        allOptos.(sprintf('%scntrl', strainInc{s})) = cntrlTracks.(conds{c});
                    end
                end
            end
        end
        cntrlTracks = allOptos;
        cntrlMat = showAvgCalTracks(cntrlTracks, medWindow, indie, stepSize);            
    end
    
    return
end