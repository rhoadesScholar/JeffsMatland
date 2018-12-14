function [xOut,yOut] = outOfRange(data,x,y)
%OUTOFRANGE function checks whether the user has made a selection outside
%the given axis. 
    limits = data;
    xLimits = [limits(1,3),limits(2,3)];
    yLimits = [limits(1,4),limits(3,4)];
    xDir = sign(diff(xLimits));
    yDir = sign(diff(yLimits));
    xOut = false;
    yOut = false;
    if (xDir == 1) && (any(xLimits(1) > x) || any(xLimits(2) < x))
        xOut = true;
    elseif (xDir == -1) &&  (any(x > xLimits(1)) || any(x < xLimits(2)))
        xOut = true;
    elseif (yDir == 1) && (any(y < yLimits(1)) || any(y > yLimits(2)))
        yOut = true;
    elseif (yDir == -1) && (any(y > yLimits(1)) || any(y < yLimits(2)))
        yOut = true;   
    end
end

