function TimerTickFcn(hco, user) %hbutton, eventStruct, hfig)

ud = get(hco,'userdata');     % hco = timer object
hfig = ud.hfig;

movieData = get(hfig,'userdata');

% display('Before: ');
% display(movieData.FrameNum);
movieData.FrameNum = movieData.FrameNum + 1;
% display('After: ');
% display(movieData.FrameNum);

if ( movieData.FrameNum < movieData.Tracks(movieData.TrackNum).Frames(1) )
    movieData.FrameNum = movieData.Tracks(movieData.TrackNum).Frames(1);
elseif ( movieData.FrameNum > movieData.Tracks(movieData.TrackNum).Frames(end) )
    movieData.FrameNum = movieData.Tracks(movieData.TrackNum).Frames(end);
end

movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
    
set(hfig,'userdata', movieData);
% display('Final: ');
% display(movieData.FrameNum);
displayFrame(hfig);

if ( movieData.FrameNum == movieData.Tracks(movieData.TrackNum).Frames(end) )
    TimerStopFcn(hbutton, eventStruct, hfig);
end

end