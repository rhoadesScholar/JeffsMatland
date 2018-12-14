function [allTracks, wormsUsed, calMats, avgs, stdErr] = showPooledAvgCalTracks(calTracks, combine, medWindow, varargin)%calTracks should be cell array of structures
                                                              %combine is boolean or cell of strains to combine
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end

    if ~exist('combine', 'var') || isempty(combine)
        strainies = {};
        a = cellfun(@(x) fields(x), calTracks, 'UniformOutput', false);
        for i = 1:length(a)
            strainies(end + 1:end+length(a{i})) = a{i};
        end
        strains = unique(strainies);
        [combine, ok] = listdlg('PromptString','Select strains to view:', 'ListString',strains, 'ListSize', [400 600]);
        if ~ok
            return
        else
            combine = strains(combine);
        end
%         combine = true;
    end
    
    if length(varargin) >= 1
        indie = varargin{1};
    else
        indie = false;
    end
    if length(varargin) >= 2
        stepSize = varargin{2};
    else
        stepSize = false;
    end
        
    allTracks = poolTracks(calTracks, combine);
    
    [calMats, avgs, stdErr, wormsUsed] = showAvgCalTracks(allTracks, medWindow, indie, stepSize);

end

function allTracks = poolTracks(calTracks, combine)

    allTracks = struct();

    for d = 1:length(calTracks)%d for day
        strains = fields(calTracks{d});
        for s = 1:length(strains)%s for strain
            if iscell(combine) && ~isempty(find(strcmpi(strains{s}, combine),1))
                if (isfield(allTracks,strains{s}))
                   oldAllTracks = allTracks.(strains{s});
                   try
                       allTracks.(strains{s}) = [oldAllTracks calTracks{d}.(strains{s})];
                   catch
                       newTracks = calTracks{d}.(strains{s});
                       newFields = fields(calTracks{d}.(strains{s}));
                       oldFields = fields(oldAllTracks);
                       if length(newFields) > length(oldFields)
                           newTracks = rmfield(newTracks, setdiff(newFields, oldFields));
                       elseif length(oldFields) > length(newFields)
                           oldAllTracks = rmfield(oldAllTracks, setdiff(oldFields, newFields));
                       end 
                       allTracks.(strains{s}) = [oldAllTracks newTracks];
                    end
                else
                   allTracks.(strains{s}) = calTracks{d}.(strains{s});
                end
            elseif ~iscell(combine) && combine
                if (isfield(allTracks,strains{s}))
                   oldAllTracks = allTracks.(strains{s});
                   allTracks.(strains{s}) = [oldAllTracks calTracks{d}.(strains{s})];
                else
                   allTracks.(strains{s}) = calTracks{d}.(strains{s});
                end
            end
        end    
    end

    if ~iscell(combine) && ~combine
        allTracks = calTracks{:};
    end

    strains = fields(allTracks);
    N2s = contains(strains,'N2');
    strainOrder = [{strains{N2s}} {strains{~N2s}}];
    allTracks = orderfields(allTracks, strainOrder);

    return
end

%%%%%%%%%%%%%%
function callScriptForPaste
    days = dir;
    days = days(3:end);
    days = days([days(:).isdir]);
    days = {days(:).name};
    for d = 1:length(days)
        files = dir([days{d} '\*.mat']);
        try
            load([files(end).folder '\' files(end).name]);
        end            
    end
    
    vs = whos('calTracks_*');
    vs = {vs(:).name};
    for b = 1:length(vs)
    eval(sprintf('cals{%i} = %s', b, vs{b}))
    end
    
    showPooledAvgCalTracks(cals, {}, [5 10])
end

function subPlotCode
    title('');
    ylabel('Worm#');
    ax = gca;
    fig = figure(1);
    set(ax, 'Parent', fig);
    set(ax, 'Position', [0.5 0.7 0.35 0.2]);
end