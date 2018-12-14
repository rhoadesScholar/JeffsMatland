function showPath(hbutton, eventStruct, hfig)
if nargin<3, hfig  = gcbf; end

movieData = get(hfig, 'userdata');

if (strcmp(movieData.DisplayTrack, 'off'))
 movieData.DisplayTrack = 'on';
else
    movieData.DisplayTrack = 'off';
end

set(hfig,'userdata',movieData);

displayFrame(hfig);

end

