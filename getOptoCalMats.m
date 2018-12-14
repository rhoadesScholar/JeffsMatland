function optoMats = getOptoCalMats(calMats, durations, stims, smooth, strains, frameRate)
% durations is nx2 array of [duration of pause before stim, duration of stim] in seconds
% stim is vector of length n of LED intensities in range [0:1]
    
    global medWindow
    medWindow = [5 10];
   
    if iscell(calMats)
        if ~exist('strains', 'var')
            strainies = {};
            a = cellfun(@(x) fields(x), calMats, 'UniformOutput', false);
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
        else
            combine = strains;
        end
        calTracks = poolTracks(calMats, combine);
        strains = fields(calTracks);
        calMats = struct();
        for s = 1:length(strains)
            strainTracks = calTracks.(strains{s});
            calMats.(strains{s}).rawSpeed = getRawSpeed(strainTracks);
            calMats.(strains{s}).rawFluor = getRawFluor(strainTracks);
        end
    elseif ~exist('strains', 'var')
        strains = fields(calMats);
    end
        
    if ~exist('frameRate', 'var')
        frameRate = 10;
    end
    
    %make stim vector
    stimVec = zeros(1,size(calMats.(strains{1})(1).rawFluor,2));
    t = 1;
    for s = 1:length(stims)
        pauseD = durations(s,1)*frameRate;
        stimD = durations(s,2)*frameRate;
        
        t = t+pauseD;
        stimVec(t : t+stimD-1) = stims(s);      
        t = t+stimD;
    end
    
    for s = 1:length(strains)
        optoMats.(strains{s}).stim = stimVec;
        if smooth
            optoMats.(strains{s}).speed = getCleanSpeeds(calMats.(strains{s}).rawSpeed);
            optoMats.(strains{s}).fluor = getCleanFluors(calMats.(strains{s}).rawFluor);
        else
            optoMats.(strains{s}).speed = calMats.(strains{s}).rawSpeed;
            optoMats.(strains{s}).fluor = calMats.(strains{s}).rawFluor;
        end
        optoMats.(strains{s}).speed = calMats.(strains{s}).rawSpeed;
        optoMats.(strains{s}).fluor = calMats.(strains{s}).rawFluor;
    end
    
    return
end


function normFluors = getCleanFluors(oldFluors)
    global medWindow
    
    normFluors = NaN(size(oldFluors));
    
    for w = 1:size(oldFluors,1)
        fluor = oldFluors(w);
        
        %########################################################################EXPERIMENTAL to normalize to non-negative!!!!!!!
        fluor = fluor + abs(min(fluor))*(min(fluor)<0);%METHOD A
%         fluor(fluor < 0) = NaN;%METHOD C$$$$$$BEST------> first draft Rhoades et al 2018
%         fluor = (fluor - min(fluor))/(max(fluor) - min(fluor));%METHOD B
%       #####################################
        
%         fluor = filloutliers(fluor, 'pchip','quartiles');%------->THINKER         
%         fluor = filloutliers(fluor, 'pchip','movmedian',3);%------->THINKER
%         fluor = fillmissing(fluor,'movmedian',3);%------->THINKER
        fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');%smooth
            
        baseFluor = quantile(fluor, 0.25);%----------->SET BASELINE NORMALIZATION FOR STEADY STATE
        fluor = (fluor/baseFluor) - 1;
        
        normFluors(w, 1:length(fluor)) = fluor';  
    end
    
    return
end

function allSpeeds = getCleanSpeeds(speeds)
    global medWindow
    
    allSpeeds = NaN(size(speeds));
    for w = 1:size(speeds,1)
        newSpeed = speeds(w);
        newSpeed(newSpeed > 500) = NaN;
%         speed = filloutliers(speed, 'pchip','movmedian',3);%------->THINKER
%         speed = fillmissing(speed,'movmedian',3);%------->THINKER
        newSpeed = movmedian(newSpeed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');
        
        allSpeeds(w, 1:length(newSpeed)) = newSpeed;  
    end
    return
end

function rawSpeed = getRawSpeed(cals)
    rawSpeed = NaN(length(cals),max(arrayfun(@(x) length(x.Frame), cals)));
    for w = 1:length(cals)
        rawSpeed(w, cals(w).Frame(1):cals(w).Frame(end)) = cals(w).speed;
    end
end

function rawFluor = getRawFluor(cals)
    rawFluor = NaN(length(cals),max(arrayfun(@(x) length(x.Frame), cals)));
    for w = 1:length(cals)
        rawFluor(w, cals(w).Frame(1):cals(w).Frame(end)) = cals(w).sqintsub;
    end
end


function allTracks = poolTracks(calTracks, combine)

    allTracks = struct();

    for d = 1:length(calTracks)%d for day
        strains = fields(calTracks{d});
        for s = 1:length(strains)%s for strain
            if iscell(combine) && max(contains(strains{s}, combine))
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
