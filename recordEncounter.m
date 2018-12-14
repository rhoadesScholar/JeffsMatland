function start = recordEncounter(i, track, trackNum)
mlock
persistent searchPath;
persistent v;

if isempty(searchPath)
    searchPath = 'F:\';%%%Change for right drive
end
preTime = 20;
endTime = 60;

name = split(track.Name, '\');
name = char(name(end));
picPrefix = split(name, '.');
picPrefix = picPrefix{1}; 

vidFile = getVidFile(name, track, searchPath);
if isempty(v) || ~strcmp(vidFile, sprintf('%s\\%s', v.Path, v.Name))
    try
        v = VideoReader(vidFile);
    catch
        answer = questdlg('Abort load?', 'Could not load vid', 'No', 'Yes', 'No');
        if strcmp(answer, 'No')
            answer = inputdlg('Change search:', 'Search path', 1, {searchPath});
            searchPath = answer{1};
            vidFile = getVidFile(name, track, searchPath);
            if strcmp(vidFile, '\')
                there = dir([searchPath '**\BehavioralCam']);
                while isempty(there)
                    cd ..
                    there = dir('BehavioralCam');
                    display('ello govna! ur in da loop looking for BehavioralCam!')
                end
                vidFile = getVidFile(name, track, searchPath);
            end
            v = VideoReader(vidFile);
        end
    end
end

xydif = [250, 250];%may need to be adjusted for other image resolutions
    bx1 = [track.SmoothX(i) - xydif(:,1)'];
    bx1(bx1 < 1)= 1;
    bx2 = [track.SmoothX(i) + xydif(:,1)'];
    bx2(bx2 > track.Width)=track.Width;
    by1 = [track.SmoothY(i) - xydif(:,2)'];
    by1(by1 < 1) = 1;
    by2 = [track.SmoothY(i) + xydif(:,2)'];
    by2(by2 > track.Height)=track.Height;

start = i - (track.FrameRate*preTime);
if start <= 1
    start = 1;
end

fin = i + (track.FrameRate*endTime);
if fin >= length(track.Speed)
    fin = length(track.Speed);
end

rTry = 0;
while rTry < 3
    try
        vidFrames = read(v, [track.Frames(start) track.Frames(fin)]);
        rTry = 4;
    catch
        pause(30)
        rTry = rTry + 1;
    end
end

xs = round(track.SmoothX(start:fin));
trackFramesInds = ~isnan(xs);
xs = xs(~isnan(xs));
ys = round(track.SmoothY(start:fin));
ys = ys(~isnan(ys));

theseYs = [];
theseXs = [];
n = 0;

%%%%ADJUST TO WORK WITH GRAYSCALE VIDS
for frame = 1:length(start:fin) 
    if trackFramesInds(frame)
        n = n + 1;
        theseYs = [theseYs ys(n)];
        theseXs = [theseXs xs(n)];
    end
    for XY = 1 : length(theseXs)
        vidFrames(theseYs(XY), theseXs(XY), (1+3*(frame-1)):3*frame) = 160;
    end
end
vidFrames = vidFrames(by1:by2, bx1:bx2, :);

newVid(size(vidFrames,1),size(vidFrames,2),length(start:fin)) = single(1);
for frame = 1:length(start:fin) 
    newVid(:,:, frame) = rgb2gray(vidFrames(:, :, (1+3*(frame-1)):3*frame));
end
vidFrames = newVid;

indices = [start:fin];

if isfield(track, 'ID')
    trackIndex = track.ID;
    try
        save(sprintf('encounterVids\\%s.mat', trackIndex), 'vidFrames', 'indices');
    catch
        mkdir('encounterVids');
        save(sprintf('encounterVids\\%s.mat', trackIndex), 'vidFrames', 'indices');
    end
else
    if trackNum >= 10
        b = '00';
    elseif trackNum >= 100
        b = '0';
    elseif trackNum >= 1000
        b = '';
    else
        b = '000';
    end
    trackIndex = sprintf('%s%i', b, trackNum);

    try
        save(sprintf('encounterVids\\%s\\%s.mat', picPrefix, trackIndex), 'vidFrames', 'indices');
    catch
        mkdir(sprintf('encounterVids\\%s', picPrefix));
        save(sprintf('encounterVids\\%s\\%s.mat', picPrefix, trackIndex), 'vidFrames', 'indices');
    end
end
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
