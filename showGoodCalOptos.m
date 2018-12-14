function [optoTracks, optoMat] = showGoodCalOptos(calTracks, medWindow, combine, thresh, span, indie, stepSize)
%thresh-> median dF/F during [span seconds]
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    if iscell(calTracks)
        allCals = calTracks;
    end
    c = length(calTracks);    
    
    medSpan = 50;
    medBuf = 5;

    optoTracks = struct();
    
    for d = 1:c
        calTracks = allCals{d};
        strains = fields(calTracks);
        frameRate = calTracks.(strains{1})(1).frameRate;
        for s = 1:length(strains)
            for w = 1:length(calTracks.(strains{s}))
                if contains(calTracks.(strains{s})(w).name, 'opto', 'IgnoreCase', true) && ~contains(calTracks.(strains{s})(w).name, 'cntrl', 'IgnoreCase', true)
                    if medWindow == 0
                        speed = calTracks.(strains{s})(w).speed;
                    else
                        speed = movmedian(calTracks.(strains{s})(w).speed, medWindow, 'omitnan', 'Endpoints', 'shrink');
                    end
                    
                    fluor = calTracks.(strains{s})(w).sqintsub;
                    fluor(fluor < 0) = NaN;%$$$$$$$$$$$$$$$$$to normalize to non-negative$$$$$$$$$$$$$$
                    fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');
                    preFedFluor = fluor(~calTracks.(strains{s})(w).refed);    
                    if length(preFedFluor) > (medSpan + medBuf)
                        medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                    else 
                        medInds = length(preFedFluor);
                    end
                    baseFluor = nanmedian(preFedFluor(medInds));
                    if isempty(baseFluor) || isnan(baseFluor)
                        baseFluor = nanmean(preFedFluor);
                    end
                    normFluor = (fluor/baseFluor) - 1;

                    pre = find(calTracks.(strains{s})(w).refed == 1,1) - 1;
                    post = length(calTracks.(strains{s})(w).refed) - pre - 1;
                    t = [-pre:post]/calTracks.(strains{s})(w).frameRate;%t in seconds               

                    checkInds = [find(t==span(1)):find(t==span(2))];
                    include = nanmedian(normFluor(checkInds)) >= thresh;
%                     include = nanmedian(normFluor(checkInds)) <= thresh(2) && include;
%                     include = nanmean(normFluor(checkInds)) >= thresh;

                    if include
    %                     optoTracks = addOptoTracks(optoTracks, normFluor, speed, calTracks.(strains{s})(w).refed);
                        try
                            optoTracks.(strains{s})(end + 1) = calTracks.(strains{s})(w);
                        catch
                            optoTracks.(strains{s})(1) = calTracks.(strains{s})(w);
                        end
                        fprintf('%s added.\n', calTracks.(strains{s})(w).name);
                    end
                end
            end
        end
    end
    if combine && ~isempty(fields(optoTracks))
        conds = fields(optoTracks);
        allOptos.opto = optoTracks.(conds{1});
        for c = 2:length(conds)
            allOptos.opto = [allOptos.opto optoTracks.(conds{c})];
        end
        optoTracks = allOptos;
        optoMat = showAvgCalTracks(optoTracks, medWindow, indie, stepSize);
    end
    
    return
end

function optoTracks = addOptoTracks(oldOptos, fluor, speed, refed)
%     persistent o;    
    newOptos.opto.speeds = speed;
    newOptos.opto.refed = refed;
    newOptos.opto.fluors = fluor;
    if (isfield(oldOptos,'opto'))
        optoTracks = [oldOptos newOptos];
    else
       optoTracks = newOptos;
    end
    
end