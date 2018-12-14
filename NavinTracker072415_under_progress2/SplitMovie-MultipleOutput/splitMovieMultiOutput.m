function splitMovieMultiOutput(TrackFileName, MovieNameWithPath, TrackNum)

if (~exist('Tracks', 'var') && ~exist('mergedTracks', 'var'))
    load(TrackFileName);
end

if (exist('mergedTracks', 'var'))
    Tracks = mergedTracks;
elseif (exist('finalTracks', 'var'))
    Tracks = finalTracks;
end

Tracks = make_double(Tracks);

MovieObj = VideoReader(MovieNameWithPath);

if (ischar(TrackNum))
    for TrackNum = 1:length(Tracks)
        display(TrackNum);
        splitSingleTrackBlockReadMultiOutput(Tracks, MovieNameWithPath, MovieObj, TrackNum);
    end
else
        display(TrackNum);
        splitSingleTrackBlockReadMultiOutput(Tracks, MovieNameWithPath, MovieObj, TrackNum);
end
clear('MovieObj');

end
