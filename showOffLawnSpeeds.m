function showOffLawnSpeeds(tracks, dist, fedDelay)%dist = 2D array of distance bins ([near1, far1; ...])
    strains = fields(tracks);
    avgs = NaN(length(strains), size(dist,1));
    stderrs = NaN(length(strains), size(dist,1));
    stderrString = cell(length(strains), size(dist,1));
    
    for s = 1:length(strains)
        for l = 1:size(dist,1)
            i = 0;
            for w = 1:length(tracks.(strains{s}))
                if ~contains(strains{s}, 'fed', 'IgnoreCase', true) || (contains(strains{s}, 'fed', 'IgnoreCase', true)...
                        && ~isnan(tracks.(strains{s})(w).refeedIndex) && (tracks.(strains{s})(w).Time(tracks.(strains{s})(w).refeedIndex)/60 <= fedDelay))
                    wormDist = (tracks.(strains{s})(w).lawnDist).*(~tracks.(strains{s})(w).refed);%NOTE: Cannot make distance bin with 0mm from lawn
                    inds = (wormDist > dist(l,1)).*(wormDist <= dist(l,2)) > 0;
                    if sum(inds) >= 3
                        i = i + 1;
                        speed = tracks.(strains{s})(w).Speed(inds)*1000;%convert into um
                        speeds.(strains{s})(i) = nanmean(speed);
                    end
                end
            end
            try
                avgs(s, l) = nanmean(speeds.(strains{s})(:));
                stderrs(s, l) = std(speeds.(strains{s})(:), 'omitnan')/sqrt(length(speeds.(strains{s})(:)));
                stderrString(s, l) = {sprintf('%.0f±%.2f\n(n=%i)', avgs(s, l), stderrs(s, l), length(speeds.(strains{s})(:)))};
            catch
                fprintf('%s has no qualifying tracks at distance %imm\n', strains{s}, dist(l));
            end
            clear speeds
        end
    end
    
    figure;
    bar(avgs);
    hold on;
    ax = gca;
    set(ax, 'XTick', [1:length(strains)]);
    set(ax, 'XTickLabel', strains);
    ylabel('Speed (um/s)');
    ylim([0 300])
    title(sprintf('Average speeds off lawn (fed worms off lawn <%i minutes)', fedDelay));
    
    %set(ax,'fontsize', 18);
    % Aligning errorbar to individual bar within groups
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    groupwidth = min(0.8, length(stderrString)/(length(stderrString)+1.5));
    for i = 1:length(stderrString)
        x = (1:length(strains)) - groupwidth/2 + (2*i-1)*groupwidth/(2*length(stderrString));
        errorbar(x,avgs(:,i),-(stderrs(:,i)), stderrs(:,i), 'k', 'linestyle', 'none');

        labelies = double(avgs(:,i)+0.07*max(avgs(:,i)))';
        text(x, labelies(:), stderrString(:,i),'HorizontalAlignment', 'center', 'FontSize', 7);
    end
    
    legend(compose('%imm to %imm', dist(1:end, 1), dist(1:end, 2)))
end