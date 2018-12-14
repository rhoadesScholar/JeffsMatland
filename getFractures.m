function [ratios, fracRates] = getFractures (allFinalTracks, hmmBin, fracBin, stateTypes) %ratios.strain(trackNum).roaming/dwelling

if (nargin < 3)
    fracBin = hmmBin;
end
if (nargin < 4)
    stateTypes = {'dwelling' 'roaming'};
end

[~, states.N2, hmmTR, hmmE] = getHMMStates(allFinalTracks.N2,hmmBin);

strains = fields(allFinalTracks);

plotData = zeros(length(strains)*length(stateTypes),2);
plotLabels = {length(strains)*length(stateTypes)};

for s=1:length(strains)%each strain
    
    [~, states.(strains{s}), ~, ~] = getHMMStatesSpecifyTRandE_2(allFinalTracks.(strains{s}),hmmBin,hmmTR,hmmE);
    intervals.(strains{s}) = getStateAuto(allFinalTracks.(strains{s}), fracBin);
    
    totalNumFracs(1:length(stateTypes)) = 0;
    totalNumIntervals(1:length(stateTypes)) = 0;
    for t=1:length(states.(strains{s}))%each track
        n = 0;
        for i=1:hmmBin:(length(states.(strains{s})(t).states)-1)%each interval
            if ~isnan(states.(strains{s})(t).states(i))
                n = n + 1;
                try
                    numFracs = ratios.(strains{s})(t).(stateTypes{states.(strains{s})(t).states(i)}).numFracs;
                    numIntervals = ratios.(strains{s})(t).(stateTypes{states.(strains{s})(t).states(i)}).numIntervals;
                catch ME
    %                 switch ME.identifier
    %                     case 'MATLAB:undefinedVarOrClass'
                            numFracs = 0;
                            numIntervals = 0;
    %                     otherwise
    %                         rethrow(ME);
    %                 end
                end
                ratios.(strains{s})(t).(stateTypes{states.(strains{s})(t).states(i)}).numFracs = numFracs + ~(states.(strains{s})(t).states(i) == intervals.(strains{s})(t).state(n));
                ratios.(strains{s})(t).(stateTypes{states.(strains{s})(t).states(i)}).numIntervals = numIntervals + 1;
            end
        end
        for b=1:length(stateTypes)
            try
                ratios.(strains{s})(t).(stateTypes{b}).ratio = (ratios.(strains{s})(t).(stateTypes{b}).numFracs) / (ratios.(strains{s})(t).(stateTypes{b}).numIntervals);
                totalNumFracs(b) = totalNumFracs(b) + ratios.(strains{s})(t).(stateTypes{b}).numFracs;
                totalNumIntervals(b) = totalNumIntervals(b) + ratios.(strains{s})(t).(stateTypes{b}).numIntervals;
            catch
                ratios.(strains{s})(t).(stateTypes{b}).ratio = NaN;
                ratios.(strains{s})(t).(stateTypes{b}).numFracs = 0;
                ratios.(strains{s})(t).(stateTypes{b}).numIntervals = 0;
            end
        end

    end
    %make plot
    for b=1:length(stateTypes)
        fracRates.(strains{s}).(stateTypes{b}) = totalNumFracs(b) / totalNumIntervals(b);
        plotData(((s-1)*length(stateTypes))+b,1:2) = [(1-fracRates.(strains{s}).(stateTypes{b})) fracRates.(strains{s}).(stateTypes{b})];
        plotLabels{((s-1)*length(stateTypes))+b} = strcat(strains{s}, stateTypes{b});
        
        errbar(((s-1)*length(stateTypes))+b,1) = std(arrayfun(@(a) [a.(stateTypes{b}).ratio], ratios.(strains{s})), 'omitnan')/sqrt(length(arrayfun(@(a) [a.(stateTypes{b}).ratio], ratios.(strains{s}))));
    end
end
figure;
hold on;
bar(plotData,'stack');
legend('normal','out of state intervals');
ylabel('fraction of time');
set(gca,'XTickLabel',plotLabels);
set(gca,'XTick',[1:length(plotLabels)]);
h = errorbar(plotData(:,1),errbar);
h.LineStyle = 'none';
end