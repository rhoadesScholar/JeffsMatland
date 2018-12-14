function tracks = checkAllEncounters(tracks)

strains = fields(tracks);

%%%%%%%%LOAD VIDS
vids = struct();
indices = struct();

if isfield(tracks.(strains{1}), 'ID')
    for s = 1:length(strains)%each strain
        theseVids = {tracks.(strains{s}).ID};
        strainVids(1:length(theseVids)) = struct('vidFrames', []);
        strainIndices(1:length(theseVids)) = struct('indices', []);
        for t = 1:length(theseVids)%each track for all strain videos
            strainVids(t) = load(sprintf('**\\encounterVids\\%s.mat',theseVids{t}), 'vidFrames');
            strainIndices(t) = load(sprintf('**\\encounterVids\\%s.mat',theseVids{t}), 'indices');
        end
        vids.(strains{s}) = strainVids;
        indices.(strains{s}) = strainIndices;
        clear strainVids;
        clear strainIndices;
    end
else
    vidNames = parseVidNames(tracks, strains);%NOTE: vids is string array, not cell array
    for s = 1:length(strains)%each strain
        oldVidPaths = {};
        for v = 1:length(vidNames.(strains{s}))%each video per strain
            theseVidPaths = dir(sprintf('**\\encounterVids\\%s\\*.mat', vidNames.(strains{s})(v)));
            theseVidPaths = arrayfun(@(vid) [vid.folder '\' vid.name], theseVidPaths, 'UniformOutput', false);
            oldVidPaths = [oldVidPaths; theseVidPaths];
        end
        theseVidPaths = oldVidPaths;
        strainVids(1:length(theseVidPaths)) = struct('vidFrames', []);
        strainIndices(1:length(theseVidPaths)) = struct('indices', []);
        for t = 1:length(theseVidPaths)%each track for all strain videos
            strainVids(t) = load(theseVidPaths{t}, 'vidFrames');
            strainIndices(t) = load(theseVidPaths{t}, 'indices');
        end
        vids.(strains{s}) = strainVids;
        indices.(strains{s}) = strainIndices;
        clear strainVids;
        clear strainIndices;
    end
end

%%%%%%%%%%%%%%%%%%%%WATCH VIDS
for s = 1:length(strains)%each strain
    trackNum = 1;
    while trackNum <= length(tracks.(strains{s}))%each worm per strain
        thisVid = vids.(strains{s})(trackNum).vidFrames;
        localI = find(indices.(strains{s})(trackNum).indices == tracks.(strains{s})(trackNum).refeedIndex);
        
        fig = figure;
        fig.Name = sprintf('%s (%i of %i): worm %i of %i', strains{s}, s, length(strains), trackNum, length(tracks.(strains{s})));
        noShow = false;
        while ~strcmp(fig.CurrentCharacter, ' ')%press spacebar to indicate event
            imshow(thisVid(:,:,localI), 'DisplayRange', []);
            localI = localI + 1;
            pause();
            if strcmp(fig.CurrentCharacter, 'b')%b for backwards
                localI = localI - tracks.(strains{s})(trackNum).FrameRate;
                if localI < 1
                    localI = 1;
                end
            elseif strcmp(fig.CurrentCharacter, 'f')%f for fast forward
                localI = localI + 3*tracks.(strains{s})(trackNum).FrameRate;
                if localI > length(indices.(strains{s})(trackNum).indices)
                    localI = length(indices.(strains{s})(trackNum).indices);
                end
            elseif strcmp(fig.CurrentCharacter, 'e')%e for empty frame
                noShow = true;
                fig.CurrentCharacter = ' ';
            end
                
            if localI >= length(indices.(strains{s})(trackNum).indices) || localI <= 1
               answer = questdlg('End of track data. Save this frame as index?', 'End of Track', 'Yes', 'No', 'Do not save index', 'No'); 
                if strcmp(answer, 'Yes')
                    fig.CurrentCharacter = ' ';
                    if localI > length(indices.(strains{s})(trackNum).indices)
                        localI = length(indices.(strains{s})(trackNum).indices);
                    elseif localI < 1
                        localI = 1;
                    end
                elseif strcmp(answer, 'Do not save index')
                    noShow = true;
                    fig.CurrentCharacter = ' ';
                elseif localI > length(indices.(strains{s})(trackNum).indices)
                    localI = length(indices.(strains{s})(trackNum).indices);
                elseif localI < 1
                    localI = 1;
                end
            end
        end
        if ~noShow
            tracks.(strains{s})(trackNum).refeedIndex = indices.(strains{s})(trackNum).indices(localI);
            vids.(strains{s})(trackNum).vidFrames = [];
            trackNum = trackNum + 1;
        else
            if trackNum == 1
                tracks.(strains{s}) = tracks.(strains{s})([2:end]);
                indices.(strains{s}) = indices.(strains{s})([2:end]);
                vids.(strains{s}) = vids.(strains{s})([2:end]);
            else
                tracks.(strains{s}) = tracks.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
                indices.(strains{s}) = indices.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
                vids.(strains{s}) = vids.(strains{s})([1:(trackNum-1) (trackNum+1):end]);
            end
        end
        close;
    end
end

num = 1;
while exist(sprintf('allTracks%i.mat', num), 'file')
    num = num + 1;
end
name = split(unique({tracks.(strains{1}).Name}), '\');
name = name(:, :, end);
name = split(name, '_');
name = unique(name(:,:,1));
eval(sprintf('tracks%s = tracks', name))
eval(sprintf('save(''allTracks%i.mat'', ''tracks%s'')', num, name));
%save(sprintf('allTracks%i.mat', num), 'tracks');

return
end

function vidNames = parseVidNames(tracks, strains)
    for s = 1:length(strains)
        names = split(unique({tracks.(strains{s}).Name}), '\');
        if size(names,2)>1
            names = names(:, :, end);
            names = split(names, '.');
            vidNames.(strains{s}) = sort(names(:,:,1));
        else
            names = names(end);
            names = split(names, '.');
            vidNames.(strains{s}) = names(1);
        end        
    end
end