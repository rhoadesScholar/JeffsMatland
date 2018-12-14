function SetFPS(hfig)
% Set frames per second for playback

% Cannot change period while movie is running
% Must stop timer, change frame rate, then restart timer

movieData = get(hfig,'userdata');


isRunning = strcmp(get(movieData.movieTimer,'Running'),'on');

if isRunning
    stop(movieData.movieTimer);
end

movieData.fps = movieData.Tracks(1).FrameRate;

set(movieData.movieTimer,'Period', 1./movieData.fps);

if isRunning
    start(movieData.movieTimer);
end

set(hfig,'userdata', movieData);

end
