function avgs = getSeriesAvgs(allTracks, field)%%could be improved to better align series

avgs = struct();
strains = fields(allTracks);

for s = 1:length(strains)
    tracks = allTracks.(strains{s});
    for l = 1:max(arrayfun(@(x) length(x.(field)), tracks))
        lens = arrayfun(@(x) length(x.(field)), tracks);
        tracks = tracks(lens >= l);
        avgs.(strains{s}).(field).avgs(l) = nanmean(arrayfun(@(x) x.(field)(l), tracks));
        avgs.(strains{s}).(field).stdErr(l) = std(arrayfun(@(x) x.(field)(l), tracks),'omitnan')/sqrt(length(tracks));
        avgs.(strains{s}).(field).stdev(l) = std(arrayfun(@(x) x.(field)(l), tracks),'omitnan');
    end
end


end