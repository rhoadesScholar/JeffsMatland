function showOptos(optos, buffer, stimsInc, errShade, exclude, medWindow)%buffer in seconds, stimsInc = stim#(s), errShade = boolean, 
% exclude = threshold pre-stim speed for exclusion

    colors = 'krbmgcy';    
    strains = fields(optos);

    for s = 1:length(strains)
        c = 1;
        figure; hold on;
        title(['Speeds with NSM stimulation in ' strains{s}]);
        stims = unique(optos.(strains{s})(:,2));
        if ~isempty(stimsInc)
            stims = stimsInc(ismember(stimsInc, stims));
        end
        for st = stims
            inds = [optos.(strains{s})(:,2) == st];
            speeds = optos.(strains{s})(inds,5:end)*1000;
            
            indsInc = nanmean([speeds(:,1:buffer*3-1)],2) >= exclude;
            speeds = speeds(indsInc, :);
            
            y = movmedian(nanmean(speeds,1), medWindow, 'omitnan', 'Endpoints', 'shrink');
            err = std(speeds, 0 , 1, 'omitnan')./sqrt(sum(~isnan(speeds)));
            t = [-buffer*3:length(y)-buffer*3 - 1]/3;
            t = t/60;
            
            if errShade
                errorshade(t,[y + err],[y - err],colors(c));
            end
            plot(t,y, 'Color',colors(c));
            c = c + 1;      if c > length(colors),    c = 1;     end
        end    
        xlabel('time (min)');
        ylabel('speed (um/s)');
        ylim([0 300]);
        plot([0 0], [0 500], 'LineWidth', 1);
%         grid on
    end

end