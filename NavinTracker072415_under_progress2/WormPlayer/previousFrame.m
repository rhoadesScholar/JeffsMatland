function previousFrame (hbutton, eventStruct, hfig)
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');

if ( movieData.FrameNum > movieData.Tracks(movieData.TrackNum).Frames(1) )
    movieData.FrameNum = movieData.FrameNum - 1;
    movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
    set(hfig,'userdata', movieData);
    displayFrame(hfig);
end

end

