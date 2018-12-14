function tracks = addNavFields(tracks)
    strains = fields(tracks);
    edges = struct();
    for s = 1:length(strains) %get headingError
        for w = 1:length(tracks.(strains{s}))
            Path = tracks.(strains{s})(w).Path;
            edgeFile = split(tracks.(strains{s})(w).Name, '\');
            edgeFile = edgeFile{end-1};
            if ~isfield(edges, 'Name') || ~ismember(edgeFile, [edges(:).Name])
                try
                    edges(end+(isfield(edges, 'Name'))).Name = {edgeFile};
                    load(sprintf('%s.lawnFile.mat', edgeFile));
                    if ~isempty(dir(sprintf('%s.edge.mat', edgeFile)))
                        load(sprintf('%s.edge.mat', edgeFile));
                    end
                catch
                    try
                        edgeFile2 = split(edgeFile, '_');
                        edgeFile2 = [edgeFile2{1} '_refeeding_' edgeFile2{2} '_' edgeFile2{3} '_' edgeFile2{4}];
                        load(sprintf('%s.lawnFile.mat', edgeFile2));
                        if ~isempty(dir(sprintf('%s.edge.mat', edgeFile2)))
                            load(sprintf('%s.edge.mat', edgeFile2));
                        end
                    catch%add lawn edge if missing
                        try
                            bgFile = dir([edgeFile '*.background.mat']);
                        catch
                            bgFile = dir([edgeFile2 '*.background.mat']);
                        end
                        load(bgFile.name);
                        [edge, lawn] = findBorderManually(bkgnd, []);
                        
                        save([edgeFile '.lawnFile.mat'], 'edge', 'lawn');
                        %error('Cannot find lawnFile. Make sure it is present in the current directory')
                    end
                end
                    edges(end).edge = edge;                        
                    edges(end).lawn = lawn;
            else
                edge = [edges(ismember([edges(:).Name], edgeFile)).edge];
                if isstruct(edge)
                    edge = edge.edge;%yeah, i know this is dumb. i will not be offended if you fix it. good luck.
                end
                lawn = [edges(ismember([edges(:).Name], edgeFile)).lawn];
                if isstruct(lawn)
                    lawn = lawn.lawn;
                end
            end
            [headingError, dist] = arrayfun(@(i) getHeading(edge, [Path(i,1), Path(i,2); Path(i-1,1), Path(i-1,2)]), 2:length(Path), 'UniformOutput', false);
            dist = cell2mat(dist);
            headingError = cell2mat(headingError);
            headingError = real([NaN headingError]);
            headingError = medfilt1(headingError, 3, 'omitnan', 'truncate');
            dist = [ldist([Path(1,1) Path(1,2)], edge) dist];
            dist = medfilt1(dist, 5, 'omitnan', 'truncate');
            tracks.(strains{s})(w).headingError = headingError;
            tracks.(strains{s})(w).edge = edge;
            tracks.(strains{s})(w).lawnDist = dist*tracks.(strains{s})(w).PixelSize;
            tracks.(strains{s})(w).AngSpeed = abs(tracks.(strains{s})(w).AngSpeed);
            tracks.(strains{s})(w).AngSpeed = medfilt1(tracks.(strains{s})(w).AngSpeed, 3, 'omitnan', 'truncate');
            tracks.(strains{s})(w).Speed = medfilt1(tracks.(strains{s})(w).Speed, 3, 'omitnan', 'truncate');
            tracks.(strains{s})(w).refed = getOnLawn(tracks.(strains{s})(w), lawn);
        end
    end

    %now save it
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
    while exist(sprintf('navTracks_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end

    eval(sprintf('tracks_%s = tracks', name))
    eval(sprintf('save(''navTracks_%s_%i.mat'', ''tracks_%s'')', name, num, name));

    return

end

function refed = getOnLawn(track, lawn)
    refed = zeros(size(track.SmoothX));
    for f = 1:length(track.SmoothX)
        if isnan(track.SmoothX(f))
            if f > 1
                refed(f) = refed(f - 1);
            else
                refed(f) = NaN;
            end
        else
            refed(f) = lawn(round(track.SmoothY(f)), round(track.SmoothX(f)));
        end
    end
    return
end

function [headingError, lengthI] = getHeading(xyI, xyA)% returns degree error of (A)ctual heading from (I)deal heading towards closest intersection;
    % xyA= [xi, yi; x(i-1), y(i-1)]

%     if size(xyA, 1) == 1
%         headingError = 0;
%         return
%     end
    if size(xyI, 1) > 1
        [lengthI, xyI] = ldist(xyA(1,:), xyI);
    end
    
    pathI = defineLineMB([xyA(1,:); xyI]);
    pathA = defineLineMB([xyA(1,:); xyA(2,:)]);

    line3 = getPerpLineMB(pathI, xyI);
    xy3 = findIntersectMB(pathA, line3);
    
    %lengthI = getDist([xyA(1,:); xyI]);
    lengthAto3 = getDist([xyA(1,:); xy3]);    
% unecessary %     length3 = getDist(xyI, xy3);
    headingError = rad2deg(acos(lengthI/lengthAto3));
    %FIND DIRECTION OF ACTUAL PATH (towards or away from lawn) and adjust
    %heading error if necessary
    if lengthI > getDist([xyA(2,:); xyI])
        headingError = 180 - headingError;
    end

    headingError = real(headingError);
    return

end

function dist = getDist(xys)
    dist = sqrt((xys(2,1) - xys(1,1))^2 + (xys(2,2) - xys(1,2))^2);
end

function coef = getPerpLineMB(line, xyI)
    m = 1/-line(1);
    b = xyI(2) - m*xyI(1);
    coef = [m b];
end

function xy = findIntersectMB(line1, line2)
    x = (line1(2) - line2(2)) / (line2(1) - line1(1));
    y = [x 1]*line1';
    xy = [x y];
end

function coef = defineLineMB(xys)%coef = [m b]
%line segment defined by y = mx + b
        %m = (y2 - y1)/(x2 – x1)
        %b = y1 - (m*x1)     
        m = (xys(2,2) - xys(1,2))/(xys(2,1) - xys(1,1));
        b = xys(1,2) - m*xys(1,1);
        coef = [m b];
end

function coef = defineLineABC(xys)%coef = [a b c]
%line segment defined by ax + by + c = 0
        %a = (y1 – y2)
        %b = (x2 – x1)
        %c = (x1y2 – x2y1)
        a = xys(1,2) - xys(2,2);
        b = xys(2,1) - xys(1,1);
        c = xys(1,1)*xys(2,2) - xys(2,1)*xys(1,2);
        coef = [a b c];
end

function [headingErrors, lengthsI] = getHeadings(edge, Path)% Not DONE!
    
    [lengthsI, xyIs] = arrayfun(@(i) ldist(Path(i,:), edge), 1:length(Path), 'UniformOutput', false);
    lengthsI = cell2mat(lengthsI);
    xyIs = cell2mat(xyIs);
    
    %%%KJSDKJFN NOT DONE!!!!!!!!!!!!!!!
    pathI = defineLineMB([Path(1,:); xyIs]);
    pathA = defineLineMB([Path(1,:); Path(2,:)]);

    line3 = getPerpLineMB(pathI, xyIs);
    xy3 = findIntersectMB(pathA, line3);
    
    %lengthI = getDist([xyA(1,:); xyI]);
    lengthAto3 = getDist([Path(1,:); xy3]);    
% unecessary %     length3 = getDist(xyI, xy3);
    headingErrors = rad2deg(acos(lengthsI/lengthAto3));
    %FIND DIRECTION OF ACTUAL PATH (towards or away from lawn) and adjust
    %heading error if necessary
    if lengthAto3 > getDist([Path(2,:); xy3])
        headingErrors = 180 - headingErrors;
    end
    
    return

end
