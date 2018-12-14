function gotoFrame(hfig, frameNum)

movieData = get(hfig,'userdata');

% Following if statement is here to handle when a user clicks on a plot line
% as opposed to clicking in the plot, but not on line
if ( length(movieData) == 0 )
    hfig = get(hfig, 'Parent');
    movieData = get(hfig,'userdata');
end

if ( frameNum >= movieData.Tracks(movieData.TrackNum).Frames(1) && ...
        frameNum <= movieData.Tracks(movieData.TrackNum).Frames(end) )
    movieData.FrameNum = frameNum;
    movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
    set(hfig,'userdata', movieData);
    displayFrame(hfig);
end


end

