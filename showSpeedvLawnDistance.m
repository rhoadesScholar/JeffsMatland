function [avgs, tracks] = showSpeedvLawnDistance(tracks)

strains = fields(tracks);
edges = struct();
if ~isfield(tracks.(strains{1}), 'lawnDist') %get lawnDist
    for s = 1:length(strains)
        for w = 1:length(tracks.(strains{s}))
            edgeFile = split(tracks.(strains{s})(w).Name, '\');
            edgeFile = edgeFile{end-1};
            Path = tracks.(strains{s})(w).Path;
            if ~isfield(edges, 'Name') || ~ismember(edgeFile, [edges(:).Name])
                try
                    edges(end+(isfield(edges, 'Name'))).Name = {edgeFile};
                    edges(end).edge = load(sprintf('%s.lawnFile.mat', edgeFile), 'edge');
                catch
                    try
                        edgeFile2 = split(edgeFile, '_');
                        edgeFile2 = [edgeFile2{1} '_refeeding_' edgeFile2{2} '_' edgeFile2{3} '_' edgeFile2{4}];
                        edges(end).edge = load(sprintf('%s.lawnFile.mat', edgeFile2), 'edge');
                    catch
                        error('Cannot find lawnFile. Make sure it is present in the current directory')
                    end
                end
            end
            edge = [edges(ismember([edges(:).Name], edgeFile)).edge];
            edge = edge.edge;
            dist = arrayfun(@(x, y) ldist([x y], edge), Path(:,1), Path(:,2)); %should make gpuArray compatable ldist for this
            tracks.(strains{s})(w).lawnDist = dist*tracks.(strains{s})(w).PixelSize;      % mm/pixel
        end
    end
end

maxLawnDist = round(max(structfun(@(x) max(arrayfun(@(y) max([y.lawnDist]), x)), tracks)));
range = 2*maxLawnDist + 1;
cero = maxLawnDist + 1;
blankSpeeds.distSpeed = zeros(1, range);
blankNums.num = zeros(1, range);

for s = 1:length(strains)
    speeds.(strains{s})(1:length(tracks.(strains{s}))) = blankSpeeds;
    nums.(strains{s})(1:length(tracks.(strains{s}))) = blankNums;
    avgs.(strains{s}) = blankSpeeds;
    totalNums.(strains{s}) = blankNums;
    
    for w = 1:length(tracks.(strains{s}))
        for d = 1:length(tracks.(strains{s})(w).lawnDist)
            if ~isnan(tracks.(strains{s})(w).lawnDist(d)) && ~isnan(tracks.(strains{s})(w).Speed(d))
                distBin = round(tracks.(strains{s})(w).lawnDist(d));
                distBin = cero + distBin*(1-2*(d <= tracks.(strains{s})(w).refeedIndex));
                speeds.(strains{s})(w).distSpeed(distBin) = speeds.(strains{s})(w).distSpeed(distBin) + tracks.(strains{s})(w).Speed(d);
                nums.(strains{s})(w).num(distBin) = nums.(strains{s})(w).num(distBin) + 1;
                avgs.(strains{s}).distSpeed(distBin) = avgs.(strains{s}).distSpeed(distBin) + tracks.(strains{s})(w).Speed(d);
                totalNums.(strains{s}).num(distBin) = totalNums.(strains{s}).num(distBin) + 1;
            end
        end
        %average each worm
        tracks.(strains{s})(w).distSpeed = speeds.(strains{s})(w).distSpeed ./ nums.(strains{s})(w).num;
    end
    %average each strain
    avgs.(strains{s}).distSpeed = avgs.(strains{s}).distSpeed ./ totalNums.(strains{s}).num;
end

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