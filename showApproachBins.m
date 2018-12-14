function [avgs, bins] = showApproachBins(tracks)
avgFields = {'Speed', 'AngSpeed', 'headingError'}; %Time?

strains = fields(tracks);

if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist')
    tracks = addNavFields(tracks);
end

maxLawnDist = floor(max(structfun(@(x) max(arrayfun(@(y) max([y.lawnDist]), x)), tracks)));

blankNums.num = zeros(1, maxLawnDist);
for f = 1:length(avgFields)
    blanks.(avgFields{f}) = zeros(1, maxLawnDist);
end

for s = 1:length(strains)%each strain
    nums.(strains{s})(1:length(tracks.(strains{s}))) = blankNums;
    totalNums.(strains{s}).num = zeros(1, maxLawnDist);
    bins.(strains{s})(1:length(tracks.(strains{s}))) = blanks;
    avgs.(strains{s}) = blanks;
    
    for w = 1:length(tracks.(strains{s}))%each worm
        for d = 1:tracks.(strains{s})(w).refeedIndex%each frame
            test = 0;
            for f = 1:length(avgFields)
                test = test + tracks.(strains{s})(w).(avgFields{f})(d);
            end 
            test = test + tracks.(strains{s})(w).lawnDist(d);
            if ~isnan(test)
                distBin = floor(tracks.(strains{s})(w).lawnDist(d));
                %speeds.(strains{s})(w).distSpeed(distBin) = speeds.(strains{s})(w).distSpeed(distBin) + tracks.(strains{s})(w).Speed(d);
                nums.(strains{s})(w).num(distBin) = nums.(strains{s})(w).num(distBin) + 1;
                totalNums.(strains{s}).num(distBin) = totalNums.(strains{s}).num(distBin) + 1;
                for f = 1:length(avgFields)
                    bins.(strains{s})(w).(avgFields{f})(distBin) = bins.(strains{s})(w).(avgFields{f})(distBin) + tracks.(strains{s})(w).(avgFields{f})(d);
                    avgs.(strains{s}).(avgFields{f})(distBin) = avgs.(strains{s}).(avgFields{f})(distBin) + tracks.(strains{s})(w).(avgFields{f})(d);
%                     stdErr.(strains{s}).(avgFields{f})(distBin) = 
                end    
            end
        end
        %average each worm
        for f = 1:length(avgFields)
            bins.(strains{s})(w).(avgFields{f}) = bins.(strains{s})(w).(avgFields{f}) ./ nums.(strains{s})(w).num;
        end   
    end
    %average each strain
    for f = 1:length(avgFields)
        avgs.(strains{s}).(avgFields{f}) = avgs.(strains{s}).(avgFields{f}) ./ totalNums.(strains{s}).num;
    end
end

[name, num] = getName(tracks, strains);
saveIt(name, num, avgs, bins, nums, totalNums);
return
%now plot!

colors = 'krbgmcy';
figure; hold on;
title('Speeds by distance from lawn');
c = 1;
x = [-maxLawnDist:maxLawnDist NaN];
for s=1:length(strains)
    for w = 1:length(tracks.(strains{s}))
        y = [tracks.(strains{s})(w).distSpeed NaN];
        p = patch(x,y, colors(c),'EdgeColor',colors(c),'EdgeAlpha',0.07);
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    c = c + 1;      if c > length(colors)    c = 1;     end
end
c = 1;
for s=1:length(strains)
    y = [avgs.(strains{s}).distSpeed NaN];
    patch(x,y, colors(c),'EdgeColor',colors(c), 'DisplayName', strains{s}, 'LineWidth', 1.5)
    c = c + 1;      if c > length(colors)    c = 1;     end
end
legend('show');

end

function saveIt(name, num, avgs, bins, nums, totalNums)
%now save it
    
    eval(sprintf('%s.avgs = avgs', name));
    eval(sprintf('%s.bins = bins', name));
    eval(sprintf('%s.nums = nums', name));
    eval(sprintf('%s.totalNums = totalNums', name));
    
    eval(sprintf('save(''%s_%i.mat'', ''%s'')', name, num, name));
end

function [name, num] = getName(tracks, strains)

     num = 1;
    if length(unique({tracks.(strains{1}).Name})) == 1
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(end);
        name = split(name, '_');
        name = unique(name(1));
    else
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(:, :, end);
        name = split(name, '_');
        name = unique(name(:,:,1));
    end
    while exist(sprintf('approaches_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end
    name = sprintf('approaches_%s', name);
    
end