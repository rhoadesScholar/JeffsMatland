function loadTrack(hfig)

movieData = get(hfig,'userdata');

MovieName = '';
MovieNameWithPath = '';
MoviePath = '';
TempMovie = '';

movieData.Movie = movieData.Tracks(movieData.TrackNum).Name;

if (~exist(movieData.Movie, 'file'))
    dummyfilename = sprintf('%s%s%s',movieData.trackPathName,filesep,filename_from_partialpath(movieData.Tracks(1).Name));
    if (~exist(dummyfilename, 'file'))
        [FileName,PathName] = uigetfile(dummyfilename, 'Choose a movie file'); % uigetfile('*.avi', 'Choose a movie file');
        movieData.Movie = [ PathName FileName ];
        movieData.trackPathName = PathName;
    else
        movieData.Movie = dummyfilename;
    end
end
    
if (~exist(movieData.Movie, 'file'))
    display('ERROR - Movie cannot be found!');
end

if ( movieData.PreserveFrameNum )
    movieData.PreserveFrameNum = 0;
else
    movieData.FrameNum = movieData.Tracks(movieData.TrackNum).Frames(1);
    movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
end

movieData.TrackNumFrames = length(movieData.Tracks(movieData.TrackNum).Frames);
movieData.NumTracks = length(movieData.Tracks);

set(hfig,'userdata', movieData);

getPathBounds(hfig);

displayFrame(hfig);

end