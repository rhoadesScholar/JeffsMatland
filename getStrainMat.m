function tracksMat = getStrainMat(dates, strain)%dates is cell array of folders with track files, strain is char array

%     m = number of tracks, n = number of frames
%     (m,n,1) SmoothX
%     (:,:,2) SmoothY
%     (:,:,3) Speed
%     (:,:,4) AngSpeed
%     (:,:,5) Frames
%     (:,:,6) Time
   
    matFields = {'SmoothX' 'SmoothY' 'Speed' 'AngSpeed' 'Frames' 'Time'};
    tracksMat = struct();
    tracksMat.dates = dates;
    
    for d = 1:length(dates)%d for day
        cd(dates{d});
        trackFile = dir(sprintf('allTracks_%s*.mat', dates{d}));
        trackFile = trackFile(end).name;
        load(trackFile);
        eval(sprintf('tracks = tracks_%s.%s', dates{d}, strain));
        if ~isfield(tracks, 'headingError') || ~isfield(tracks, 'lawnDist')
            tracks = addNavFields(tracks);
        end
        
        tracksMat.refeedIndex = [tracks.refeedIndex];
        tracksMat.PixelSize = [tracks.PixelSize];
        tracksMat.FrameRate = [tracks.FrameRate];
        tracksMat.Name = {tracks.Name};
        
        tracksMat.Mat = padFields(tracks, matFields);
        
        cd ..
    end
    return


end

function [frontBuf, endBuf, range] = getPadding(tracks)
    
    endLag = max(arrayfun(@(y) single([(length(y.Frames) - y.refeedIndex)]), tracks));
    frontLag = max(arrayfun(@(y) single([(y.refeedIndex - 1)]), tracks));
    range = endLag + frontLag + 1;
    frontBuf = (frontLag) - [tracks.refeedIndex];
    endBuf = range - (frontBuf + arrayfun(@(y) length(y.Frames), tracks));
    
end

function [fieldMat] = padFields(tracks, matFields)
    [frontBuf, endBuf, range] = getPadding(tracks);
    %m = arrayfun(@(y) length(y.Frames), tracks);
    fieldMat = NaN(length(tracks), range);
    for f = 1:length(matFields)
        if tracks.(matFields{f})
        fieldMat(:,:,f) = [arrayfun(@(x) NaN(x), frontBuf) tracks.(matFields{f}) NaN(endBuf)];        
    end
    dfsgsdfg
end
