function [refeeds, avgs, stdErr, lags] = analyzeRefeed_v2(allTracks)
avgFields = {'Speed' 'AngSpeed' 'headingError'};
strains = fields(allTracks);
refeeds = struct();

endLag = max(structfun(@(x) max(arrayfun(@(y) single([(length(y.Frames) - y.refeedIndex)]), x)), allTracks));
frontLag = max(structfun(@(x) max(arrayfun(@(y) single([(y.refeedIndex - 1)]), x)), allTracks));
lags = {frontLag, endLag};
range = endLag + frontLag + 1;

for s = 1:length(strains)    
    for t = 1:length(allTracks.(strains{s}))
        track = allTracks.(strains{s})(t);
        frontBuf = (frontLag) - track.refeedIndex;
        endBuf = range - (frontBuf + length(track.Speed));
        feels = fields(track);
        for i = 1:length(feels)
            [m, n] = size(track.(feels{i}));
            if strcmp(feels{i}, 'Speed')
                event.(feels{i}) = [NaN(m, frontBuf) medfilt1(track.(feels{i}), 3, 'omitnan', 'truncate') NaN(m, endBuf)];%apply sliding window median filter to speeds
            elseif strcmp(feels{i}, 'AngSpeed')
                event.(feels{i}) = [NaN(m, frontBuf) medfilt1(abs(track.(feels{i})), 3, 'omitnan', 'truncate') NaN(m, endBuf)];%apply sliding window median filter
            elseif strcmp(feels{i}, 'headingError')
                event.(feels{i}) = [NaN(m, frontBuf) medfilt1(track.(feels{i}), 3, 'omitnan', 'truncate') NaN(m, endBuf)];%apply sliding window median filter
            elseif m == length(track.Frames) && ~isstruct(track.(feels{i}))
                event.(feels{i}) = [NaN(frontBuf, n); track.(feels{i}); NaN(endBuf, n)];
            elseif n == length(track.Frames) && ~isstruct(track.(feels{i}))
                event.(feels{i}) = [NaN(m, frontBuf) track.(feels{i}) NaN(m, endBuf)];
            else%data won't be aligned to refeed event
                event.(feels{i}) = track.(feels{i});
            end
        end
        try
            refeeds.(strains{s}) = [refeeds.(strains{s}) event];
        catch
            refeeds.(strains{s}) = event;
        end
    end
end

%%%%now analyze
for s = 1:length(strains)
    for f = 1:length(avgFields)
        for l = 1:range
            avgs.(strains{s}).(avgFields{f})(l) = nanmean(arrayfun(@(x) x.(avgFields{f})(l), refeeds.(strains{s})));
            stdErr.(strains{s}).(avgFields{f})(l) = std(arrayfun(@(x) x.(avgFields{f})(l), refeeds.(strains{s})),'omitnan')/sqrt(length(refeeds.(strains{s})));
        end
    end
end

%now save it
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
    while exist(sprintf('refeeds_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end

    eval(sprintf('refeeds_%s.refeeds = refeeds', name))
    eval(sprintf('refeeds_%s.avgs = avgs', name))
    eval(sprintf('refeeds_%s.stdErr = stdErr', name))
    eval(sprintf('refeeds_%s.lags = lags', name))
    
    eval(sprintf('save(''refeeds_%s_%i.mat'', ''refeeds_%s'')', name, num, name));
    
    return
end

