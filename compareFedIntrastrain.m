function feds = compareFedIntrastrain(refeeds, lags, strains, ts)
%can pass lags = [] with cell of all track structs to pool
%can also pass strains as {} to have auto populated
if ~exist('ts', 'var')
    ts = [0 30];
end

if iscell(refeeds)
     normalTracks = normalizeSpeedsByN2(allTracks, combine);
     [refeeds, ~, ~, lags] = analyzeRefeed(normalTracks);
end

if isempty(strains)
    strains = fields(refeeds);
end

for s = 1:length(strains)
    if ~strcmpi(strains{s}, 'Fed') && sum(contains(strains, [strains{s} 'fed'], 'IgnoreCase', true))
        for t = 1:length(refeeds.(strains{s}))
            refeeds.(strains{s})(t).Time = refeeds.(strains{s})(t).Time + 90*60;
        end
        fedStrain = strains{contains(strains, [strains{s} 'fed'], 'IgnoreCase', true)};
        refeeds.(fedStrain) = [refeeds.(fedStrain) refeeds.(strains{s})];
        inc(s) = false;
    else
        inc(s) = true;
    end    
end

strains = strains(inc);
newStrains = {};

for s = 1:length(strains)
%     mid = floor((min(arrayfun(@(x) length(x.Speed), refeeds.(strains{s}))))/2);
    times = arrayfun(@(x) x.Time(lags{1})/60, refeeds.(strains{s}));%time into video of encounters in minutes        
    g = 1;
    for n = 1:size(ts,1)
        group = sprintf('%s_%ito%imin', strains{s}, ts(n,1), ts(n,2));
        newTracks.(group) = refeeds.(strains{s})([ceil(times) >= ts(n,1)].*[ceil(times) <= ts(n,2)] == 1);
        try
            tabl = struct2table(newTracks.(group));
        catch
            tabl = newTracks.(group);
        end
        avgs.(group).Speed = nanmean([tabl.Speed], 1);
        stdErr.(group).Speed = std([tabl.Speed], 0 , 1, 'omitnan')./sqrt(sum(~isnan([tabl.Speed])));
        if ~isempty(avgs.(group).Speed)
            newStrains(g) = {group};
            g = g + 1;
        end
    end    
    
    showEncounters(newTracks, avgs, stdErr, lags, newStrains);
    feds.(strains{s}).avgs = avgs;
    feds.(strains{s}).stdErr = stdErr;
    feds.(strains{s}).refeeds = newTracks;
    feds.(strains{s}).lags = lags;
    clear('newTracks', 'avgs', 'stdErr');    
end

end