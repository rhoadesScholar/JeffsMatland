% the length of the path (in pixels) travelled from startFrame to endFrame

function d = track_path_length(Track, startFrame, endFrame)

if(nargin<2)
    startFrame=1;
    endFrame=length(Track.SmoothX);
end

if(isfield(Track,'SmoothX'))
    X = Track.SmoothX(startFrame:endFrame);
    Y = Track.SmoothY(startFrame:endFrame);
else
    X = Track.Path(startFrame:endFrame,1);
    Y = Track.Path(startFrame:endFrame,2);
end

X = X(~isnan(X));
Y = Y(~isnan(Y));

dX = diff(X);
dY = diff(Y);

dR = dX.^2 + dY.^2;

dR = sqrt(dR);

d = sum(dR);

clear('dR');
clear('dX');
clear('dY');
clear('X');
clear('Y');

return;

end

