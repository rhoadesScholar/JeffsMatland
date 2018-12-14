function index = checkEncounter(i, track, trackNum, intsct)
searchPath = 'D:\Jeff';
buffer = 100;

name = split(track.Name, '\');
name = char(name(end));
picPrefix = split(name, '.');
picPrefix = picPrefix{1};

try
    index = load(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum), 'index');
    xy = track.Path(index.index,:);
    if pdist([intsct; xy(1),xy(2)]) > buffer
        rm(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum));
        rm(sprintf('encounters\\%s\\%i.N.mat', picPrefix, trackNum));
        load('notAThing', 'alsoNotAThing');
    else
        index = index.index;
        return
    end
catch
    vidFile = getVidFile(name, track, searchPath);
    xydif = [300, 300];%may need to be adjusted for other image resolutions

        bx1 = [track.SmoothX - xydif(:,1)'];
        bx1(bx1 < 1)= 1;
        bx2 = [track.SmoothX + xydif(:,1)'];
        bx2(bx2 > track.Width)=track.Width;
        by1 = [track.SmoothY - xydif(:,2)'];
        by1(by1 < 1) = 1;
        by2 = [track.SmoothY + xydif(:,2)'];
        by2(by2 > track.Height)=track.Height;
        
        loadDone = false;
        while ~loadDone
            try
                v = VideoReader(vidFile, 'CurrentTime', double(track.Frames(i)/track.FrameRate - 3));
                loadDone = true;
            catch
                answer = questdlg('Abort load?', 'Could not load vid', 'No', 'Yes', 'No');
                if strcmp(answer, 'Yes')
                    loadDone = true;
                else
                    answer = inputdlg('Change search:', 'Search path', 1, {searchPath});
                    searchPath = answer{1};
                    vidFile = getVidFile(name, track, searchPath);
                end
            end
        end
        index = i - (1 + track.FrameRate*3);
        if index < 1
            index = 1;
        end
        xs = round(track.SmoothX(1:index));
        xs = xs(~isnan(xs));
        ys = round(track.SmoothY(1:index));
        ys = ys(~isnan(ys));

    fig = figure;
    while hasFrame(v) && ~strcmp(fig.CurrentCharacter, ' ')%press spacebar to indicate event
        vidFrame = readFrame(v);
        %mapshow(track.Path(index + 1,1),track.Path(index + 1,2),'DisplayType','point','Marker','o');%need to make this show on figure....
        %plot(track.Path(1:index,1), track.Path(1:index,2))
        if ~isnan(track.SmoothX(index))
            xs = [xs round(track.SmoothX(index))];
            ys = [ys round(track.SmoothY(index))];
        end
        for cor = 1:length(xs) vidFrame(round(ys(cor)), round(xs(cor)), :) = [0 0 255]; end
        vidFrame = vidFrame(by1(i):by2(i), bx1(i):bx2(i), 3);
        imshow(vidFrame, 'InitialMagnification', 100, 'DisplayRange', []);
        index = index + 1;
        pause();
        if strcmp(fig.CurrentCharacter, 'b')%b for backwards
            index = index - track.FrameRate;
            v = VideoReader(vidFile, 'CurrentTime', double(track.Frames(index)/track.FrameRate));
        elseif strcmp(fig.CurrentCharacter, 'f')%f for fast forward
            index = index + 3*track.FrameRate;
            if index > length(track.Speed)
                index = length(track.Speed);
            end
            v = VideoReader(vidFile, 'CurrentTime', double(track.Frames(index)/track.FrameRate));
        elseif strcmp(fig.CurrentCharacter, 'e')%e for empty frame
            index = false;
            try
                save(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum), 'index');
            catch
                mkdir(sprintf('encounters\\%s', picPrefix));
                save(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum), 'index');
            end
            close;
            return
        end
        if index >= length(track.Speed)
           answer = questdlg('End of track data. Save this frame as index?', 'End of Track', 'Yes', 'Do not save index', 'Go back', 'Yes'); 
            if strcmp(answer, 'Yes')
                fig.CurrentCharacter = ' ';
            elseif strcmp(answer, 'Go back')
                index = index - track.FrameRate;
                v = VideoReader(vidFile, 'CurrentTime', double(track.Frames(index)/track.FrameRate));
            else
                index = false;
                close;
                return
            end
        end
    end

    notVidFrame = [];
    randy = index + (randi(120))*track.FrameRate*(-1)^(randi(2));
    while isempty(notVidFrame)
        try
            v = VideoReader(vidFile, 'CurrentTime', double(track.Frames(randy)/track.FrameRate));
            notVidFrame = readFrame(v);
            xs = round(track.SmoothX(1:randy));
            xs = xs(~isnan(xs));
            ys = round(track.SmoothY(1:randy));
            ys = ys(~isnan(ys));
            for cor = 1:randy vidFrame(round(ys(cor)), round(xs(cor)), :) = [0 0 255]; end
            notVidFrame = notVidFrame(by1(i):by2(i), bx1(i):bx2(i));
        catch
            randy = index + (randi(120))*track.FrameRate*(-1)^(randi(2));
        end
    end

    try
        save(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum), 'vidFrame', 'index');
        save(sprintf('encounters\\%s\\%i.N.mat', picPrefix, trackNum), 'notVidFrame');
    catch
        mkdir(sprintf('encounters\\%s', picPrefix));
        save(sprintf('encounters\\%s\\%i.Y.mat', picPrefix, trackNum), 'vidFrame', 'index');
        save(sprintf('encounters\\%s\\%i.N.mat', picPrefix, trackNum), 'notVidFrame');
    end
    close;
end 

return

end

function vidFile = getVidFile(name, track, varargin)
    if length(varargin) == 1
        searchPath = varargin{1};
        name = strcat(searchPath, '\**\', name);
    else
        name = strcat('**\', name);
    end
    file = dir(name);
    if isempty(file)
        name = split(track.Name, '\');
        name = char(name(end));
        name = split(name, '_');
        name = [name{1} '_refeeding_' name{2} '_' name{3} '_' name{4}];
        if exist('searchPath', 'var')
            name = strcat(searchPath, '\**\', name);
        else
            name = strcat('**\', name);
        end
        file = dir(name);
    end
    vidFile = strcat(file.folder, '\', file.name);
    return
end