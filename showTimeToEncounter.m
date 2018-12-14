function showTimeToEncounter(refeeds)
strains = fields(refeeds);
mid = length(refeeds.(strains{1})(1).Speed); %set for two minute span on either side of event
for s = 1:length(strains)
    means(s) = mean([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]);
    minDif(s) = means(s) - min([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]);
    maxDif(s) = max([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]) -  means(s);
    stdev(s) = {sprintf('±%g', std([arrayfun(@(x) x.Time(mid)/60, refeeds.(strains{s}))]))};
    
end
figure; hold on;
b = bar(means);
set(gca, 'XTick', [1:length(strains)]);
set(gca, 'XTickLabel', strains);
title('Time to lawn encounter (minutes)');
errorbar([1:length(strains)], means, minDif, maxDif, 'LineStyle', 'none');
text([1:length(strains)], double(means+0.1*means), stdev);

end


