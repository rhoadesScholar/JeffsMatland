function compareFed(refeeds, lags, strains, ts)
if ~exist('ts', 'var')
    ts = [0 30];
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

for n = 1:size(ts,1)
    for s = 1:length(strains)
        mid = floor((min(arrayfun(@(x) length(x.Speed), refeeds.(strains{s}))))/2);
        times = arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}));%time into video of encounters in minutes        
        newTracks.(strains{s}) = refeeds.(strains{s})([ceil(times) >= ts(n,1)].*[ceil(times) <= ts(n,2)] == 1);
        try
            tabl = struct2table(newTracks.(strains{s}));
        catch
            tabl = newTracks.(strains{s});
        end
        avgs.(strains{s}).Speed = nanmean([tabl.Speed], 1);
        stdErr.(strains{s}).Speed = std([tabl.Speed], 0 , 1, 'omitnan')./sqrt(sum(~isnan([tabl.Speed])));
    end
    
    showEncounters(newTracks, avgs, stdErr, lags);
    clear('newTracks', 'avgs', 'stdErr');
end

end