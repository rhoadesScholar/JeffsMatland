function [refeeds, avgs, stdErr, lags] = analyzeRefeed(allTracks)
fedDelay = 30;
avgFields = {'Speed', 'AngSpeed'};
strains = fields(allTracks);
refeeds = struct();

endLag = max(structfun(@(x) max(arrayfun(@(y) single([(length(y.Frames) - y.refeedIndex)]), x)), allTracks));
frontLag = max(structfun(@(x) max(arrayfun(@(y) single([(y.refeedIndex)]), x)), allTracks));
lags = {frontLag, endLag};
range = endLag + frontLag + 1;

for s = 1:length(strains)    
    for t = 1:length(allTracks.(strains{s}))
        track = allTracks.(strains{s})(t);
        if ~isnan(track.refeedIndex) && (~contains(strains{s}, 'fed', 'IgnoreCase', true) || (contains(strains{s}, 'fed', 'IgnoreCase', true) && (track.Time(track.refeedIndex)/60 <= fedDelay)))
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
                    event.(feels{i}) = [NaN(m, frontBuf) medfilt1(real(track.(feels{i})), 3, 'omitnan', 'truncate') NaN(m, endBuf)];%apply sliding window median filter
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
end

%%%%now analyze
for s = 1:length(strains)
    tabl = struct2table(refeeds.(strains{s}));        
    for f = 1:length(avgFields)
        avgs.(strains{s}).(avgFields{f}) = nanmean([tabl.(avgFields{f})], 1);
        stdErr.(strains{s}).(avgFields{f}) = std([tabl.(avgFields{f})], 0 , 1, 'omitnan')./sqrt(sum(~isnan([tabl.(avgFields{f})])));
%         for l = 1:range
%             avgs.(strains{s}).(avgFields{f})(l) = nanmean(arrayfun(@(x) x.(avgFields{f})(l), refeeds.(strains{s})));
%             stdErr.(strains{s}).(avgFields{f})(l) = std(arrayfun(@(x) x.(avgFields{f})(l), refeeds.(strains{s})),'omitnan')/sqrt(length(refeeds.(strains{s})));
%         end
    end
end

%now save it
    choice = questdlg('Save these results?');
    if strcmp(choice, 'Yes')
        fileName = inputdlg('Filename: ');
        fileName = fileName{1};
        num = 1;
        while exist(sprintf('refeeds_%s_%i.mat', fileName, num), 'file')
            num = num + 1;
        end
        eval(sprintf('save(''refeeds_%s_%i.mat'', ''refeeds'', ''avgs'', ''stdErr'', ''lags'', ''-v7.3'')', fileName, num));
    end
    return
end

