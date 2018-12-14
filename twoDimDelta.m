function deltaList = twoDimDelta(x, y, ratioX, ratioY)

if nargin < 4
    mode = ratioX;
    X = x;
    Y = y;
else
    X = x/ratioX;
    Y = y/ratioY;
    mode = 'euclidean';
end

%see pdist2(X, Y, 'distance') for alternative methods of calculation

deltaMat = pdist2([X', Y'], [X', Y'], mode);
deltaMat = deltaMat';

deltaList = deltaMat(2:(length(X)+1):end);


% avg = nanmean(deltaList);
% stdErr = std(deltaList)/sqrt(length(deltaList));

return
end