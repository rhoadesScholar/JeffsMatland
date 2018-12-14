function LimitFrameSelector(hfig,pos) %,pos2,pos3,pos4)

% The following variable, "trackLimitMode", defines which track-limiting
% features are available.
%
% LIMIT - Limit frames in the same figure window, only.
% SPAWN - Spawns a new figure window with the limited track.
%         Spawned windows inherit the same features defined in
%         trackLimitMode
% BOTH - Limit and spawn options enabled
% NONE - No track limiting options available

LIMIT = 1;
SPAWN = 2;
BOTH = 3;
NONE = 4;

trackLimitMode = SPAWN;

movieData = get(hfig,'userdata');

movieData.FrameSelectorBeg = uicontrol(hfig, ...
    'tag', 'FRAMESELECTBEG', ...
    'enable', 'of', ...
    'style', 'edit', ...
    'Position', pos, ...
    'string', '1');

pos(1) = pos(1) + 55;
pos(3) = 50;
movieData.FrameSelectorEnd = uicontrol(hfig, ...
    'tag', 'FRAMESELECTEND', ...
    'enable', 'of', ...
    'style', 'edit', ...
    'Position', pos, ...
    'string', '1');

if ( trackLimitMode == LIMIT || trackLimitMode == BOTH )
    pos(1) = pos(1) + 55;
    pos(3) = pos(3) + 40;
    movieData.FrameSelectorText = uicontrol(hfig, ...
        'style','pushbutton', ...
        'tag', 'FRAMESELECTTEXT', ...
        'string', 'Limit frames', ...
        'Position', pos, ...
        'callback', @LimitFrames);

    pos(1) = pos(1) + 100;
    movieData.FrameSelectorReset = uicontrol(hfig, ...
        'style','pushbutton', ...
        'tag', 'FRAMESELECTRESET', ...
        'enable', 'off', ...
        'string', 'Full Track', ...
        'Position', pos, ...
        'callback', @LimitFramesReset);
    
else
    pos(1) = pos(1) + 155;
end

if ( trackLimitMode == SPAWN || trackLimitMode == BOTH )
    if ( trackLimitMode == BOTH )
        pos(1) = pos(1) + 100;
    else
        pos(1) = pos(1) - 100;
    end
    pos(3) = 2*pos(3); % NP
    movieData.FrameSelectorSpawn = uicontrol(hfig, ...
        'style','pushbutton', ...
        'tag', 'FRAMESELECTSPAWN', ...
        'enable', 'on', ...
        'string', 'New Frame Range', ...  % Spawn
        'Position', pos, ...
        'callback', @LimitFramesSpawn);
    if ( trackLimitMode == BOTH )
        pos(1) = pos(1) - 100;
    else
        pos(1) = pos(1) + 100;
    end
end

pos(2) = 0;
pos(3) = 200;

% pos = [570     0   200    20];
% 415     0   200    20


movieData.FullTrackFramesText = uicontrol(hfig, ...
    'style','text', ...
    'tag', 'FULLTRACKFRAMESTEXT', ...
    'string', '', ...
    'Position', pos);

movieData.TempTrack = 0;

set(hfig,'userdata', movieData);

end

