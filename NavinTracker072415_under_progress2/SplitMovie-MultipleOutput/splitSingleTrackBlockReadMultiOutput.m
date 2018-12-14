function splitSingleTrackBlockRead(Tracks, MovieNameWithPath, MovieObj, TrackNum)

% This function splits the active movie file into separate files, each
% frame centered on the worm's centroid.  One file per track.
% Files are named MOVIENAME-N where N = track number.
% Current version only splits out the current track, future versions will
% split all tracks.

display('Splitting movie file...');

Track = Tracks(TrackNum);

WormLength = round(Track.Wormlength/Track.PixelSize);
WormLengthPadded = max(WormLength * 1.5, 32);

WormLengthPadded = 400;

chunk = 1;
maxChunkFrames = 1000;
movieFilenameMinusExt = MovieNameWithPath(1:length(MovieNameWithPath)-4);
movieFilenameSingleTrack = [movieFilenameMinusExt, '-Track-', int2str(TrackNum), '-Chunk-', int2str(chunk), '-Raw.avi'];
trackMovieObj = avifile(movieFilenameSingleTrack, 'compression', 'cvid');

Mov.colormap=[];

% Track.NumFrames
prevCentroid = [];

display ('Starting');
datestr(now)

maxFrames = MovieObj.NumberOfFrames;
% nFrames = MovieObj.NumberOfFrames;
vidHeight = MovieObj.Height;
vidWidth = MovieObj.Width;

frameOffset = 1;
frameWindow = 10;
lastFrame = min((frameOffset+frameWindow), maxFrames);
lastFrame = min(lastFrame, maxFrames);

% movWindow(1:lastFrame) = ...
%     struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
%            'colormap', []);

movWindow = read(MovieObj,[frameOffset lastFrame]);

% movWindow = read(MovieObj, [1 nFrames]);

endTrack = 10;
% for TrackFrame = 1:Track.NumFrames
for TrackFrame = 1:endTrack
    
% stopFrames = min(5,Track.NumFrames);
% for TrackFrame = 1:stopFrames
% 
    FrameNum = Track.Frames(TrackFrame);

    centroid = [Track.SmoothX(TrackFrame) Track.SmoothY(TrackFrame)];
    if ( isempty(centroid) )
        centroid = Tracks(TrackNum).Path(TrackFrame,:);
    end
    if ( isempty(centroid) )
        centroid = Track.bound_box_corner(TrackFrame,:);
    end
    if ( isempty(centroid) )
        PathBounds = splitGetPathBounds(Tracks, TrackNum);
        centroid = [(PathBounds(1)+PathBounds(2))/2, (PathBounds(3)+PathBounds(4))/2];
    end
    if ( isnan(centroid(1)) || isnan(centroid(2)) )
        if ( ~isempty(prevCentroid) )
            centroid = prevCentroid;
        else
            centroid = [ MovieObj.width/2, MovieObj.height/2 ];
        end
    end
    
    prevCentroid = centroid;
    
    minX = round(centroid(1) - WormLengthPadded/2);
    minY = round(centroid(2) - WormLengthPadded/2);

    %     Make sure minX and minY are within bounds
    minX = max(minX, 1);
    minY = max(minY, 1);
    
    minX = min(minX, MovieObj.width-WormLengthPadded);
    minY = min(minY, MovieObj.height-WormLengthPadded);

%     display ('About to grab frame');
%     datestr(now)
%     display(lastFrame);
    if ( FrameNum > lastFrame ) 
        frameOffset = FrameNum;
        lastFrame = min((frameOffset+frameWindow), maxFrames);
        lastFrame = min(lastFrame, maxFrames);
%         clear movWindow;
        movWindow = read(MovieObj,[frameOffset lastFrame]);
%         display('too high');
    elseif ( FrameNum < frameOffset ) 
        frameOffset = FrameNum - frameWindow;
        if ( frameOffset < 1 )
            frameOffset = 1;
        end
        lastFrame = min((frameOffset+frameWindow), maxFrames);
        lastFrame = min(lastFrame, maxFrames);
%         clear movWindow;
        movWindow = read(MovieObj,[frameOffset lastFrame]);
%         display('too low');
    end
%     display(frameOffset);
%     display(FrameNum);
%     display(FrameNum-frameOffset+1);
%     display(lastFrame);
    Mov.cdata = movWindow(:,:,:,FrameNum-frameOffset+1);
%     display ('About to crop');
%     datestr(now)
    Mov.cdata = imcrop(Mov.cdata, [minX, minY, WormLengthPadded, WormLengthPadded]);
%     display('About to add frame');
%     datestr(now)
    trackMovieObj = addframe(trackMovieObj, Mov);
%     display ('Done');
%     datestr(now)

    if ( mod(TrackFrame, maxChunkFrames) == 0 )
        display (['Reached track frame ', int2str(TrackFrame)]);
        datestr(now)
        trackMovieObj = close(trackMovieObj);
        chunk = chunk + 1;
        movieFilenameSingleTrack = [movieFilenameMinusExt, '-Track-', int2str(TrackNum), '-Chunk-', int2str(chunk), '-Raw.avi'];
        trackMovieObj = avifile(movieFilenameSingleTrack, 'compression', 'cvid');
    end
       
end
    display ('Done');
    datestr(now)
    trackMovieObj = close(trackMovieObj);

% movieFilenameSingleTrackCompressed = [movieFilenameMinusExt, '-Track-', int2str(TrackNum), '.avi'];
% rm(movieFilenameSingleTrackCompressed);
% converts the large uncompressed temp file to a compressed xvid mpeg4
% command = sprintf('ffmpeg -i %s -c libxvid -vtag xvid %s', movieFilenameSingleTrack, movieFilenameSingleTrackCompressed);
% run_command(command);
% system(command);
% rm(movieFilenameSingleTrack);

display('Done.');

return;