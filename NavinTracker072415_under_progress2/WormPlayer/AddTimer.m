function AddTimer(hfig)

movieData = get(hfig,'userdata');
% Setup timer
h = timer( ...
    'ExecutionMode','fixedRate', ...
    'TimerFcn', @TimerTickFcn, ...
    'StopFcn', @TimerStopFcn, ...
    'BusyMode', 'queue', ... %'drop', ...
    'TasksToExecute', inf);

% Store fig handle in timer
movieTimer.hfig = hfig;
set(h,'userdata',movieTimer);

% Store timer handle in figure
movieData.movieTimer = h;
set(hfig,'userdata', movieData);

end