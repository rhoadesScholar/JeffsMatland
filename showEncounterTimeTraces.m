function showEncounterTimeTraces(varargin)
% g = 3;

if length(varargin) == 2
    tracks = varargin{1};    
    strain = varargin{2};
    if ~isfield(tracks, 'Speed')
        tracks = tracks.(strain);
    end
    [refeeds, lags] = getRefeeds(tracks);
elseif length(varargin) >= 3
    refeeds = varargin{1};
    lags = varargin{2};
    strain = varargin{3};
    if ~isfield(refeeds, 'Speed')
        refeeds = refeeds.(strain);
    end
end
    
mid = floor((min(arrayfun(@(x) length(x.Speed), refeeds)))/2);
times = arrayfun(@(x) x.Time(mid)/60, refeeds);%time into video of encounters in minutes

if length(varargin) == 4
    ts = varargin{4};    
else
    ts = [0 15; 16 25; 26 (max(times)+1)];
end   

for n = 1:size(ts, 1)
    grp{n} = sprintf('%s%s%i',strain, 'group', n);
    newTracks.(grp{n}) = refeeds([ceil(times) >= ts(n,1)].*[ceil(times) <= ts(n,2)] == 1);
end
    
% stdev = std(times, 'omitnan');
% avg = nanmean(times);
% index = 1:length(times);
% for n=1:g
%     grp{n} = sprintf('%s%s%i',strain, 'group', n);
%     newTracks.(grp{n}) = refeeds(index([((avg+(stdev*(n-(g/2+1))))*(n~=1) < times).*((n~=g)*times < (avg+(stdev*(n-(g/2)))))]==1));
% end

% 
% newTracks.(grp{1}) = refeeds(index(times < (avg-(stdev/2))));
% newTracks.(grp{2}) = refeeds(index([((avg-(stdev/2)) < times).*(times < (avg+(stdev/2)))]==1));
% newTracks.(grp{3}) = refeeds(index(times > (avg+(stdev/2))));

for s = 1:length(grp)
    try
        tabl = struct2table(newTracks.(grp{s}));
    catch
        tabl = newTracks.(grp{s});
    end
    avgs.(grp{s}).Speed = nanmean([tabl.Speed], 1);
    stdErr.(grp{s}).Speed = std([tabl.Speed], 0 , 1, 'omitnan')./sqrt(sum(~isnan([tabl.Speed])));
%     for l = 1:min(arrayfun(@(x) length(x.Speed), newTracks.(grp{s})))
%         avgs.(grp{s}).Speed(l) = nanmean(arrayfun(@(x) x.Speed(l), newTracks.(grp{s})));
%         stdErr.(grp{s}).Speed(l) = std(arrayfun(@(x) x.Speed(l), newTracks.(grp{s})),'omitnan')/sqrt(length(newTracks.(grp{s})));
%     end
end

showEncounters(newTracks, avgs, stdErr, lags);
fig = gcf;
showTimeToEncounter(newTracks, mid, fig);
end

function [refeeds, lags] = getRefeeds(allTracks)%for single strain
    endLag = max(arrayfun(@(y) single([(length(y.Frames) - y.refeedIndex)]), allTracks));
    frontLag = max(arrayfun(@(y) single([(y.refeedIndex - 1)]), allTracks));
    range = endLag + frontLag + 1;
    lags = {frontLag, endLag};
    
    for t = 1:length(allTracks)
        track = allTracks(t);
        frontBuf = (frontLag) - track.refeedIndex;
        endBuf = range - (frontBuf + length(track.Speed));
        feels = fields(track);
        for i = 1:length(feels)
            [m, n] = size(track.(feels{i}));
            if strcmp(feels{i}, 'Speed')
                event.(feels{i}) = [NaN(m, frontBuf) medfilt1(track.(feels{i}), 5, 'omitnan', 'truncate') NaN(m, endBuf)];%apply sliding window median filter to speeds
            elseif m == length(track.Frames) && ~isstruct(track.(feels{i}))
                event.(feels{i}) = [NaN(frontBuf, n); track.(feels{i}); NaN(endBuf, n)];
            elseif n == length(track.Frames) && ~isstruct(track.(feels{i}))
                event.(feels{i}) = [NaN(m, frontBuf) track.(feels{i}) NaN(m, endBuf)];
            else%data won't be aligned to refeed event
                event.(feels{i}) = track.(feels{i});
            end
        end
        try
            refeeds = [refeeds event];
        catch
            refeeds = event;
        end
    end
end

function showTimeToEncounter(refeeds, mid, fig)
    colors = 'krbmgcy';
    strains = fields(refeeds);
    for s = 1:length(strains)
        means(s) = nanmean([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]);
        minDif(s) = means(s) - min([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]);
        maxDif(s) = max([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]) -  means(s);
        stdev(s) = {sprintf('SD = ±%.2f', std([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))], 'omitnan'))};
    end
    tempFig = figure; hold on;
    c = 1;
    for m = 1:length(means)
        b(m) = bar(m, means(m), 'FaceColor', colors(c));
        c = c + 1; if c > length(colors)    c = 1;     end
    end
    ax = gca;
    set(ax, 'XTick', [1:length(strains)]);
    set(ax, 'XTickLabel', strains);
    title('Time to lawn encounter (minutes)');
    errorbar([1:length(strains)], means, minDif, maxDif, 'LineStyle', 'none');
    text([1:length(strains)], double(means+0.1*max(means)), stdev);
    set(ax, 'Parent', fig);
    set(ax, 'Position', [0.6 0.5 0.2 0.375]);
    close(tempFig)
end
