function [allTracks, wormsUsed, calMats, avgs, stdErr] = showPooledAvgOptoTracks(calTracks, combine, stims, durations, medWindow, varargin)%calTracks should be cell array of structures
                                                              %combine is boolean or cell of strains to combine
    
                                                              
                                                              
  ########NOT READY####                                                              
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
    
    [calMats, avgs, stdErr] = showAvgOptoCalTracks(allTracks, stims, durations, medWindow, indie, stepSize);

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

function [strainMats, avgs, stdErr] = showAvgOptoCalTracks(calTracks, stims, durations, medWindow, varargin)
    medSpan = 300;%30;----> first draft Rhoades et al 2018
    medBuf = 5;%3;----> first draft Rhoades et al 2018
    
    cmap = getCmap;
    clim = [-1 4];

    if length(varargin)>=1
        indie = varargin{1};
    else
        indie = false;%set show individual traces or stdErr
    end
    if length(varargin)>=2
        stepSize = varargin{2};
    else
        stepSize = false;
    end

    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    strains = fields(calTracks);
    avgs = struct();
    stdErr = struct();
    strainMats = struct();
    frameRate = calTracks.(strains{1})(1).frameRate;
    
    for s = 1:length(strains)%get pretty data
        cleanTracks = struct();
        strainTracks = calTracks.(strains{s});
        
        [strainTracks] = splitEvents(strainTracks, stims, durations, medSpan, medBuf);
        
        preSpan = max(arrayfun(@(x) find(x.refed, 1), strainTracks)) - 1;
        postSpan = max(arrayfun(@(x) max([find(~flip(x.refed), 1) isempty(find(~flip(x.refed), 1))*length(x.refed)]), strainTracks)) - 1;
        
        cleanTracks.refed = [zeros(1, preSpan) ones(1, postSpan)];
        if stepSize
            cleanTracks.speeds = reCalcSpeeds(strainTracks, preSpan, postSpan, medWindow, stepSize);
        else
            cleanTracks.speeds = getCleanSpeeds(strainTracks, preSpan, postSpan, medWindow);
        end
        
        cleanTracks.fluors = getCleanFluors(strainTracks, preSpan, postSpan, medWindow, medSpan, medBuf);
%         strainTracks = splitEvents(strainTracks, strains{s}, medSpan, medBuf, thresh);%-------->>>>>NOT ORIGINAL
        
        if length(strainTracks) > 1
            avgs.(strains{s}).speed = nanmean(cleanTracks.speeds);%----> first draft Rhoades et al 2018
            avgs.(strains{s}).fluor = nanmean(cleanTracks.fluors);%----> first draft Rhoades et al 2018
%             avgs.(strains{s}).speed = nanmedian(cleanTracks.speeds);
%             avgs.(strains{s}).fluor = nanmedian(cleanTracks.fluors);
            if ~indie
                stdErr.(strains{s}).speed = std(cleanTracks.speeds,'omitnan')./sqrt(sum(~isnan([cleanTracks.speeds])));
                stdErr.(strains{s}).fluor = std(cleanTracks.fluors,'omitnan')./sqrt(sum(~isnan([cleanTracks.fluors])));
            end
        else
            avgs.(strains{s}).speed = (cleanTracks.speeds);
            avgs.(strains{s}).fluor = (cleanTracks.fluors);
        
            stdErr.(strains{s}).speed = 0;
            stdErr.(strains{s}).fluor = 0;
        end
            
        fprintf('%s, n of %i\n', strains{s}, size(cleanTracks.fluors, 1))
        strainMats.(strains{s}) = cleanTracks;
        
        if ~indie
            [t, timey] = showStrainTracksStdErr(strains{s}, length(strainTracks), avgs.(strains{s}).speed, avgs.(strains{s}).fluor, ...
                stdErr.(strains{s}).speed, stdErr.(strains{s}).fluor, cleanTracks.refed, frameRate, preSpan, postSpan);%, medWindow, medSpan, medBuf);
            fig = gcf;
            figure
            imagesc(cleanTracks.fluors, clim);
            title(sprintf('%s (n = %i), NSM Calcium \n(median window smoothing = -%0.2f  to +%0.2f seconds)', strains{s}, length(strainTracks), (medWindow(1)/frameRate), (medWindow(2)/frameRate)));
            xlabel(sprintf('Time (%s)', timey));
            zt = find(t == 0);
            if strcmp(timey, 'min')
                st = mod(zt, 600);               
                st = st + (st==0);
                tInds = [st:600:length(cleanTracks.refed)];
            else
                st = mod(zt, 10);
                st = st + (st==0);
                tInds = [st:10:length(cleanTracks.refed)];
            end
            xticks(tInds);
            xticklabels(t(tInds));
            xlim([zt-300, zt+2400]);
            
            ax = gca;
            colormap(ax, cmap);
            c = colorbar;
            c.Label.String = 'Fluorescence';
            hold on
            
            plot([preSpan preSpan], [0 length(strainTracks)+ 2], 'Color', 'm', 'LineWidth', 1);
            
            %%%%%%make subplot
            title('');
            ylabel('Worm#');
            ax = gca;
            this = gcf;
            set(ax, 'Parent', fig);
            set(ax, 'Position', [0.5 0.7 0.35 0.2]);
            close(this)
            %%%%%
            
        else
            showStrainTracksIndie(strains{s}, length(strainTracks), avgs.(strains{s}).speed, avgs.(strains{s}).fluor, ...
                cleanTracks.speeds, cleanTracks.fluors, cleanTracks.refed, frameRate, preSpan, postSpan, medWindow);
        end
    end

end

function [splitTracks] = splitEvents(strainTracks, stims, durations, medSpan, medBuf)
    splitTracks = struct();
    e = 1;
    for w = 1:length(strainTracks)
        t = 1;
        for d = 1:length(stims)
            pauseD = durations(d,1);
            stimD = durations(d,2);
            
            preStim = strainTracks(w).sqintsub(t : t+pauseD-1);
            stimFluor = strainTracks(w).sqintsub(t+pauseD : t+pauseD+stimD-1);
            postStimFluor = strainTracks(w).sqintsub(t+pauseD+stimD : t+pauseD+stimD+durations(d+1,1)-1);
            
            medInds = (length(preStim) - (medSpan + medBuf)):(length(preStim)- medBuf);
            if (length(preStim) - (medSpan + medBuf)) > 0 && sum(~isnan(preStim(medInds))) > medSpan/2 && sum(~isnan(stimFluor(1:medSpan+medBuf))) > medSpan/2
                splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                splitTracks(e).refed = strainTracks(w).refed(span);
                splitTracks(e).speed = strainTracks(w).speed(span);
                splitTracks(e).xc = strainTracks(w).xc(span);
                splitTracks(e).yc = strainTracks(w).yc(span);
                splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                splitTracks(e).frameRate = strainTracks(w).frameRate;
                splitTracks(e).bgmedian = strainTracks(w).bgmedian(span);
                e = e + 1;
            end
            t = t+pauseD+stimD;
        end
    end
    
    return
end

function normFluors = getCleanFluors(cals, preSpan, postSpan, medWindow, medSpan, medBuf)
    preFluors = NaN(length(cals), preSpan);
    postFluors = NaN(length(cals),postSpan);
    
    for w = 1:length(cals)
        fluor = cals(w).sqintsub;
        
        %########################################################################EXPERIMENTAL to normalize to non-negative!!!!!!!
        fluor = fluor + abs(min(fluor))*(min(fluor)<0);%METHOD A
%         fluor(fluor < 0) = NaN;%METHOD C$$$$$$BEST------> first draft Rhoades et al 2018
%         fluor = (fluor - min(fluor))/(max(fluor) - min(fluor));%METHOD B
%       #####################################
        
%         fluor = filloutliers(fluor, 'pchip','quartiles');%------->THINKER         
%         fluor = filloutliers(fluor, 'pchip','movmedian',3);%------->THINKER
%         fluor = fillmissing(fluor,'movmedian',3);%------->THINKER
        fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');%smooth
               
        preFedFluor = fluor(~cals(w).refed);
        if length(preFedFluor) > (medSpan + medBuf)
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
        else 
            medInds = 1:length(preFedFluor);
        end
%         ####################$#$#$#$#$#$#$#$#$#$#
%         baseFluor = nanmedian(preFedFluor(medInds));
        baseFluor = nanmean(preFedFluor(medInds));%----> first draft Rhoades et al 2018
        
        if isempty(baseFluor) || isnan(baseFluor)
%             baseFluor = nanmedian(preFedFluor);
            baseFluor = nanmean(preFedFluor);%----> first draft Rhoades et al 2018
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
        speed = cals(w).speed;
        speed(speed > 500) = NaN;
%         speed = filloutliers(speed, 'pchip','movmedian',3);%------->THINKER
%         speed = fillmissing(speed,'movmedian',3);%------->THINKER
        speed = movmedian(speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');        
        
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

function [t, timey] = showStrainTracksStdErr(strain, num, speed, fluor, stdErrSpeed, stdErrFluor,...
    refed, frameRate, preSpan, postSpan)%, medWindow, medSpan, medBuf)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    xLim = [-30 240];
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
        xLim = [-0.5 4];
    end
    
    figure;
    hold on;
    title(sprintf('%s (n = %i), NSM Calcium vs. Speed\n', strain, num)); %(median window smoothing = -%0.2f  to +%0.2f seconds)
    xlabel(sprintf('Time (%s)', timey));
    
    
    xs = [min(t) max(t)];    
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);

    ys = [-9999 9999];
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];
    
    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.13, 'LineStyle', ':');
    
    yyaxis left
    err = stdErrFluor;
    errorshade(t,[fluor + err],[fluor - err], [0 .8 0]);
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1)
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])
    set(gca, 'ylim', [-2 2])
    grid on
    
    yyaxis right
    err = stdErrSpeed;
    errorshade(t,[speed + err],[speed - err], 'b');
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1)
    ylabel('Speed (um/sec)');
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    set(gca, 'xlim', xLim);%###################XLIM
%     set(gca, 'xlim', [-(medSpan+medBuf)/60 4]);
    
end

function showStrainTracksIndie(strain, num, speed, fluor, indieSpeeds, indieFluors,...
    refed, frameRate, preSpan, postSpan, medWindow)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    xLim = [-30 240];
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
        xLim = [-0.5 4];
    end
    xs = [min(t) max(t)];
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);
    
    figure;
    hold on;
    title(sprintf('%s (n = %i), NSM Calcium vs. Speed\n(median window smoothing = -%0.2f  to +%0.2f seconds)', strain, num, (medWindow(1)/frameRate), (medWindow(2)/frameRate)));
    xlabel(sprintf('Time (%s)', timey));  
    set(gca, 'xlim', xLim);%###################XLIM   
    
    yyaxis left    
    ylabel('Speed (um/sec)');
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    yyaxis right
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])    
    set(gca, 'ylim', [-2 2]) 
    grid on
    
    ys = [-9999 9999];
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];
    
    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
    
    for w = 1:size(indieFluors,1)
        disp('Press any key to continue');
        pause;
        yyaxis right
        patch([t NaN],[indieFluors(w, :) NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 0.0001, 'EdgeAlpha', 0.2)
        yyaxis left        
        patch([t NaN],[indieSpeeds(w, :) NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 0.0001, 'EdgeAlpha', 0.2)
    end
    
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 2)
    yyaxis left
%     set(gca, 'YColor', 'b')
%     set(gca, 'ylim', [0 250])

    yyaxis right
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 2)
%     ylabel('Fluoresence intensity (R.U.)');
%     set(gca, 'YColor', [0 .8 0])    
    
end

function cmap = getCmap

cmap = [0         0         0
         0         0    0.0470
         0         0    0.0940
         0         0    0.1410
         0         0    0.1880
         0         0    0.2350
         0         0    0.2820
         0         0    0.3291
         0         0    0.3761
         0         0    0.4231
         0         0    0.4701
         0         0    0.5171
         0         0    0.5641
         0         0    0.6111
         0         0    0.7407
         0         0    0.8704
         0         0    1.0000
         0    0.3333    1.0000
         0    0.6667    1.0000
         0    1.0000    1.0000
         0    0.9714    0.8571
         0    0.9429    0.7143
         0    0.9143    0.5714
         0    0.8857    0.4286
         0    0.8571    0.2857
         0    0.8286    0.1429
         0    0.8000         0
    0.0769    0.8154         0
    0.1538    0.8308         0
    0.2308    0.8462         0
    0.3077    0.8615         0
    0.3846    0.8769         0
    0.4615    0.8923         0
    0.5385    0.9077         0
    0.6154    0.9231         0
    0.6923    0.9385         0
    0.7692    0.9538         0
    0.8462    0.9692         0
    0.9231    0.9846         0
    1.0000    1.0000         0
    1.0000    0.9231         0
    1.0000    0.8462         0
    1.0000    0.7692         0
    1.0000    0.6923         0
    1.0000    0.6154         0
    1.0000    0.5385         0
    1.0000    0.4615         0
    1.0000    0.3846         0
    1.0000    0.3077         0
    1.0000    0.2308         0
    1.0000    0.1538         0
    1.0000    0.0769         0
    1.0000         0         0
    0.9545         0         0
    0.9091         0         0
    0.8636         0         0
    0.8182         0         0
    0.7727         0         0
    0.7273         0         0
    0.6818         0         0
    0.6364         0         0
    0.5909         0         0
    0.5455         0         0
    0.5000         0         0];
% 0         0    0
%          0         0    0.6111
%          0         0    0.6597
%          0         0    0.7083
%          0         0    0.7569
%          0         0    0.8056
%          0         0    0.8542
%          0         0    0.9028
%          0         0    0.9514
%          0         0    1.0000
%          0    0.0833    1.0000
%          0    0.1667    1.0000
%          0    0.2500    1.0000
%          0    0.3333    1.0000
%          0    0.4167    1.0000
%          0    0.5000    1.0000
%          0    0.5833    1.0000
%          0    0.6667    1.0000
%          0    0.7500    1.0000
%          0    0.8333    1.0000
%          0    0.9167    1.0000
%          0    1.0000    1.0000
%          0    0.9818    0.9091
%          0    0.9636    0.8182
%          0    0.9455    0.7273
%          0    0.9273    0.6364
%          0    0.9091    0.5455
%          0    0.8909    0.4545
%          0    0.8727    0.3636
%          0    0.8545    0.2727
%          0    0.8364    0.1818
%          0    0.8182    0.0909
%          0    0.8000         0
%     0.0909    0.8182         0
%     0.1818    0.8364         0
%     0.2727    0.8545         0
%     0.3636    0.8727         0
%     0.4545    0.8909         0
%     0.5455    0.9091         0
%     0.6364    0.9273         0
%     0.7273    0.9455         0
%     0.8182    0.9636         0
%     0.9091    0.9818         0
%     1.0000    1.0000         0
%     1.0000    0.9286         0
%     1.0000    0.8571         0
%     1.0000    0.7857         0
%     1.0000    0.7143         0
%     1.0000    0.6429         0
%     1.0000    0.5714         0
%     1.0000    0.5000         0
%     1.0000    0.4286         0
%     1.0000    0.3571         0
%     1.0000    0.2857         0
%     1.0000    0.2143         0
%     1.0000    0.1429         0
%     1.0000    0.0714         0
%     1.0000         0         0
%     0.9167         0         0
%     0.8333         0         0
%     0.7500         0         0
%     0.6667         0         0
%     0.5833         0         0
%     0.5000         0         0];
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