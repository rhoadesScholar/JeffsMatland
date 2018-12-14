function calTracks = getCalTracks(refeed, frameRate) %files should be named: date_mode_genotype_vid#.an#.txt; refeed is boolean
    pixelSize = 3.25; %um/px
%     thresh = 2.5;
    if ~exist('refeed', 'var')
        refeed = true;
    end
    if ~exist('frameRate', 'var')
        frameRate = 10;%10frames/second
    end
    
    data = findData;
    data = cleanData(data);
    %consider smoothing [x, y]
    data = getVelocities(data, frameRate, pixelSize);
%     data = cleanFluors(data, thresh); DONE LATER IN DISPLAY SCRIPT
    
    if refeed
        [data, prompt, refeedInds] = getRefeeds(data);
    end
    if isempty(data)
        return
    end
    calTracks = data;
    
    defFilename = dir('*.txt');
    defFilename = {defFilename.name};
    defFilename = strsplit('_', defFilename{1});
    defFilename = sprintf('%s_%s', defFilename{1}, defFilename{2});
    
    fileName = inputdlg('Input name for data file: ', 'Name file', 1, {defFilename});
    fileName = fileName{1};
    n = 1;        
    if exist([fileName '.mat'], 'file')
        while exist(sprintf('%s_%i.mat', fileName, n), 'file')
            n = n + 1;
        end
        fileName = sprintf('%s_%i.mat', fileName, n);
    end
    
    trackPrefix = strsplit('_', fileName);
    trackPrefix = trackPrefix{1};
    eval(sprintf('calTracks_%s = calTracks;', trackPrefix));
    eval(sprintf('save(''%s'', ''calTracks_%s'')', fileName, trackPrefix));
    if refeed
        file = fopen(sprintf('notes_%i.txt', n), 'w');
        fprintf(file, 'For %s:\r\n', fileName);
        for i = 1:length(prompt)
            fprintf(file, '%s %s\r\n', prompt{i}, refeedInds{i});
        end
        fclose('all');
    end
    
    return
end

function data = findData
    files = dir('*.txt');
    files = {files.name};
    files = files(~contains(files, 'notes'));
    data = struct();
    count = struct();
    
    for f = 1:length(files)
        nameParts = strsplit('_', files{f});
        try
            count.(nameParts{3}) = count.(nameParts{3}) + 1;
        catch
            count.(nameParts{3}) = 1;
        end
        
        data.(nameParts{3})(count.(nameParts{3})).name = files{f};        
        data.(nameParts{3})(count.(nameParts{3})).data = readtable(files{f});
    end
end

function data = cleanData(rawData)
    strains = fields(rawData);
    data = struct();
    
    for s = 1:length(strains)%each strain
        for w = 1:length(rawData.(strains{s}))%each worm
            thisData = rawData.(strains{s})(w).data;
            inds = killOrphans(thisData.Slice);
            thisData(inds', :) = [];
            thisData = killOutcasts(thisData);
            thisData.Frame = thisData.Slice;
            thisData.Slice = [];
            thisData.area = [];
            thisData.x = [];
            thisData.y = [];
            thisData.sqarea = [];
            thisData.useTracking = [];
            newWorm = table2struct(thisData, 'ToScalar', true);
            newWorm.name = rawData.(strains{s})(w).name;
            try
                data.(strains{s}) = [data.(strains{s}) newWorm];
            catch
                data.(strains{s}) = newWorm;
            end
        end
    end
    
    return
end

function inds = killOrphans(slices)%dark, right? (written a couple weeks into Trump's presidency)
    sliceDif = slices(2:end)- slices([1:end-1]);
    sliceDif = [1; sliceDif];
    
    jumpPoints = find(sliceDif~=1);
    inds = jumpPoints((jumpPoints(2:end)-jumpPoints(1:end-1))==1);%find orphan jumps
    
    if sum(jumpPoints == length(slices)) %is last slice orphan
        inds = [inds; jumpPoints(end)];
    end
    return
end

function newData = killOutcasts(data)%see kill orphans for ~comic narration
    slices = data.Slice;
    sliceDif = slices(2:end)- slices([1:end-1]);
    sliceDif = [1; sliceDif];    
    jumpPoint = find(sliceDif~=1,1);%find(sliceDif<1,1);
    if isempty(jumpPoint)
        newData = data;
    else
        if sliceDif(jumpPoint) < 1 
            startInd = find(slices == slices(jumpPoint)-1,1);
            if isempty(startInd)
                startInd = 0;
            end
            inds = [startInd+1:jumpPoint-1]';
            data(inds', :) = [];
        else
            newSlices = num2cell((slices(jumpPoint - 1) + 1) : (slices(jumpPoint) - 1));
            try
                newRows(1:length(newSlices), :) = data(1:length(newSlices), :);
            catch
                for i = 1:length(newSlices)
                    newRows(i, :) = data(1, :);
                end
            end
            newRows(:, 'Slice') = newSlices';
            newRows(:, 2:13) = {NaN};
            
            data = [data(1:(jumpPoint - 1),:); newRows; data(jumpPoint:end, :)];
        end
        newData = killOutcasts(data);
    end
    
    return
end

function data = getVelocities(data, frameRate, pixelSize)
    strains = fields(data);
    
    for s = 1:length(strains)%each strain
        for w = 1:length(data.(strains{s}))%each worm
            x = data.(strains{s})(w).xc;
            x = medfilt1(x, 3, 'omitnan', 'truncate');%
            dx = diff(x);
            dx = [NaN; dx];
            y = data.(strains{s})(w).yc;
            y = medfilt1(y, 3, 'omitnan', 'truncate');%
            dy = diff(y);
            dy = [NaN; dy];
            
            dist = sqrt(dx.^2 + dy.^2);
            dist = dist*pixelSize;
            data.(strains{s})(w).speed = dist*frameRate;
            data.(strains{s})(w).frameRate = frameRate;
            data.(strains{s})(w).pixelSize = pixelSize;
        end
    end
    
    return
end

function data = cleanFluors(data, thresh)
    strains = fields(data);
    for s = 1:length(strains)
        for w = 1:length(data.(strains{s}))
            totMedian = nanmedian(data.(strains{s})(w).bgmedian);
            include = [data.(strains{s})(w).bgmedian <= thresh*totMedian];
            data.(strains{s})(w).sqintsub(~include) = NaN;
        end
    end
end

function [data, prompt, refeedsInds] = getRefeeds(data)
    strains = fields(data);
    
    i = 1;
    for s = 1:length(strains)%each strain
        for w = 1:length(data.(strains{s}))%each worm
            prompt(i) = {sprintf('Encounter Frame(s) for %s: ', data.(strains{s})(w).name)};
            i = i + 1;
        end
    end
    
    i = 1;
    for s = 1:length(strains)%each strain
        for w = 1:length(data.(strains{s}))%each worm
            refeedsInds(i) = inputdlg(prompt(i));
            if isempty(refeedsInds(i))
                data = {}
                return
            end
            thisRefeed = str2num(refeedsInds{i});%get lawn crossings
            if isempty(thisRefeed)%leave empty for off lawn
                data.(strains{s})(w).refed = zeros(length(data.(strains{s})(w).Frame), 1);
            else
                thisRefeed = [thisRefeed data.(strains{s})(w).Frame(end)];
                data.(strains{s})(w).refed = zeros(length(data.(strains{s})(w).Frame), 1);
                for e = 1:(length(thisRefeed) - 1)
                    dife = abs(data.(strains{s})(w).Frame - thisRefeed(e));%in case exact encounter frame wasn't tracked
                    difeN = abs(data.(strains{s})(w).Frame - thisRefeed(e+1));
                    startInd = find(dife == min(dife), 1);
                    endInd = find(difeN == min(difeN), 1);
                    data.(strains{s})(w).refed(startInd : endInd) = mod(e,2);%label as on or off lawn
                end
            end
            i = i + 1;
        end
    end
    
    return
end