function [navMat, medians, prcts] = showCalApproachMedians(tracks, varargin)%binSize, p, cutOff, scaleFactor)
%track = calTracks structure
%binsize in same measure as lawnDist field of tracks
%p = percentiles for error bars
%cutoff indicates data length necessary for a worm to be included in plot
%--> cutOff = [length for cutoff, percent allowable NaN]
    
    par = inputParser;
    addParameter(par, 'binSize', 25);
    addParameter(par, 'scaleFactor', 1000);
    addParameter(par, 'p', [90 10]);
    addParameter(par, 'cutOff', [1.5 .2]);
    addParameter(par, 'plotFade', 1);
    addParameter(par, 'plotInclude', 0);
    parse(par, varargin{:})
    
    vars = fields(par.Results);
    for v = 1:length(vars)
        eval([vars{v} ' = [' num2str(par.Results.(vars{v})) ']']);
    end
    
%     if ~exist('binSize', 'var'), binSize = 25; end
%     if ~exist('scaleFactor', 'var'), scaleFactor = 1000; end
%     if ~exist('p', 'var'), p = [90 10]; end
%     if ~exist('cutOff', 'var'), cutOff = [1.5 .2]; end
    xAdjust = binSize/scaleFactor;
    
    cmap = getCmap;
    avgFields = {'fluor', 'speed', 'headingError'}; 
    fieldX = 'lawnDist';
    fieldXLabel = 'Distance from Lawn (mm)';
    fieldYLabel = 'Calcum Fluorescence (R.U.)';
    ylimit = [-2 2];
    
    strains = fields(tracks);

    if ~isfield(tracks.(strains{1}), 'headingError')
        tracks = getCalNavs(tracks);
    end

    maxX = ceil(max(structfun(@(x) nanmax(arrayfun(@(y) nanmax([y.(fieldX)(1:find(y.refed == 1,1))]/xAdjust), x)), tracks)));
    
    navMat = struct();
    fig = figure; hold on;
    title(sprintf('%s vs. %s', fieldYLabel, fieldXLabel));
    for s = 1:length(strains)%each strain
        nums.(strains{s}) = zeros(1, maxX);
        binIndices = arrayfun(@(x) ...
            discretize(tracks.(strains{s})(x).(fieldX)(1:find(tracks.(strains{s})(x).refed == 1,1))/xAdjust,...
            [1:maxX],'IncludedEdge','right'), 1:length(tracks.(strains{s})), 'UniformOutput', false);
            %index which frame's data goes in which bin
        
        for f = 1:length(avgFields)
            binData = arrayfun(@(x) arrayfun(@(y) ...
            tracks.(strains{s})(x).(avgFields{f})((binIndices{x} == y)), maxX:-1:1, 'UniformOutput', false)...
            , 1:length(tracks.(strains{s})), 'UniformOutput', false);%sort each worm's data into right bins
                %and reverse order so first bin is data furthest from lawn
            binAvgs = NaN(length(binData), maxX);
            for x = 1:length(binData), binAvgs(x,:) = cellfun(@(y) nanmean(y), binData{x}); end
            %average all of each worms data per bin and put in matrix form
            
            navMat.(strains{s}).(avgFields{f}) = binAvgs;
            medians.(strains{s}).(avgFields{f}) = nanmedian(binAvgs);
            prcts.(strains{s}).(avgFields{f}) = prctile(binAvgs, p);
        end
        
        figure
        heatMe = navMat.(strains{s}).(avgFields{1});
        cutBin = discretize(cutOff(1)/xAdjust, 1:maxX);
        cutSite = maxX - cutBin;
        nanCount = sum(isnan(heatMe(:,cutSite:end)),2);
        include = [nanCount <= cutOff(2)*cutBin];
        heatMe = heatMe(include,:);
        
        imagesc(-cutBin, 1, heatMe(:, cutSite:end), ylimit)
        title(sprintf('%s vs. %s', fieldYLabel, fieldXLabel));
        xlabel(fieldXLabel)
        ylabel('Worm#')
        ax = gca;
        colormap(ax, cmap);
        cb = colorbar;
        cb.Label.String = fieldYLabel;
        xlim([-cutBin 0])
        xs = xticks*xAdjust;
        xticklabels(num2str(xs'));
        
        figure(fig)
        if plotFade && plotInclude
            for n = 1:length(binIndices)
                nums.(strains{s}) = nansum([nums.(strains{s}); arrayfun(@(y) nansum([binIndices{n}==y]), 1:maxX)]);
            end
            nums.(strains{s}) = fliplr(nums.(strains{s}));
            plotNums = [nums.(strains{s})]';
            plotNums = plotNums/(max(plotNums)*3);
        elseif plotFade && ~plotInclude
            for n = 1:length(include)
                if include(n)
                    nums.(strains{s}) = nansum([nums.(strains{s}); arrayfun(@(y) nansum([binIndices{n}==y]), 1:maxX)]);
                end
            end
            nums.(strains{s}) = fliplr(nums.(strains{s}));
            plotNums = [nums.(strains{s})]';
            plotNums = plotNums/(max(plotNums)*3);
        else
            plotNums = ones(size([nums.(strains{s})]'));
            plotNums = plotNums*.25;
        end
        if plotInclude
            fig = addPlot([medians.(strains{s}).(avgFields{1})], [-maxX-1:0]*xAdjust, prcts.(strains{s}).(avgFields{1}),...
            plotNums, sprintf('%s (n = %i)', strains{s}, length(tracks.(strains{s}))), fig);
        else
            fig = addPlot(nanmedian(heatMe), [-maxX-1:0]*xAdjust, prctile(heatMe, p),...
            plotNums, sprintf('%s (n = %i)', strains{s}, size(heatMe, 1)), fig);
        end
    end
    
    legend('show');
    xlabel(fieldXLabel);
    ylabel(fieldYLabel);
    xlim('auto');
    ylim(ylimit);
%     xs = abs(xticks)*xAdjust;
%     xticklabels(num2str(xs'));
%     
    return
end

function fig = addPlot(y, x, err, nums, name, fig)
    colors = 'krbmgcy';
    if isempty(fig.UserData), c = 1; 
    else, c = fig.UserData; end
    
    start = find(~isnan(y), 1);
    fin = find(~isnan(y), 1, 'last');
    xThis = x(start:fin);
    y = y(start:fin);
    err = err(:,start:fin);
    nums = nums(start:fin);
    if ~isempty(find(isnan(y),1))
%         if (length(find(isnan(y))) > 300)
%             h = msgbox(sprintf('There are %i NaN values in dataset for strain %s', length(find(isnan(y))), strains{s}));
%         end
        nans = find(isnan(y));
        for n = 1:length(nans)
            y(nans(n)) = y(nans(n)-1);
            err(:,nans(n)) = err(:,nans(n)-1);
            nums(nans(n)) = nums(nans(n)-1);
        end
    end
    
    errorshade(xThis, err(1,:), err(2,:), colors(c), nums);
    
    if all(nums == mean(nums))
        plot(xThis,y, colors(c), 'DisplayName', name);
    else
        patch([xThis NaN],[y NaN], colors(c),'EdgeColor',colors(c), 'DisplayName', name,...
        'LineWidth', 1.5, 'FaceVertexAlphaData', [nums; NaN], 'EdgeAlpha', 'flat', 'AlphaDataMapping', 'scaled')
    end
    
    c = c + 1;
    if c > length(colors), c = 1; end
    fig.UserData = c;
    
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
