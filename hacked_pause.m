% loop cycle time is normally PAUSELOOP_STEPSIZE = 0.015625 sec
% if within 0.015625/2 sec have elapsed, end
% gives pause times that are equal to the inputted time, on average!!
% not perfect, but it's better than the matlab pause function, at least for
% times < 0.5sec

function actual_pausetime = hacked_pause(pausetime)

global PAUSELOOP_STEPSIZE;
global PAUSELOOP_HALF_STEPSIZE;

if(pausetime <= 0)
    actual_pausetime = 0;
    return;
end

t0=absolute_seconds(clock);

% for longer pauses, use the system pause command
if(pausetime>1)
    pause(pausetime)
    actual_pausetime = absolute_seconds(clock)-t0;
    return;
end

delT = round(pausetime/PAUSELOOP_STEPSIZE)*PAUSELOOP_STEPSIZE;

while( (delT-(absolute_seconds(clock)-t0)) >  PAUSELOOP_HALF_STEPSIZE )
    % futile while-loop for the actual pause
end

actual_pausetime = absolute_seconds(clock)-t0;

return;
