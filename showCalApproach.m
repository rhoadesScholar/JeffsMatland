function [tracks, navMat, avgsFinal, stdErr] = showCalApproach(tracks, binSize, scaleFactor)
%track = calTracks structure
%binsize in same measure as lawnDist field of tracks
%p = percentiles for error bars
%cutoff indicates data length necessary for a worm to be included in plot

    cmap = getCmap;
    avgFields = {'fluor', 'speed', 'headingError'}; 
    fieldX = 'lawnDist';
    if ~exist('binSize', 'var'), binSize = 50; end
    if ~exist('scaleFactor', 'var'), scaleFactor = 1000; end
    binAdjust = binSize/scaleFactor;
    
    strains = fields(tracks);

    if ~isfield(tracks.(strains{1}), 'headingError')
        tracks = getCalNavs(tracks);
    end

    maxX = ceil(max(structfun(@(x) max(arrayfun(@(y) max([y.(fieldX)]/binAdjust), x)), tracks)));

    for f = 1:length(avgFields)
        blanks.(avgFields{f}) = num2cell(zeros(maxX, 1));
    end
    
    navMat = struct();
    for s = 1:length(strains)%each strain
        totalNums.(strains{s}).num = zeros(maxX, 1);
        medians.(strains{s}) = blanks;
        navMat.(strains{s}).num = zeros(length(tracks.(strains{s})), maxX);
        for f = 1:length(avgFields)
            navMat.(strains{s}).(avgFields{f}) = NaN(length(tracks.(strains{s})), maxX);
        end
        for w = 1:length(tracks.(strains{s}))%each worm
            
            for d = 1:find(tracks.(strains{s})(w).refed,1)%each frame
                test = 0;
                for f = 1:length(avgFields)
                    test = test + tracks.(strains{s})(w).(avgFields{f})(d);
                end 
                test = test + tracks.(strains{s})(w).(fieldX)(d);
                if ~isnan(test)
                    xBin = ceil(tracks.(strains{s})(w).(fieldX)(d)*binAdjust);
                    if (xBin == 0), xBin = 1; end
                    totalNums.(strains{s}).num(xBin) = totalNums.(strains{s}).num(xBin) + 1;
                    navMat.(strains{s}).num(w, xBin) = navMat.(strains{s}).num(w, xBin) + 1;
                    for f = 1:length(avgFields)
                        medians.(strains{s}).(avgFields{f})(xBin, totalNums.(strains{s}).num(xBin)) = {tracks.(strains{s})(w).(avgFields{f})(d)};
                        navMat.(strains{s}).(avgFields{f})(w, xBin) = ...
                            nansum([navMat.(strains{s}).(avgFields{f})(w, xBin), tracks.(strains{s})(w).(avgFields{f})(d)]);
                    end
                end
            end
        end
       for f = 1:length(avgFields)
            navMat.(strains{s}).(avgFields{f}) = navMat.(strains{s}).(avgFields{f})./navMat.(strains{s}).num;
       end
        imagesc(navMat.(strains{s}).(avgFields{1})(:,length(navMat.(strains{s}).(avgFields{1})):-1:1), [-2 2])
        title('NSM Calcium vs. Distance from Lawn')
        xlabel('Distance from Lawn (in microns)')
        ylabel('R.U. Fluorescence')
        ax = gca;
        colormap(ax, cmap);
        c = colorbar;
        c.Label.String = 'Fluorescence';
        xticklabels
        xticklabels(ans(end:-1:1));
    end

    for s = 1:length(strains)
        for f = 1:length(avgFields)
            for l = 1:maxX
                stdErr.(strains{s}).(avgFields{f})(l) = std([medians.(strains{s}).(avgFields{f}){l,:}],'omitnan')/sqrt(totalNums.(strains{s}).num(l));
                avgsFinal.(strains{s}).(avgFields{f})(l) = nanmean([medians.(strains{s}).(avgFields{f}){l,:}]);
            end
        end
    end
    
    colors = 'krbmgcy';
    figure; hold on;
    title(sprintf('%s vs. %s', avgFields{1}, fieldX));
    x = [1:maxX];
    c = 1;
    for s = 1:length(strains)
        y = [avgsFinal.(strains{s}).(avgFields{1})];
        start = find(~isnan(y), 1);
        fin = find(~isnan(y), 1, 'last');
        xThis = x(start:fin);
        y = y(start:fin);
        err = stdErr.(strains{s}).(avgFields{1})(start:fin);
        if ~isempty(find(isnan(y),1))
            if (length(find(isnan(y))) > 300)
                h = msgbox(sprintf('There are %i NaN values in dataset for strain %s', length(find(isnan(y))), strains{s}));
            end
            nans = find(isnan(y));
            for n = 1:length(nans)
                y(nans(n)) = y(nans(n)-1);
                err(nans(n)) = err(nans(n)-1);
            end
        end
%         errorshade(xThis,[y + err],[y - err],colors(c));
%         patch([xThis NaN],[y NaN], colors(c),'EdgeColor',colors(c), 'DisplayName', sprintf('%s (n = %i)', strains{s}, length(tracks.(strains{s}))), 'LineWidth', 1.5)
%         
        errorshade(xThis,[y + err],[y - err],colors(c), totalNums.(strains{s}).num/(max(totalNums.(strains{s}).num)*3));
        patch([xThis NaN],[y NaN], colors(c),'EdgeColor',colors(c), 'DisplayName', sprintf('%s (n = %i)', strains{s}, length(tracks.(strains{s}))),...
        'LineWidth', 1.5, 'FaceVertexAlphaData', [totalNums.(strains{s}).num; NaN], 'EdgeAlpha', 'flat', 'AlphaDataMapping', 'scaled')
    
        c = c + 1;
        if c > length(colors)    c = 1;     end
    end
    legend('show');
    xlabel(sprintf('%s binned by %i', fieldX, binAdjust));
    ylabel(avgFields{1});
    xlim('auto');
    ylim('auto');
    
    return
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
