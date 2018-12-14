function showPooledCalTracks(calTracks, combine, medWindow)%calTracks should be cell array of structures
                                                              %combine is boolean or cell of strains to combine
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end

    if ~exist('combine', 'var')
        combine = true;
    end
    
    allTracks = poolTracks(calTracks, combine);
    
    showCalTracks(allTracks, medWindow);

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

function showCalTracks(calTracks, medWindow)
    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    
    strains = fields(calTracks);
    frameRate = calTracks.(strains{1})(1).frameRate;
    figure;
    for s = 1:length(strains)
        for w = 1:length(calTracks.(strains{s}))
            if medWindow == 0
                speed = calTracks.(strains{s})(w).speed;
            else
                speed = movmedian(calTracks.(strains{s})(w).speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(calTracks.(strains{s})(w).speed, medWindow, 'omitnan', 'truncate');
            end
            
            fluor = movmedian(calTracks.(strains{s})(w).sqintsub, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(calTracks.(strains{s})(w).sqintsub, medWindow, 'omitnan', 'truncate');
            preFedFluor = fluor(~calTracks.(strains{s})(w).refed);
            medSpan = length(preFedFluor)-floor(length(preFedFluor)/20);
            baseFluor = median([preFedFluor(1:medSpan)]);%not robust, may need adjustment/further consideration
            if isempty(baseFluor) || isnan(baseFluor)
                baseFluor = nanmean(fluor(1:10));
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
            
            plot(t, speed, 'Color', 'b', 'LineStyle', '-');
            hold on;
            title(sprintf('%s worm#%i, NSM Calcium & Speed (median window smoothing = -%0.2f  to +%0.2f seconds)', strains{s}, w, (medWindow(1)/frameRate), (medWindow(2)/frameRate)));
            xlabel(sprintf('Time (%s)', timey));
            ylabel('Speed (um/sec)');
            yyaxis left
            set(gca, 'YColor', 'b')
            set(gca, 'ylim', [0 250])
            
            yyaxis right
            plot(t, normFluor, 'Color', [0 .8 0], 'LineStyle', '-')
            ylabel('Fluoresence intensity (R.U.)');
            set(gca, 'YColor', [0 .8 0])
            set(gca, 'ylim', [-1 4])
            
            set(gca, 'xlim', [min(t) max(t)]);
            
            xs = xlim;
            ys = ylim;
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
            pause;
            clf
            
%             plot(fit(normFluor, speed, 'gauss3'), normFluor, speed, 'predfunc');

        end
    end
    close;
    return
end

%%%%%%%%%%%%%%
function callScriptForPaste
    vs = whos('calTracks_*');
    vs = {vs(:).name};
    for b = 1:length(vs)
    eval(sprintf('cals{%i} = %s', b, vs{b}))
    end
    showPooledCalTracks(cals, true, [5 10])
end