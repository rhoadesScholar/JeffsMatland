function cleanMats = showCleanCalTracks(calTracks, medWindow, thresh, combine, varargin)
    medSpan = 60;
    medBuf = 3;
    
    if length(varargin)>=1
        stepSize = varargin{1};
    else
        stepSize = false;
    end

    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    if ~exist('thresh', 'var')
        thresh = 1.75;
    end
    if ~exist('combine', 'var') || combine
        calTracks = poolTracks(calTracks, combine);
    end
    
    strains = fields(calTracks);    
    frameRate = calTracks.(strains{1})(1).frameRate;
    
    for s = 1:length(strains)%get pretty data
        cleanTracks = struct();
        strainTracks = calTracks.(strains{s});
        
        strainTracks = splitEvents(strainTracks, strains{s}, medSpan, medBuf, thresh);
        
        preSpan = max(arrayfun(@(x) find(x.refed, 1), strainTracks)) - 1;
        postSpan = max(arrayfun(@(x) max([find(~flip(x.refed), 1) isempty(find(~flip(x.refed), 1))*length(x.refed)]), strainTracks)) - 1;
        
        cleanTracks.refed = [zeros(1, preSpan) ones(1, postSpan)];
        if stepSize
            cleanTracks.speeds = reCalcSpeeds(strainTracks, preSpan, postSpan, medWindow, stepSize);
        else
            cleanTracks.speeds = getCleanSpeeds(strainTracks, preSpan, postSpan, medWindow);
        end
        
        cleanTracks.fluors = getCleanFluors(strainTracks, preSpan, postSpan, medWindow, medSpan, medBuf);
        cleanMats.(strains{s}) = cleanTracks;                
    end
    
    showCalMats(cleanMats, strains);
end

function splitTracks = splitEvents(strainTracks, strain, medSpan, medBuf, thresh)
    splitTracks = struct();
    e = 1;
    for w = 1:length(strainTracks)
        
        totMedian = nanmedian(strainTracks(w).bgmedian);
        include = [strainTracks(w).bgmedian <= thresh*totMedian];
        strainTracks(w).sqintsub(~include) = NaN;
        
        crossings = find(diff(strainTracks(w).refed) ~= 0);
        crossings = [0; crossings; length(strainTracks(w).refed)];                
        if contains(strain, 'fed', 'IgnoreCase', true)
            if length(crossings) == 2
                span = [1:crossings(2)];
                
                preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
                postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1);
                medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                
                if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) >= medSpan/2
                    splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                    splitTracks(e).refed = strainTracks(w).refed(span);
                    splitTracks(e).speed = strainTracks(w).speed(span);
                    splitTracks(e).xc = strainTracks(w).xc(span);
                    splitTracks(e).yc = strainTracks(w).yc(span);
                    splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                    splitTracks(e).frameRate = strainTracks(w).frameRate;
                    splitTracks(e).bgmedian = strainTracks(w).bgmedian;
                    e = e + 1;
                end
            else
                for c = 1:2:length(crossings)-2
                    span = [crossings(c)+1:(crossings(c+2))];
                    
                    preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
                    postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1); 
                    medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                    if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) > medSpan/2
                        splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                        splitTracks(e).refed = strainTracks(w).refed(span);
                        splitTracks(e).speed = strainTracks(w).speed(span);
                        splitTracks(e).xc = strainTracks(w).xc(span);
                        splitTracks(e).yc = strainTracks(w).yc(span);
                        splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                        splitTracks(e).frameRate = strainTracks(w).frameRate;
                        splitTracks(e).bgmedian = strainTracks(w).bgmedian;
                        e = e + 1;
                    end
                end
            end
        elseif contains(strain, 'food', 'IgnoreCase', true)
            
%             preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
%             postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1);
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
            if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) > medSpan/2
                splitTracks(e).sqintsub = strainTracks(w).sqintsub;
                splitTracks(e).refed = strainTracks(w).refed;
                splitTracks(e).speed = strainTracks(w).speed;
                splitTracks(e).xc = strainTracks(w).xc;
                splitTracks(e).yc = strainTracks(w).yc;
                splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                splitTracks(e).frameRate = strainTracks(w).frameRate;
                splitTracks(e).bgmedian = strainTracks(w).bgmedian;
                e = e + 1;
            end
        elseif ~strainTracks(w).refed(1)
            if length(crossings) == 2
                span = [1:crossings(2)];
            else
                span = [1:(crossings(3))];
            end
            
            preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
            postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1);
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
            if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) > medSpan/2
                splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                splitTracks(e).refed = strainTracks(w).refed(span);
                splitTracks(e).speed = strainTracks(w).speed(span);
                splitTracks(e).xc = strainTracks(w).xc(span);
                splitTracks(e).yc = strainTracks(w).yc(span);
                splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                splitTracks(e).frameRate = strainTracks(w).frameRate;
                splitTracks(e).bgmedian = strainTracks(w).bgmedian;
                e = e + 1;
            end
        end
    end
    
    return
end

function normFluors = getCleanFluors(cals, preSpan, postSpan, medWindow, medSpan, medBuf)
    preFluors = NaN(length(cals), preSpan);
    postFluors = NaN(length(cals),postSpan);
    
    for w = 1:length(cals)
        
        fluor = movmedian(cals(w).sqintsub, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).sqintsub, medWindow, 'omitnan', 'truncate');
        preFedFluor = fluor(~cals(w).refed);
        if length(preFedFluor) > (medSpan + medBuf)
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
        else 
            medInds = length(preFedFluor);
        end
%         ####################$#$#$#$#$#$#$#$#$#$#
%         baseFluor = nanmedian(preFedFluor(medInds));
        baseFluor = nanmean(preFedFluor(medInds));
        
        if isempty(baseFluor) || isnan(baseFluor)
            baseFluor = nanmean(preFedFluor);
        end
        fluor = (fluor/baseFluor) - 1;
        %now normalized:
        preFedFluor = fluor(~cals(w).refed);
        postFedFluor = fluor(cals(w).refed == 1);
        
        preFluors(w, 1:length(preFedFluor)) = fliplr(preFedFluor');%NOTE: in reverse order for alignment purposes
        postFluors(w, 1:length(postFedFluor)) = postFedFluor';  
    end
    
    normFluors = [fliplr(preFluors) postFluors];
    return
end

function allSpeeds = getCleanSpeeds(cals, preSpan, postSpan, medWindow)
    preSpeeds = NaN(length(cals), preSpan);
    postSpeeds = NaN(length(cals),postSpan);
    
    for w = 1:length(cals)
        speed = movmedian(cals(w).speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');        
        
        preFedSpeed = speed(~cals(w).refed);
        postFedSpeed = speed(cals(w).refed == 1);
        
        preSpeeds(w, 1:length(preFedSpeed)) = fliplr(preFedSpeed');%NOTE: in reverse order for alignment purposes
        postSpeeds(w, 1:length(postFedSpeed)) = postFedSpeed';  
    end
    
     allSpeeds = [fliplr(preSpeeds) postSpeeds];
    return
end

function newSpeeds = reCalcSpeeds(cals, preSpan, postSpan, medWindow, stepSize)
    %stepSize = 4;%must be even
    
    newCals = struct();
    for w = 1:length(cals)%each worm
        x = cals(w).xc;
        x = medfilt1(x, 3, 'omitnan', 'truncate');%
        dx = arrayfun(@(i) x(i+stepSize) - x(i), [stepSize/2:length(x)-stepSize]);
        dx = [NaN(stepSize/2, 1); dx'; NaN(stepSize, 1)];
        
        y = cals(w).yc;
        y = medfilt1(y, 3, 'omitnan', 'truncate');%
        dy = arrayfun(@(i) y(i+stepSize) - y(i), [stepSize/2:length(y)-stepSize]);
        dy = [NaN(stepSize/2, 1); dy'; NaN(stepSize, 1)];
        
        dist = sqrt(dx.^2 + dy.^2);
        dist = dist*cals(w).pixelSize;
        newCals(w).speed = dist*(cals(w).frameRate/stepSize);
        newCals(w).refed = cals(w).refed;
        
    end
    newSpeeds = getCleanSpeeds(newCals, preSpan, postSpan, medWindow);
    
    return
end

function allTracks = poolTracks(calTracks, combine)

    allTracks = struct();

    for d = 1:length(calTracks)%d for day
        strains = fields(calTracks{d});
        for s = 1:length(strains)%s for strain
            if iscell(combine) && max(contains(combine,strains{s}))
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
