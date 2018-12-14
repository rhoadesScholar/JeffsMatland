function playMovie (hbutton, eventStruct, hfig)
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');
icons = get_icons_from_fig(hfig);
hPlay = findobj(movieData.htoolbar, 'tag','Play/Pause');

if strcmp(movieData.play, 'on')
    set(hPlay, ...
     ...  % 'tooltip', 'Resume', ...
        'cdata', icons.play_on);
    movieData.play = 'off';
    stop(movieData.movieTimer);
    set(hfig,'userdata', movieData);
    return;
end

movieData.play = 'on';

start(movieData.movieTimer);

set(hPlay, ...
   ...  %       'tooltip', 'Resume', ...
    'cdata', icons.play_off);
set(hfig,'userdata', movieData);

% for FrameNum = movieData.FrameNum:movieData.Tracks(movieData.TrackNum).Frames(end)
%     movieData.FrameNum = FrameNum;
%     movieData.TrackFrame = movieData.FrameNum - movieData.Tracks(movieData.TrackNum).Frames(1) + 1;
%     set(hfig,'userdata', movieData);
%     displayFrame(hfig);
%     pause(1/movieData.fps);
% end

end

