function [normalTracks, refeeds, lags, avgs, allNums] = showPooledEncounters(allTracks, combine, varargin)

    par = inputParser;
    addParameter(par, 'exclude', {});
    parse(par, varargin{:})

    if nargin > 2 && isempty(par.Results.exclude)
        normalTracks = normalizeSpeedsByN2(allTracks, combine, varargin{:});
    else
        normalTracks = normalizeSpeedsByN2(allTracks, combine);
    end

    if ~isempty(par.Results.exclude)
        excluded = par.Results.exclude;
        strains = fields(normalTracks);
        for s = 1:length(strains)
            include = arrayfun(@(x) ~contains(x.Name, excluded), normalTracks.(strains{s}));
            normalTracks.(strains{s}) = normalTracks.(strains{s})(include);
        end
    end

    [refeeds, lags, avgs, allNums] = showEncounters(normalTracks);

    return
end
%%%################################
function callScriptForPaste
    vs = whos('tracks_*');
    vs = {vs(:).name};
    for b = 1:length(vs)
        eval(sprintf('allTracks{%i} = %s', b, vs{b}));
    end
    showPooledEncounters(allTracks, {'N2' 'SWF18' 'SWF18r2c'})%EDIT STRAINS    
end

