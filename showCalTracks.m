function showCalTracks(calTracks, medWindow)
    if ~exist('medWindow', 'var')
        medWindow = [5 5];
    end
    if iscell(calTracks)
        allCals = calTracks;
    end
    c = length(calTracks);    
    
    medSpan = 50;
    medBuf = 5;

    fig = figure;
    hold on
    
    for d = 1:c
        if c > 1
            calTracks = allCals{d};
        end            
        strains = fields(calTracks);
        frameRate = calTracks.(strains{1})(1).frameRate;
        for s = 1:length(strains)
            w = 1;
            while w <= length(calTracks.(strains{s}))
                if medWindow == 0
                    speed = calTracks.(strains{s})(w).speed;
                else
                    speed = movmedian(calTracks.(strains{s})(w).speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(calTracks.(strains{s})(w).speed, medWindow, 'omitnan', 'truncate');
                end

                fluor = movmedian(calTracks.(strains{s})(w).sqintsub, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(calTracks.(strains{s})(w).sqintsub, medWindow, 'omitnan', 'truncate');
                preFedFluor = fluor(~calTracks.(strains{s})(w).refed);    
                if length(preFedFluor) > (medSpan + medBuf)
                    medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                else 
                    medInds = length(preFedFluor);
                end
                if medInds == 0
                    baseFluor = quantile(fluor, 0.25);
                    fprintf('mean dF/F = %0.4f\n',nanmean((fluor/baseFluor) - 1))
                else
                    baseFluor = nanmedian(preFedFluor(medInds));
                    if isempty(baseFluor) || isnan(baseFluor)
                        baseFluor = nanmean(preFedFluor);
                    end                    
                end
                normFluor = (fluor/baseFluor) - 1;
                
                pre = find(calTracks.(strains{s})(w).refed == 1,1) - 1;
                post = length(calTracks.(strains{s})(w).refed) - pre - 1;
                t = [-pre:post]/calTracks.(strains{s})(w).frameRate;%t in seconds
                timey = 'sec';
                if max(t) > 300
                    t = t/60;%t in minutes
                    timey = 'min';
                end
                
                ys = [-1000 1000];
                
                crossings = find(diff(calTracks.(strains{s})(w).refed) ~= 0);
                if isempty(crossings) && calTracks.(strains{s})(w).refed(1) == 1
                    crossings = 1;
                end
                if mod(length(crossings),2)
                    crossings(end + 1) = length(t);
                end
                for l = 1:2:length(crossings)
                    lawnTime = t(crossings(l):crossings(l+1));
                    lawnYs(1:length(lawnTime)) = [ys(1)];
                    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
                    lawnTime = [lawnTime, flip(lawnTime)];
                    %lawnYs = [lawnYs fliplr(lawnYs)];
                    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
                    clear lawnTime lawnYs;
                end
                
                yyaxis left
                plot(t, normFluor, 'Color', [0 .8 0])
                ylabel('Fluoresence intensity (R.U.)');
                set(gca, 'YColor', [0 .8 0])
                set(gca, 'ylim', [-1 4])
                grid on

                yyaxis right
                plot(t, speed, 'Color', 'b');
                title(sprintf('%s, NSM Calcium & Speed \n %s', strains{s}, calTracks.(strains{s})(w).name));
                xlabel(sprintf('Time (%s)', timey));
                ylabel('Speed (um/sec)');                
                
                set(gca, 'YColor', 'b')
                set(gca, 'ylim', [0 250])
                
                set(gca, 'xlim', [min(t) max(t)]);
                
                set(gcf, 'UserData', t)                
                drawnow
                disp('Press any key to continue');
                pause;
                if strcmp(fig.CurrentCharacter, 'b')
                    w = w - 1;
                    w = (w == 0) + w;
                elseif strcmp(fig.CurrentCharacter, 's')
                    w = length(calTracks.(strains{s})) + 1;
                else
                    w = w + 1;
                end
                clf;
                hold on
            end
        end
    end
    close
    return
end