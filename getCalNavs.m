function tracks = getCalNavs(tracks)
    medSpan = 30;%30;----> first draft Rhoades et al 2018
    medBuf = 3;%3;----> first draft Rhoades et al 2018
    thresh = 1.52;%1.35 < 1.52 < 1.75
    medWindow = [5 10];
    
    strains = fields(tracks);
    edges = struct();
    for s = 1:length(strains) %get headingError
        for w = 1:length(tracks.(strains{s}))
            edgeFile = split(tracks.(strains{s})(w).name, '.');
            edgeFile = edgeFile{1};
            if ~isfield(edges, 'name') || ~ismember(edgeFile, [edges(:).name])
                try
                    edges(end+(isfield(edges, 'name'))).name = {edgeFile};
                    edgeName = dir(sprintf('*/%s.lawnFile.mat', edgeFile));
                    load([edgeName.folder '/' edgeName.name]);
                catch
                    bgFile = dir(['*/' edgeFile '*.tif']);
                    bkgnd = imread([bgFile.folder '/' bgFile.name]);
                    [edge, lawn] = findBorderManually(bkgnd, []);

                    save([bgFile.folder '/' edgeFile '.lawnFile.mat'], 'edge', 'lawn');
                    %error('Cannot find lawnFile. Make sure it is present in the current directory')
                end
                    edges(end).edge = edge;                        
                    edges(end).lawn = lawn;
            else
                edge = [edges(ismember([edges(:).name], edgeFile)).edge];
                if isstruct(edge)
                    edge = edge.edge;%yeah, i know this is dumb. i will not be offended if you fix it. good luck.
                end
                lawn = [edges(ismember([edges(:).name], edgeFile)).lawn];
                if isstruct(lawn)
                    lawn = lawn.lawn;%see above
                end
            end
            Path = [tracks.(strains{s})(w).xc, tracks.(strains{s})(w).yc];
            [headingError, dist] = arrayfun(@(i) getHeading(edge, [Path(i,1), Path(i,2); Path(i-1,1), Path(i-1,2)]), 2:length(Path), 'UniformOutput', false);
            dist = cell2mat(dist);
            headingError = cell2mat(headingError);
            headingError = real([NaN headingError]);
            headingError = medfilt1(headingError, 5, 'omitnan', 'truncate');
            dist = [ldist([Path(1,1) Path(1,2)], edge) dist];
            dist = medfilt1(dist, 5, 'omitnan', 'truncate');
            tracks.(strains{s})(w).headingError = headingError;
            tracks.(strains{s})(w).edge = edge;
            tracks.(strains{s})(w).lawnDist = dist*tracks.(strains{s})(w).pixelSize/1000;
            
            %get clean speed
            speed = tracks.(strains{s})(w).speed;
            speed(speed > 500) = NaN;
    %         speed = filloutliers(speed, 'pchip','movmedian',3);%------->THINKER
    %         speed = fillmissing(speed,'movmedian',3);%------->THINKER
            tracks.(strains{s})(w).speed = movmedian(speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');        
            
            %get clean calcium fluorescence
            fluor = tracks.(strains{s})(w).sqintsub;        
            %########################################################################EXPERIMENTAL to normalize to non-negative!!!!!!!
            fluor = fluor + abs(min(fluor))*(min(fluor)<0);%METHOD A
    %         fluor(fluor < 0) = NaN;%METHOD C$$$$$$BEST------> first draft Rhoades et al 2018
    %         fluor = (fluor - min(fluor))/(max(fluor) - min(fluor));%METHOD B
    %       #####################################
    %         fluor = filloutliers(fluor, 'pchip','quartiles');%------->THINKER         
    %         fluor = filloutliers(fluor, 'pchip','movmedian',3);%------->THINKER
    %         fluor = fillmissing(fluor,'movmedian',3);%------->THINKER
            fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');%smooth

            preFedFluor = fluor(~tracks.(strains{s})(w).refed);
            if length(preFedFluor) > (medSpan + medBuf)
                medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
            else
                medInds = 1:length(preFedFluor);
            end
    %         ####################$#$#$#$#$#$#$#$#$#$#
    %         baseFluor = nanmedian(preFedFluor(medInds));
            baseFluor = nanmean(preFedFluor(medInds));%----> first draft Rhoades et al 2018

            if isempty(baseFluor) || isnan(baseFluor)
    %             baseFluor = nanmedian(preFedFluor);
                baseFluor = nanmean(preFedFluor);%----> first draft Rhoades et al 2018
            end
            if isempty(tracks.(strains{s})(w).refed)
                baseFluor = quantile(fluor, 0.25);%----------->SET BASELINE NORMALIZATION FOR STEADY STATE
            end
            tracks.(strains{s})(w).fluor = (fluor/baseFluor) - 1;
        end
    end

    return

end

function [edge, lawn] = findBorderManually (bkgnd, edge)

    figure;
    imshow(imadjust(bkgnd));
    hold on;

    if nargin<2 || isempty(edge)
        edge = ginput2();
    else
        plot(edge(:,1), edge(:,2));
    end
    if isempty(edge)
        edge = [NaN NaN];
        lawn = NaN(size(bkgnd));
        return
    end
    dim = ~(abs(edge(1,2) - edge(end,2)) > abs(edge(1,1) - edge(end,1))) + 1;
    other = (dim==1) + 1;

    questdlg('Pick side of lawn.', 'Side of lawn', 'OK', 'OK');
        answer(1) = 'N';
        while answer(1) == 'N'
            food = ginput2(1);
            mapshow(food(1),food(2),'DisplayType','point','Marker','X');
            answer = questdlg('Are you sure there is food there?', 'Confirm', 'Yes', 'No', 'Yes');
        end

    side = all(food(dim) < edge(:,dim));
    lawn = zeros(size(bkgnd));
    % lawn(:) = ~side;
    for s = 1:(length(edge)-1)
        %ax +by + c = 0
        a = edge(s,2) - edge(s+1,2);
        b = edge(s+1,1) - edge(s,1);
        c = edge(s,1)*edge(s+1,2) - edge(s+1,1)*edge(s,2);
        iV = 1:size(lawn,other);
        for f = floor(edge(s,other)):ceil(edge(s+1,other))
            if f<=0
                f = 1;
            elseif f > size(lawn,dim)
                f = size(lawn,dim);
            end
            if dim == 1
                vec = ((a*iV + b*f + c)<=0);
                lawn(f,:) = vec~=side;%may cause errors
            else
               vec = ((a*f + b*iV + c)<=0);
               lawn(:,f) = vec==side;
            end
        end
    end
    close
end

function [headingError, lengthI] = getHeading(xyI, xyA)% returns degree error of (A)ctual heading from (I)deal heading towards closest intersection;
    % xyA= [x(i), y(i); x(i-1), y(i-1)]

%     if size(xyA, 1) == 1
%         headingError = 0;
%         return
%     end
    if size(xyI, 1) > 1
        [lengthI, xyI] = ldist(xyA(1,:), xyI);
    else
        headingError = NaN;
        lengthI = NaN;
        return
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

    headingError = double(real(headingError));
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