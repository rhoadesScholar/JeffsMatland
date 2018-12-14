strains = fields(allTracks);
encounterTimes = struct();

figure; hold on
for s= 1:length(strains)
    encounterTimes.(strains{s}) = arrayfun(@(x) x.Frame(find(x.refed,1))/x.frameRate,allTracks.(strains{s}))/60;
    means(s) = mean(encounterTimes.(strains{s}));
    stderrs(s) = means(s)/sqrt(length(encounterTimes.(strains{s})));
    
    encounterData.(strains{s}).encounterTimes = encounterTimes.(strains{s});
    encounterData.(strains{s}).mean = means(s);
    encounterData.(strains{s}).stderr = stderrs(s);
    
    bar(s, means(s));
    xs = ones(length(encounterTimes.(strains{s})),1);
    xs = xs*s;
    scatter(xs, encounterTimes.(strains{s}), 'k');
%     errorbar(s, stderrs(s));    
end
xticks(1:s)
xlim([0.5 s+0.5])

xticklabels(strains)
xlabel('Strain')
ylabel('Encounter time (minutes)')

