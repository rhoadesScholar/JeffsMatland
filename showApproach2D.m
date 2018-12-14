function [avgsFinal, stdErr] = showApproach2D(tracks, varargin)

    avgFields = {'headingError', 'Speed', 'AngSpeed', 'Time'}; %Time?
    fieldX = 'lawnDist';
    xFactor = 1;

    if length(varargin) == 1
        pooled = varargin{1};
    else
        pooled = false;
    end

    strains = fields(tracks);

    if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist')
        tracks = addNavFields(tracks);
    end

    maxX = ceil(max(structfun(@(x) max(arrayfun(@(y) max([y.(fieldX)]*xFactor), x)), tracks)));

    for f = 1:length(avgFields)
        blanks.(avgFields{f}) = num2cell(zeros(maxX, 1));
    end

    for s = 1:length(strains)%each strain
        totalNums.(strains{s}).num = zeros(maxX, 1);
        avgs.(strains{s}) = blanks;

        for w = 1:length(tracks.(strains{s}))%each worm
            for d = 1:tracks.(strains{s})(w).refeedIndex%each frame
                test = 0;
                for f = 1:length(avgFields)
                    test = test + tracks.(strains{s})(w).(avgFields{f})(d);
                end 
                test = test + tracks.(strains{s})(w).(fieldX)(d);
                if ~isnan(test)
                    xBin = ceil(tracks.(strains{s})(w).(fieldX)(d)*xFactor);
                    if (xBin == 0) xBin = 1; end
                    totalNums.(strains{s}).num(xBin) = totalNums.(strains{s}).num(xBin) + 1;
                    for f = 1:length(avgFields)
                        avgs.(strains{s}).(avgFields{f})(xBin, totalNums.(strains{s}).num(xBin)) = {tracks.(strains{s})(w).(avgFields{f})(d)};
                    end    
                end
            end
        end
    end

    for s = 1:length(strains)
        for f = 1:length(avgFields)
            for l = 1:maxX
                stdErr.(strains{s}).(avgFields{f})(l) = std([avgs.(strains{s}).(avgFields{f}){l,:}],'omitnan')/sqrt(totalNums.(strains{s}).num(l));
                avgsFinal.(strains{s}).(avgFields{f})(l) = nanmean([avgs.(strains{s}).(avgFields{f}){l,:}]);
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
        errorshade(xThis,[y + err],[y - err],colors(c));
        patch([xThis NaN],[y NaN], colors(c),'EdgeColor',colors(c), 'DisplayName', sprintf('%s (n = %i)', strains{s}, length(tracks.(strains{s}))), 'LineWidth', 1.5)
        c = c + 1;
        if c > length(colors)    c = 1;     end
    end
    legend('show');
    xlabel(fieldX);
    ylabel(avgFields{1});
    xlim('auto');
    ylim('auto');
    
%     
%     if pooled
%         name = 'pooled';
%         num = 1;
%         while exist(sprintf('approaches2D_%s_%i.mat', name, num), 'file')
%             num = num + 1;
%         end
%         name = sprintf('approaches2D_%s', name);
%     else
%         [name, num] = getName(tracks, strains);
%     end
% 
%     saveIt(name, num, avgsFinal, stdErr);
    return
end

function saveIt(name, num, avgs, stdErr)
%now save it
    
    eval(sprintf('%s.avgs = avgs', name));
    eval(sprintf('%s.stdErr = stdErr', name));
    
    eval(sprintf('save(''%s_%i.mat'', ''%s'')', name, num, name));
end

function [name, num] = getName(tracks, strains)
    num = 1;
    if length(unique({tracks.(strains{1}).Name})) == 1
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(end);
        name = split(name, '_');
        name = unique(name(1));
    else
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(:, :, end);
        name = split(name, '_');
        name = unique(name(:,:,1));
    end
    while exist(sprintf('approaches_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end
    name = sprintf('approaches_%s', name);
    
end
