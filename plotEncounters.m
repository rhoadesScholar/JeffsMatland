function [refeeds, avgs] = plotEncounters(tracks, varargin)

if length(varargin)>=1
    refeeds = tracks;
    avgs = varargin{1};
    stdErr = varargin{2};
    lags = varargin{3};
    if length(varargin)>=4
        strains = varargin{4};
    else
        strains = fields(avgs);
    end
else
    [refeeds, avgs, stdErr, lags] = analyzeRefeed(tracks);
    strains = fields(refeeds);
end

colors = 'krbmgcy';
figure; hold on;
title('Speeds at Lawn Encounter');
x = [];
n = 1;
while isempty(x)
    try
        x = (-lags{1}:lags{2})/(refeeds.(strains{n})(1).FrameRate*60);
    catch
        n = n + 1;
    end
end
frameRate = refeeds.(strains{n})(1).FrameRate;

c = 1;
wormCounts = cell(length(strains),1);
for s = n:length(strains)
    y = [avgs.(strains{s}).Speed];
    start = find(~isnan(y), 1);
    fin = find(~isnan(y), 1, 'last');
    xThis = x(start:fin);
    y = y(start:fin);
    err = stdErr.(strains{s}).Speed(start:fin);
    try
        tabl = struct2table(refeeds.(strains{s}));
    catch
        tabl = refeeds.(strains{s});
    end
    nums = sum(~isnan([tabl.Speed(1:end, start:fin)]));
    nums = nums';
    if ~isempty(find(isnan(y),1))
        if (length(find(isnan(y))) > 300)
            fprintf('There are %i NaN values in dataset for strain %s \n', length(find(isnan(y))), strains{s});
        end
        y = fillmissing(y, 'pchip');
        err = fillmissing(err, 'pchip');
%         nans = find(isnan(y));
%         for n = 1:length(nans)
%             y(nans(n)) = y(nans(n)-1);
%             err(nans(n)) = err(nans(n)-1);
%         end
    end
    fill([xThis, xThis(end:-1:1)],[[y + err],[y(end:-1:1) - err(end:-1:1)]],[0.9 0.9 0.95], 'LineWidth', 0.1, 'EdgeColor', [0.85 0.85 0.9]);
    plot(xThis,y, colors(c), 'DisplayName', sprintf('%s (n = %i)', strains{s}, length(refeeds.(strains{s}))),...
        'LineWidth', 1.5)
    c = c + 1;      if c > length(colors)    c = 1;     end
    wormCounts{s} = sprintf('%s (n = %i)', strains{s}, length(refeeds.(strains{s})));
end
legend('show');
xlabel('time (min)');
ylabel('speed (um/s)');
xlim([-8 8]);
ylim([0 0.2]);
%showTimeToEncounter(refeeds);
% showSpeedBars(avgs, stdErr, lags, frameRate, wormCounts, strains);
end

function showSpeedBars(avgs, stdErr, lags, frameRate, wormCounts, strains)
    barTimes = [-6, -4;
                -2, -1;
                -0.5, 0;
                0, 0.2;
                0.2, 1;
                6, 10];%nx2 matrix of bin times in minutes
    
    relativeFrames = barTimes.*(60*frameRate);%get frames for bin
    barFrames = relativeFrames + lags{1};
    
    for t = 1:size(barTimes, 1)
        
        means(t,:) = arrayfun(@(s) nanmean(avgs.(strains{s}).Speed(barFrames(t,1):barFrames(t,2))), 1:length(strains)).*1000;
        stdErry(t,:) = arrayfun(@(s) nanmean(stdErr.(strains{s}).Speed(barFrames(t,1):barFrames(t,2))), 1:length(strains)).*1000;
        stdText(t,:) = arrayfun(@(s) sprintf('±%.2f', stdErry(t, s)), 1:length(strains), 'UniformOutput', false);
        
%         figure; hold on;
%         b = bar(means(t,:));
%         set(gca, 'XTick', [1:length(strains)]);
%         set(gca, 'XTickLabel', strains);
%         title(sprintf('Speed at %0.1g to %0.1g min from lawn encounter (um/s)', barTimes(t,1),barTimes(t,2)));
%         errorbar([1:length(strains)], means(t,:), stdErry(t,:), stdErry(t,:), 'LineStyle', 'none');
%         text([1:length(strains)], double(means(t,:)+0.1*means(t,:)), stdText(t,:));
    end
        figure; hold on;
        b = bar(means);
        set(gca, 'XTick', [1:size(barTimes,1)]);
        set(gca, 'XTickLabel', arrayfun(@(t) sprintf('%0.1f to %0.1f min', barTimes(t,1),barTimes(t,2)), 1:size(barTimes,1), 'UniformOutput', false));
        title('Speeds (um/s)');
        %errorbar([1:length(strains)*size(barTimes,1)], means, stdErry, stdErry, 'LineStyle', 'none');
        
%         errorbar(means, stdErry, 'LineStyle', 'none');
%         text([1:length(strains)*size(barTimes,1)], double(means+0.1*means), stdText);
%         
        %set(ax,'fontsize', 18);
        % Aligning errorbar to individual bar within groups
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        grpMeas = size(stdText, 2);
        grpWidth = min(0.8, grpMeas/(grpMeas+1.5));
        offset = (grpWidth*(grpMeas-1))/(2*grpMeas);
        mid = ceil(grpMeas/2);
        
        for i = 1:size(stdText,1)
            for g = 1:grpMeas
%                 grpMeas - 1
%                 g - mid
%                 c = (g - mid + mod(g+1,2))/(g+mod(g+1,2));
                x(g) = i - grpWidth/2 + (2*g-1)*grpWidth/(2*grpMeas);%+ c*offset;
            end
%                 x(1) = i - grpWidth/2 + grpWidth/(2*grpMeas); %x(1) = i - groupwidth/2 + (2*i-1)*groupwidth/(2*grpMeas);
            
            errorbar(x,means(i,:),-(stdErry(i,:)), stdErry(i,:), 'k', 'linestyle', 'none');

            labelies = double(means(i,:)+ stdErry(i,:)+3)';
            text(x, labelies(:), stdText(i,:),'HorizontalAlignment', 'center', 'FontSize', 7);
        end
        
        legend(wormCounts)
end