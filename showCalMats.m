function showCalMats(calMats, strains, showTogether)
    
    if isempty(strains)
        strains = fields(calMats);
    end
    if isempty(showTogether)
        showTogether = false;
    end

    fig = figure;
    hold on;
    if showTogether
        showStrainTracksStdErr(strain, num, speed, fluor, stdErrSpeed, stdErrFluor,...
            refed, frameRate, preSpan, postSpan)%, medWindow, medSpan, medBuf)
    else
        for s = 1:length(strains)
        t = [-sum(calMats.(strains{s}).refed == 0):(sum(calMats.(strains{s}).refed == 1) - 1)]/10;%t in seconds
        timey = 'sec';
        if max(t) > 300
            t = t/60;%t in minutes
            timey = 'min';
        end
        clear('lawnTime', 'lawnYs');
        
        lawnTime = 0:0.01:max(t);
        ys = [-1000 1000];
        lawnYs(1:length(lawnTime)) = [ys(1)];
        lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
        lawnTime = [lawnTime, flip(lawnTime)];
        w = 1;
        
        while w <= size(calMats.(strains{s}).fluors,1)            
            fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
            set(gca, 'xlim', [min(t) max(t)]);
            
            yyaxis right
            set(gca, 'YColor', 'b')
            set(gca, 'ylim', [0 250])
            title(sprintf('%s #%i, NSM Calcium vs. Speed', strains{s}, w));
            xlabel(sprintf('Time (%s)', timey));
            ylabel('Speed (um/sec)');
            patch([t NaN],[movmean(calMats.(strains{s}).speeds(w,:),50) NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1.5)

            yyaxis left
            ylabel('Fluoresence intensity (R.U.)');
            set(gca, 'YColor', [0 .8 0])
            set(gca, 'ylim', [-5 5])%#$#$#$#$#$#$#$#$#$#$#$#$#$#YLIM
            patch([t NaN],[movmean(calMats.(strains{s}).fluors(w,:),50) NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1.5)            
            
            grid on;
            
            disp('Press any key to continue');
            pause;
            if strcmp(fig.CurrentCharacter, 'b')
                w = w - 1;
                w = (w == 0) + w;
            elseif strcmp(fig.CurrentCharacter, 's')
                w = size(calMats.(strains{s}).fluors,1) + 1;
            elseif strcmp(fig.CurrentCharacter, 't')
                makeStim(calMats.(strains{s}).fluors(w,:), calMats.(strains{s}).refed, calMats.(strains{s}).speeds(w,:));
                fig.CurrentCharacter = ' ';
                w = w + 1;
            else
                w = w + 1;
            end
            clf;
        end
        end
    end
    close
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