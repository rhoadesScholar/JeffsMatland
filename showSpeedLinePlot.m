function [avgs, stdErrs, intraWormAvgs] = showSpeedLinePlot(refeeds, lags, binTimes, frameRate)%conditions labels must be formatted: 'STRAINst###'
    if ~exist('frameRate', 'var')
        frameRate = 3;
    end
    if ~exist('binTimes', 'var')
        binTimes = [1.6666667 4]; % bin time in minutes
    end    
    
    relativeFrames = binTimes.*(60*frameRate); % get frames in bin
    grphFrames = relativeFrames + lags{1};
    
    meanies = struct();
    stdErries = struct();
    
    for t = 1:size(binTimes,1)
        [avg, stderr, intraWormAvg] = getIntraWormAvgs(refeeds, [grphFrames(t,1):grphFrames(t,2)]);
        if ~isempty(fields(meanies))
            meanies = [meanies; avg];
            stdErries = [stdErries; stderr];
            intraWormies = [intraWormies; intraWormAvg];
        else
            meanies = avg;
            stdErries = stderr;
            intraWormies = intraWormAvg;
        end
    end
    
    conditions = sort(fields(refeeds));
    for c = 1:length(conditions)
        condition = conditions{c};
        [start, ender] = regexpi(condition, 'st\d*');
        if ~isempty(start)
            strains{c} = condition(1:start-1);
            timePoints(c) = str2double(condition(start+2:ender));
        else
            [start, ender] = regexpi(condition, 'Fed');
            strains{c} = condition(1:start-1);
            timePoints(c) = 5;
        end
    end
    
    strains = unique(strains);
    timePoints = unique(timePoints);
    
    for t = 1:size(binTimes,1)
        for s = 1:length(strains)
            e = 1;
            for tP = 1:length(timePoints)
                if timePoints(tP)==5
                    time = 'Fed';
                else
                    time = num2str(timePoints(tP));
                end
                c = find(contains(conditions, strains{s}).*contains(conditions, time));
                avgs(t).(strains{s})(e) = meanies(t).(conditions{c});
                stdErrs(t).(strains{s})(e) = stdErries(t).(conditions{c});                
                intraWormAvgs(t).(strains{s})(e) = intraWormies(t).(conditions{c});
                e = e + 1;
            end
        end  
    end
    
    for t = 1:size(binTimes,1)
        figure; hold on;
        ylim([0 100]); ylabel('Speed (um/s)');
        xlim([-20 380]); xlabel('Starvation time (min)');
        xticks([5 30 90 180 360])
        colors = {'b' 'g' 'k' 'r' 'm' 'c' 'y'};
        for s = 1:length(strains)
            errorbar(timePoints, [avgs(t).(strains{s}).Speed].*1000, [stdErrs(t).(strains{s}).Speed].*1000,...
                ['.-' colors{s}], 'CapSize', 4, 'LineWidth', 1);%EVERY STRAIN MUST HAVE THE SAME TIMEPOINTS
        end
        if length(strains)==2
            for tP = 1:length(timePoints)
                [h, p] = ttest2([intraWormAvgs(t).(strains{1})(tP).Speed], [intraWormAvgs.(strains{2})(tP).Speed],...
                    'Alpha', 0.05/length(timePoints));%NOTE: HARD CODED STRAIN INDICES
                if h
                    testStr = sprintf('*%0.4f', p);
                else
                    testStr = sprintf('%0.4f', p);
                end
                y = max([avgs(t).(strains{1})(tP).Speed, avgs(t).(strains{2})(tP).Speed])*1000 + 10;
                if y >= max(ylim)
                    y = min(ylim) + 10;
                end
                text(timePoints(tP), double(y), testStr);
                if tP == 1
                    forAnova = [intraWormAvgs(t).(strains{1})(tP).Speed, intraWormAvgs(t).(strains{2})(tP).Speed];                    
                    anovaTimes(1:length([intraWormAvgs(t).(strains{1})(tP).Speed, intraWormAvgs(t).(strains{2})(tP).Speed])) = timePoints(tP);
                    anovaStrains(1:length([intraWormAvgs(t).(strains{1})(tP).Speed])) = strains(1);
                    anovaStrains(end+1:end+length([intraWormAvgs(t).(strains{2})(tP).Speed])) = strains(2);
                else
                    forAnova = [forAnova, intraWormAvgs(t).(strains{1})(tP).Speed, intraWormAvgs(t).(strains{2})(tP).Speed];                   
                    anovaTimes(end+1:end+length([intraWormAvgs(t).(strains{1})(tP).Speed, intraWormAvgs(t).(strains{2})(tP).Speed])) = timePoints(tP);
                    anovaStrains(end+1:end+length([intraWormAvgs(t).(strains{1})(tP).Speed])) = strains(1);
                    anovaStrains(end+1:end+length([intraWormAvgs(t).(strains{2})(tP).Speed])) = strains(2);
                end
            end
            anovan(forAnova, {anovaTimes, anovaStrains}, 'model', 2, 'varnames', {'Starvation Time', 'Strain'})
        end        
        legend(strains);
    end    

end