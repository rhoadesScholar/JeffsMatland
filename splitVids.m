function splitVids(vidFolder, numFields, strains)
    colors = {'m' 'c' 'r' 'g' 'b' 'k'};
    
    cd(vidFolder)
    if ~exist('numFields', 'var')
        numFields = inputdlg({'Number of fields:'});
        numFields = str2num(numFields{1});
    end
    if ~exist('strains', 'var')
        for s = 1:numFields
            prompt(s) = {sprintf('Strain #%i', s)};
        end
        strains = inputdlg(prompt);
    end
    
    vid = dir('*.avi');
    v = VideoReader(vid.name);
    vidFrame = readFrame(v);
    
    fields =  struct();
    c = 1;
    figure;
    imshow(vidFrame, []);
    hold on;    
    for s = 1:numFields
%         answer = questdlg(sprintf('Shape of field for strain %s: ', strains{s}), 'Field shape', 'Circle', 'Rectangle', 'Rectangle'); 
%         if strcmp(answer, 'Circle')
%             
%         else
%             
%         end
        [x, y] = getField(strains{s},colors{c});
        fields(s).x = x;
        fields(s).y = y;
        c = c + 1;
    end
    
    for s = 1:numFields
        vidName = makeVidName(vidFolder, strains{s});
        writers(s) = openVidWriter(vidName, v.FrameRate);
    end    
    
    tic
    %%%%%%%%%%%%%%%write full videos
    vidFrame = rgb2gray(vidFrame);
    writeVids(writers, fields, vidFrame);
    while hasFrame(v)
        vidFrame = rgb2gray(readFrame(v));%may throw off Navin's processing scripts, but would speed processing up
        writeVids(writers, fields, vidFrame);
    end
    close(writers);
    toc
end

function [x, y] = getField(strain, color)
    [x, y] = ginput2(2);
    p = patch(x([1 2 2 1]), y([1 1 2 2]), color, 'FaceAlpha', 0.5);
    answer = questdlg(sprintf('Field successfully selected for strain %s?', strain), 'Field selection');
    if strcmp(answer, 'Yes')
        return
    elseif strcmp(answer, 'No')
        p.delete;
        [x, y] = getField(strain, color);
        return
    else
        error('Figure out what you want, then try again.')
    end
end

function vidName = makeVidName(vidFolder, strain)
    name = split(vidFolder, '_');
    i = 97;
    vidName = sprintf('%s_%s_%s_%s%c_%s', name(1), name(2), strain, name(3), i, name(4));
    while isdir(vidName)
        i = i + 1;
        vidName = sprintf('%s_%s_%s_%s%c_%s', name(1), name(2), strain, name(3), i, name(4));
    end
end

function w = openVidWriter(vidName, frameRate)
    mkdir(vidName);
    w = VideoWriter(sprintf('%s//%s.avi', vidName, vidName));
    w.FrameRate = frameRate;
    open(w);
end

function writeVids(writers, fields, vidFrame)
    for s = 1:length(writers)
        subVid = vidFrame(fields(s).y(1):fields(s).y(2),...
            fields(s).x(1):fields(s).x(2));
        writeVideo(writers(s), subVid);
    end
end