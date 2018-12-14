function cleanMats = showCleanSteadyCalTracks(calTracks, medWindow, thresh, combine, stepSize, buf)    
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    if ~exist('thresh', 'var')
        thresh = 1.75;
    end
    if ~exist('buf', 'var') 
        buf = 1;
    end
    if ~exist('stepSize', 'var') 
        stepSize = false;
    end
    if ~exist('combine', 'var') 
        combine = true;
    end
    if combine
       calTracks = poolTracks(calTracks, combine);
    end
    
    strains = fields(calTracks);    
    
    for s = 1:length(strains)%get pretty data
        cleanTracks = struct();
        strainTracks = calTracks.(strains{s});
        
        strainTracks = cleanEvents(strainTracks, thresh, buf);
        if stepSize
            [allSpeeds, allX, allY] = reCalcSpeeds(strainTracks, medWindow, stepSize);
            cleanTracks.speeds = allSpeeds;
            cleanTracks.xs = allX;
            cleanTracks.ys = allY;
        else
            [allSpeeds, allX, allY] = getCleanSpeeds(strainTracks, medWindow);
            cleanTracks.speeds = allSpeeds;
            cleanTracks.xs = allX;
            cleanTracks.ys = allY;
        end
        
        cleanTracks.fluors = getCleanFluors(strainTracks, medWindow);
        cleanMats.(strains{s}) = cleanTracks;
        fluorMeans(s) = nanmean(nanmean(cleanTracks.fluors, 1));%NEEDS SOME THOUGHT
        fluorStdErr(s) = std(nanmean(cleanTracks.fluors, 1))/sqrt(size(cleanTracks.fluors,2));%ISH
    end
    
    figure;
    hold on
    bar(fluorMeans);
    xticks(1:length(strains));
    xticklabels(strains);
    errorbar(fluorMeans, fluorStdErr,'.')
    showCals(cleanMats, strains);
    plotSteadyCals(cleanMats, buf);
end

function cleanTracks = cleanEvents(strainTracks, thresh, buf)
    cleanTracks = struct();
    for w = 1:length(strainTracks)        
        totMedian = nanmedian(strainTracks(w).bgmedian);
        include = [strainTracks(w).bgmedian <= thresh*totMedian];
        strainTracks(w).sqintsub(~include) = NaN;                     
        cleanTracks(w).sqintsub = strainTracks(w).sqintsub;
        cleanTracks(w).refed = strainTracks(w).refed;
        cleanTracks(w).speed = strainTracks(w).speed;
        cleanTracks(w).xc = strainTracks(w).xc;
        cleanTracks(w).yc = strainTracks(w).yc;
        cleanTracks(w).pixelSize = strainTracks(w).pixelSize;
        cleanTracks(w).frameRate = strainTracks(w).frameRate;
        cleanTracks(w).bgmedian = strainTracks(w).bgmedian; 
        
        maxX(w) = max(strainTracks(w).xc);
        minX(w) = min(strainTracks(w).xc);
        maxY(w) = max(strainTracks(w).yc);
        minY(w) = min(strainTracks(w).yc);
    end
    
    
    maxX = max(filloutliers(maxX, 'clip', 'mean'));
    minX = min(filloutliers(minX, 'clip', 'mean'));
    
    maxY = max(filloutliers(maxY, 'clip', 'mean'));    
    minY = min(filloutliers(minY, 'clip', 'mean'));
    
    xc = minX + (maxX - minX)/2;
    yc = minY + (maxY - minY)/2;
    r = min([(maxX - minX)/2 (maxY - minY)/2]);
    %         scircleg%MANUAL CIRCLE
    for w = 1:length(strainTracks)                
        include = [cleanTracks(w).xc <= (xc + r*buf)].*[cleanTracks(w).xc >= (xc - r*buf)]...
            .*[cleanTracks(w).yc <= (yc + r*buf)].*[cleanTracks(w).yc >= (yc - r*buf)];
        cleanTracks(w).sqintsub(~include) = NaN;                             
    end
    
    return
end

function normFluors = getCleanFluors(cals, medWindow)
    normFluors = NaN(length(cals), max(arrayfun(@(x) length(x.sqintsub), cals)));
    for w = 1:length(cals)
        fluor = cals(w).sqintsub;
%         outLows = fluor;
%         outLows([fluor > nanmean(fluor)]) = nanmean(fluor);
%         [outLows,TF,~,~,center] = filloutliers(outLows, 'linear', 'gesd');
%         fluor(TF) = outLows(TF);
%         [fluor,TF,lower,upper,center] = filloutliers(fluor, 'center', 'gesd');%'movmedian', medWindow);
        fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).sqintsub, medWindow, 'omitnan', 'truncate');
%         ####################$#$#$#$#$#$#$#$#$#$#
%         baseFluor = nanmedian(fluor);
%         baseFluor = nanmean(fluor);
        baseFluor = quantile(fluor, 0.125);
%         baseFluor = abs(lower);
        
        fluor = (fluor/baseFluor) - 1;
        %now normalized:
        normFluors(w, 1:length(fluor)) = fluor; 
    end
    
    return
end

function [allSpeeds, allX, allY] = getCleanSpeeds(cals, medWindow)
    allSpeeds = NaN(length(cals), max(arrayfun(@(x) length(x.speed), cals)));
    allX = NaN(length(cals), max(arrayfun(@(x) length(x.xc), cals)));
    allY = NaN(length(cals), max(arrayfun(@(x) length(x.yc), cals)));
    for w = 1:length(cals)
        speed = movmedian(cals(w).speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');        
        
        allSpeeds(w,1:length(speed)) = speed;
        allX(w,1:length(cals(w).xc)) = cals(w).xc;
        allY(w,1:length(cals(w).yc)) = cals(w).yc;
    end
    return
end

function [newSpeeds, allX, allY] = reCalcSpeeds(cals, medWindow, stepSize)
    %stepSize = 4;%must be even
    
    newCals = struct();
    for w = 1:length(cals)%each worm
        x = cals(w).xc;
        x = medfilt1(x, 3, 'omitnan', 'truncate');%
        dx = arrayfun(@(i) x(i+stepSize) - x(i), [1:length(x) - stepSize]);%[stepSize/2:length(x)-stepSize]);
        endDx = arrayfun(@(i) x(end) - x(i), [(length(x) - stepSize) + 1 : length(x) - 1]);%*new
        dx = [dx'; endDx'; NaN];%[NaN(stepSize/2, 1); dx'; NaN(stepSize, 1)];
        
        y = cals(w).yc;
        y = medfilt1(y, 3, 'omitnan', 'truncate');%
        dy = arrayfun(@(i) y(i+stepSize) - y(i), [1:length(y) - stepSize]);%[stepSize/2:length(x)-stepSize]);
        endDy = arrayfun(@(i) y(end) - y(i), [(length(y) - stepSize) + 1 : length(y) - 1]);%*new
        dy = [dy'; endDy'; NaN];%[NaN(stepSize/2, 1); dy'; NaN(stepSize, 1)];
        
        dist = sqrt(dx.^2 + dy.^2);
        dist = dist*cals(w).pixelSize;
        clear steps
        steps(1:(length(dist) - stepSize)) = stepSize;
        steps([(length(y) - stepSize) + 1 : length(y)]) = [(stepSize - 1):-1:1, 1];
        newCals(w).speed = dist./(steps'/cals(w).frameRate);
        newCals(w).xc = x;
        newCals(w).yc = y;        
    end
    [newSpeeds, allX, allY] = getCleanSpeeds(newCals, medWindow);
    
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

function showCals(calMats, strains)
    
    if isempty(strains)
        strains = fields(calMats);
    end

    fig = figure;
    hold on;
    
    for s = 1:length(strains)
        w = 1;
        
        while w <= size(calMats.(strains{s}).fluors,1)            
            t = [1:length(calMats.(strains{s}).speeds)]/10;%t in seconds
            timey = 'sec';
            if max(t) > 300
                t = t/60;%t in minutes
                timey = 'min';
            end
            
            set(gca, 'xlim', [min(t) max(t)]);
            
            yyaxis right
            set(gca, 'YColor', 'b')
            set(gca, 'ylim', [0 600])
            title(sprintf('%s #%i, NSM Calcium vs. Speed', strains{s}, w));
            xlabel(sprintf('Time (%s)', timey));
            ylabel('Speed (um/sec)');
            patch([t NaN],[movmean(calMats.(strains{s}).speeds(w,:),1) NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1.5)

            yyaxis left
            ylabel('Fluoresence intensity (R.U.)');
            set(gca, 'YColor', [0 .8 0])
            set(gca, 'ylim', [-5 5])%#$#$#$#$#$#$#$#$#$#$#$#$#$#YLIM
            patch([t NaN],[movmean(calMats.(strains{s}).fluors(w,:),1) NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1.5)            
            
            grid on;
            
            disp('Press any key to continue');
            pause;
            if strcmp(fig.CurrentCharacter, 'b')
                w = w - 1;
                w = (w == 0) + w;
            elseif strcmp(fig.CurrentCharacter, 's')
                w = size(calMats.(strains{s}).fluors,1) + 1;
            else
                w = w + 1;
            end
            clf;
        end
    end
    close
    return
end

function plotSteadyCals(cleanMats, buf)
    strains = fields(cleanMats);
    circ = struct();
    for s = 1:length(strains)
        figure;
        hold on
        colorbar;
        colormap(hsv)
        title(sprintf('%s, NSM Calcium by position', strains{s}));
        for w = 1:size(cleanMats.(strains{s}).speeds,1)
            x = [cleanMats.(strains{s}).xs(w,:) NaN];
            y = [cleanMats.(strains{s}).ys(w,:) NaN];
            c = [cleanMats.(strains{s}).fluors(w,:) NaN];
            patch(x,y, c,'EdgeColor','interp', 'LineWidth', 1.25);
%             disp('Press any key to continue');
%             pause
        end
        maxX = max(cleanMats.(strains{s}).xs, [], 2);
        maxX = max(filloutliers(maxX, 'clip', 'quartiles'));
        
        minX = min(cleanMats.(strains{s}).xs, [], 2);
        minX = min(filloutliers(minX, 'clip', 'quartiles'));
        
        maxY = max(cleanMats.(strains{s}).ys, [], 2);
        maxY = max(filloutliers(maxY, 'clip', 'quartiles'));
        
        minY = min(cleanMats.(strains{s}).ys, [], 2);
        minY = min(filloutliers(minY, 'clip', 'quartiles'));
        
        xc = minX + (maxX - minX)/2;
        yc = minY + (maxY - minY)/2;
        r = min([(maxX - minX)/2 (maxY - minY)/2]);
        viscircles([xc yc], r*buf);

    end
end