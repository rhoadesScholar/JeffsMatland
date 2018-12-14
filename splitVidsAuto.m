function splitVidsAuto(dates)%dates is cell array of date folders
    colors = {'m' 'c' 'r' 'g' 'b' 'k'};
    
    for d=1:length(dates)
        mkdir(sprintf('%s_unsplit', dates{d}));
        cd (char(dates(d)))
        folders = dir; %avi should be in own folder named date_refeeding_numFields_genotype1_genotype2_genotype3_vid#_Cam#
        vids = {};
        for i= 3:length(folders)
            vids(i-2) = {folders(i).name};
            cd(vids{i-2});
            vid = dir('*.avi');
            v = VideoReader(vid.name);
            vidFrame = readFrame(v);
            nameParts = strsplit('_', vids{i-2});
            numFields = str2double(nameParts{3});
            for s = 1:numFields
                strains(s) = nameParts(3+s);
            end
            
            fields =  struct();
            c = 1;
            figure;
            imshow(vidFrame, []);
            hold on;    
            for s = 1:numFields
                [x, y] = getField(strains{s},colors{c});
                fields(s).x = x;
                fields(s).y = y;
                c = c + 1;
            end

            for s = 1:numFields
                vidName = makeVidName(nameParts, strains{s});
                writers(s) = openVidWriter(vidName, v.FrameRate);
            end    

            tic
            %%%%%%%%%%%%%%%write full videos
            vidFrame = rgb2gray(vidFrame);
            writeVids(writers, fields, vidFrame);
            while hasFrame(v)
                vidFrame = rgb2gray(readFrame(v));
                writeVids(writers, fields, vidFrame);
            end
            close(writers);
            toc
            cd ..
            clear('v')
            movefile(vids{i-2}, sprintf('..//%s_unsplit//', dates{d}));
        end
        cd ..
    end

    
    
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

function vidName = makeVidName(nameParts, strain)
    i = 97;
    vidName = sprintf('%s_%s_%s_%s%c_%s', nameParts{1}, nameParts{2}, strain, nameParts{end-1}, i, nameParts{end});
    while isdir(sprintf('..//%s', vidName))
        i = i + 1;
        vidName = sprintf('%s_%s_%s_%s%c_%s', nameParts{1}, nameParts{2}, strain, nameParts{end-1}, i, nameParts{end});
    end
end

function w = openVidWriter(vidName, frameRate)
    mkdir(sprintf('..//%s', vidName));
    w = VideoWriter(sprintf('..//%s//%s.avi', vidName, vidName));
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