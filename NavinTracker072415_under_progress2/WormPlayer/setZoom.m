function setZoom(hbutton, eventStruct, hfig)
if nargin<3, hfig  = gcbf; end

movieData = get(hfig, 'userdata');

hZoom = findobj(movieData.htoolbar, 'tag','ZOOM');
icons = get_icons_from_fig(hfig);

if ( movieData.ZoomLevel == movieData.MaxZoomLevel )
    movieData.ZoomLevel = 0;
    set(hZoom, ...
        'cdata', icons.ZoomOff);
else
    movieData.ZoomLevel = movieData.ZoomLevel + 1;
    set(hZoom, ...
        'cdata', icons.ZoomOn);
end

% if (strcmp(movieData.ZoomLevel, 'off'))
%     movieData.Zoom = 'track';
%     set(hZoom, ...
%         'cdata', icons.ZoomOn);
% else
%     movieData.Zoom = 'off';
%     set(hZoom, ...
%         'cdata', icons.ZoomOff);
% end

% display(movieData.ZoomLevel);

set(hfig,'userdata',movieData);

displayFrame(hfig);
end

