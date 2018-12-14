function LimitFramesReset(hbutton, eventStruct, hfig)
% 
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');
if ( movieData.TempTrack ~= 0 )
    movieData.Tracks(movieData.TempTrack) = [];
    movieData.TempTrack = 0;
end

movieData.TrackNum = movieData.OrigTrackNum;
movieData.OrigTrackNum = 1;

H = movieData.FrameSelectorReset;
set(H, 'enable', 'off');

H = movieData.FrameSelectorText;
set(H, 'enable', 'on');

STR = movieData.FullTrackFramesText;
set(STR, 'string', '');

set(hfig,'userdata', movieData);
loadTrack(hfig);

end

