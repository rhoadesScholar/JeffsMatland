function [result] = getBehavioralAutoCorr(finalTracks, bin, mode)%means, autoCorrData, binnedSpeed, binnedAngSpeed
% *********NEEDS WORK

strains = fields(finalTracks);
% C = vision.Autocorrelator;

AngSpeedFig = figure;
title(sprintf('%s \n %s %i', 'Average Autocorrelation of Angular Speed', 'bin size(sec) = ', (bin/3)));
hold on;
SpeedFig = figure;
title(sprintf('%s \n %s %i', 'Average Autocorrelation of Linear Speed', 'bin size(sec) = ', (bin/3)));
hold on;

if nargin < 3
    maxLinSpeed = getMaxSpeed(finalTracks, bin);
end

for s=1:length(strains) %each strain
    
    binnedSpeed.(strains{s}) = nanbinSpeed(finalTracks.(strains{s}), bin);
    binnedAngSpeed.(strains{s}) = nanbinAngSpeed(finalTracks.(strains{s}), bin);
%     
%     binnedSpeed.(strains{s}) = cell2mat(arrayfun (@(tracks) nanbinSpeed(tracks, bin), finalTracks.(strains{s}), 'UniformOutput', false));
%     binnedAngSpeed.(strains{s}) = cell2mat(arrayfun (@(tracks) nanbinAngSpeed(tracks, bin), finalTracks.(strains{s}), 'UniformOutput', false));
    
    autoCorrSpeed.(strains{s}) = arrayfun (@(x) autocorr([x.Speed]), binnedSpeed.(strains{s}),'UniformOutput', false);
    autoCorrAngSpeed.(strains{s}) = arrayfun (@(x) autocorr([x.AngSpeed]), binnedAngSpeed.(strains{s}),'UniformOutput', false);
    if nargin < 3
        paceChange.(strains{s}) = cell2mat(arrayfun (@(x, y) twoDimDelta([abs(x.AngSpeed)], [y.Speed], 180, maxLinSpeed),...
            binnedAngSpeed.(strains{s}), binnedSpeed.(strains{s}), 'UniformOutput', false));
    else
        paceChange.(strains{s}) = cell2mat(arrayfun (@(x, y) twoDimDelta([abs(x.AngSpeed)], [y.Speed], mode),...
            binnedAngSpeed.(strains{s}), binnedSpeed.(strains{s}), 'UniformOutput', false));
    end
    
    autoCorrSpeeds = autoCorrSpeed.(strains{s});
    autoCorrAngs = autoCorrAngSpeed.(strains{s});
    for l = 1:max(arrayfun(@(x) length(x{1}), autoCorrSpeeds))
        lens = arrayfun(@(x) length(x{1}), autoCorrSpeeds);
        autoCorrSpeeds = autoCorrSpeeds(lens >= l);
        autoCorrAngs = autoCorrAngs(lens >= l);
        
        means.(strains{s}).Speed.avgs(l) = nanmean(arrayfun(@(x) x{1}(l), autoCorrSpeeds));
        means.(strains{s}).Speed.stdErr(l) = std(arrayfun(@(x) x{1}(l), autoCorrSpeeds),'omitnan')/sqrt(length(autoCorrSpeeds));
        means.(strains{s}).Speed.stdev(l) = std(arrayfun(@(x) x{1}(l), autoCorrSpeeds),'omitnan');
        
        means.(strains{s}).AngSpeed.avgs(l) = nanmean(arrayfun(@(x) x{1}(l), autoCorrAngs));
        means.(strains{s}).AngSpeed.stdErr(l) = std(arrayfun(@(x) x{1}(l), autoCorrAngs),'omitnan')/sqrt(length(autoCorrAngs));
        means.(strains{s}).AngSpeed.stdev(l) = std(arrayfun(@(x) x{1}(l), autoCorrAngs),'omitnan');
    end
    
%     for l = 1:max(arrayfun(@(x) length(x.(field)), tracks))
%         lens = arrayfun(@(x) length(x.(field)), tracks);
%         tracks = tracks(lens >= l);
%         avgs.(strains{s}).(field).avgs(l) = nanmean(arrayfun(@(x) x.(field)(l), tracks));
%         avgs.(strains{s}).(field).stdErr(l) = std(arrayfun(@(x) x.(field)(l), tracks),'omitnan')/sqrt(length(tracks));
%         avgs.(strains{s}).(field).stdev(l) = std(arrayfun(@(x) x.(field)(l), tracks),'omitnan');
%     end
    
    means.(strains{s}).paceChange.avg = nanmean([paceChange.(strains{s})]);
    means.(strains{s}).paceChange.stdErr = std([paceChange.(strains{s})],'omitnan')/sqrt(length([paceChange.(strains{s})]));
    
    figure(AngSpeedFig);
    plot(means.(strains{s}).AngSpeed.avgs);
    figure(SpeedFig);
    plot(means.(strains{s}).Speed.avgs);
    
%     autoCorrData.(strains{s}) = arrayfun (@(x,y) step(C, [x.Speed; y.AngSpeed]), binnedSpeed.(strains{s}), binnedAngSpeed.(strains{s}), 'UniformOutput', false);
%     
%     for l = 1:min(arrayfun(@(x) length(x{1}), autoCorrData.(strains{s})))
%         
%         means.(strains{s})(1:3, l) = [nanmean(arrayfun(@(x) x{1}(1,l), autoCorrData.(strains{s}))); ...
%             nanmean(arrayfun(@(x) x{1}(2,l), autoCorrData.(strains{s})));...
%             nanmean(arrayfun(@(x) x{1}(3,l), autoCorrData.(strains{s})))];
%         
%     end
end

legend(strains);
figure(AngSpeedFig);
legend(strains);

figure;
title(sprintf('%s \n %s %i', 'Average 2D Autocorrelation (Angular & Linear Speeds)', 'bin size(sec) = ', (bin/3)));
hold on;
bar(arrayfun(@(strain) means.(char(strain)).paceChange.avg, strains));
set(gca,'XTickLabel',strains);
set(gca,'XTick',[1:length(strains)]);
h = errorbar(arrayfun(@(strain) means.(char(strain)).paceChange.avg, strains),...
    arrayfun(@(strain) means.(char(strain)).paceChange.stdErr, strains));
h.LineStyle = 'none';

result.means = means;
result.autoCorrSpeed = autoCorrSpeed;
result.autoCorrAngSpeed = autoCorrAngSpeed;
result.binnedSpeed = binnedSpeed;
result.binnedAngSpeed = binnedAngSpeed;
result.bin = bin;
return



end