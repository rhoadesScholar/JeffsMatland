function [avgs] = showApproachAvgs(tracks, varargin)
avgFields = {'headingError', 'AngSpeed', 'Time'}; %Time?
fieldX = 'lawnDist';
fieldY = 'Speed';
xFactor = 1;
yFactor = 1000;

if length(varargin) == 1
    pooled = varargin{1};
else
    pooled = false;
end
    
strains = fields(tracks);

if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist')
    tracks = addNavFields(tracks);
end

maxY = ceil(max(structfun(@(x) max(arrayfun(@(y) max([y.(fieldX)]*xFactor), x)), tracks)));
maxX = ceil(max(structfun(@(x) max(arrayfun(@(y) max([y.(fieldY)]*yFactor), x)), tracks)));

for f = 1:length(avgFields)
blanks.(avgFields{f}) = zeros(maxX, maxY);
end

for s = 1:length(strains)%each strain
    totalNums.(strains{s}).num = zeros(maxX, maxY);
    avgs.(strains{s}) = blanks;
    
    for w = 1:length(tracks.(strains{s}))%each worm
        for d = 1:tracks.(strains{s})(w).refeedIndex%each frame
            test = 0;
            for f = 1:length(avgFields)
                test = test + tracks.(strains{s})(w).(avgFields{f})(d);
            end 
            test = test + tracks.(strains{s})(w).(fieldX)(d) + tracks.(strains{s})(w).(fieldY)(d) + tracks.(strains{s})(w).(avgFields{1})(d);
            if ~isnan(test)
                yBin = ceil(tracks.(strains{s})(w).(fieldX)(d)*xFactor);
                xBin = ceil(tracks.(strains{s})(w).(fieldY)(d)*yFactor);
                if (yBin == 0) yBin = 1; end
                if (xBin == 0) xBin = 1; end
                totalNums.(strains{s}).num(xBin, yBin) = totalNums.(strains{s}).num(xBin, yBin) + 1;
                for f = 1:length(avgFields)
                    avgs.(strains{s}).(avgFields{f})(xBin, yBin) = avgs.(strains{s}).(avgFields{f})(xBin, yBin) + tracks.(strains{s})(w).(avgFields{f})(d);
                end    
            end
        end
    end
    %average each strain
    for f = 1:length(avgFields)
        avgs.(strains{s}).(avgFields{f}) = avgs.(strains{s}).(avgFields{f}) ./ totalNums.(strains{s}).num;
        avgs.(strains{s}).(avgFields{f})(isinf(avgs.(strains{s}).(avgFields{f}))) = NaN;
    end
end

if pooled
    name = 'pooled';
    num = 1;
    while exist(sprintf('approaches_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end
    name = sprintf('approaches_%s', name);
else
    [name, num] = getName(tracks, strains);
end

saveIt(name, num, avgs, totalNums);

for s = 1:length(strains)
    figure; hold on;
    title(sprintf('%s, n = %i', strains{s}, length(tracks.(strains{s}))));
    xlabel(fieldX);
    ylabel(fieldY);
    zlabel(avgFields{1});
    surface(avgs.(strains{s}).(avgFields{1}), 100*(totalNums.(strains{s}).num ./ sum(sum([totalNums.(strains{s}).num]))), 'EdgeAlpha', 0.5);
    colormap jet
    colorbar
    %%%%%%
%     [X, Y, Z] = prepareSurfaceData([tracks.(strains{s}).(fieldX)], [tracks.(strains{s}).(fieldY)], [tracks.(strains{s}).(avgFields{1})]);
%     f = fit([X, Y], Z, 'poly55');%, 'Normalize', 'on');
%     figure; hold on;
%     title(sprintf('%s, n = %i', strains{s}, length(tracks.(strains{s}))));
%     xlabel(fieldX);
%     ylabel(fieldY);
%     zlabel(avgFields{1});
%     plot(f, 'Style', 'PredFunc')
%     colormap jet
%     colorbar
end
return

end

function saveIt(name, num, avgs, totalNums)
%now save it
    
    eval(sprintf('%s.avgs = avgs', name));
    eval(sprintf('%s.totalNums = totalNums', name));
    
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