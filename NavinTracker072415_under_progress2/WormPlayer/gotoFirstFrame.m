function gotoFirstFrame(hbutton, eventStruct, hfig)
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');

gotoFrame(hfig, movieData.Tracks(movieData.TrackNum).Frames(1));

end

