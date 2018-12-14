function clickGotoTrack(hObject, eventdata)
[ClickX ClickY] = clickPos(hObject, eventdata);

hfig = get(hObject, 'parent');
movieData = get(hfig,'userdata');

if ( length(movieData) == 0 )
    hfig = get(hfig, 'Parent');
    movieData = get(hfig,'userdata');
end

Wormlength = max(movieData.Tracks(movieData.TrackNum).Wormlength, 15);
MaxHeight = Wormlength;
MaxWidth = Wormlength;

% first, create a bounding box for each worm for this track number...
BoundingBoxes = CreateBoundingBoxes(movieData.Tracks, movieData.FrameNum, ...
    MaxHeight, MaxWidth); 

ClickedTrack = FindClickedTrack(ClickX, ClickY, BoundingBoxes);

ClickedTrack.TN = round(ClickedTrack.TN);
ClickedTrack.FN = round(ClickedTrack.FN);
% if ( ClickedTrack.TN == 0 || ClickedTrack.TN == ud.TrackNum )
if ( ClickedTrack.TN == 0 )
    return;
end

movieData.TrackNum = ClickedTrack.TN;
movieData.FrameNum = ClickedTrack.FN;

movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
movieData.PreserveFrameNum = 1;
% display(movieData.TrackNum);

set(hfig,'userdata', movieData);

loadTrack(hfig);
