function [avgs, stdErrs, intraWormAvgs] = getIntraWormAvgs(data, bin)%data is refeed/other similarly formatted data
% bin is an array as follow: [beginIndice:endIndice]
    avgFields = {'Speed', 'AngSpeed'};
    avgs = struct();
    stdErrs = struct();
    
    strains = fields(data);
    for s = 1:length(strains)
        for f = 1:length(avgFields)
            intraWormAvgs.(strains{s}).(avgFields{f}) = arrayfun(@(x) nanmean(x.(avgFields{f})(bin)), data.(strains{s}));
            avgs.(strains{s}).(avgFields{f}) = nanmean(intraWormAvgs.(strains{s}).(avgFields{f}));
            stdErrs.(strains{s}).(avgFields{f}) = std(intraWormAvgs.(strains{s}).(avgFields{f}), 'omitnan')./...
                sqrt(sum(~isnan(intraWormAvgs.(strains{s}).(avgFields{f}))));
        end
    end
    
    return
    
end