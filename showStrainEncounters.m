function showStrainEncounters(refeeds, avgs)

if nargin < 2
    [refeeds, avgs] = analyzeRefeed(refeeds);
end
strains = fields(refeeds);
for s=1:length(strains)
    fig(s) = figure; hold on;
    ttle = sprintf('%s %s', 'Speeds at Lawn Encounter for strain', strains{s});
    title(ttle);
    for t = 1:length(refeeds.(strains{s}))
        plot(refeeds.(strains{s})(t).Speed, 'LineStyle', ':');
    end
end
for s=1:length(strains)
    figure(fig(s)); hold on;
    plot(avgs.(strains{s}).Speed, 'Color', 'b', 'LineWidth',  2);
end

end