function frame = createActiveWormBox(frame, X, Y, WormLength)

PointColor = [ 0 255 0 ];
X = round(X);
Y = round(Y);

% WormLength = max(WormLength, 15);

MaxWormWidth = WormLength * 1.5;
MaxWormHeight = WormLength * 1.5;

boxWidth = round(MaxWormWidth/2);
boxHeight = round(MaxWormHeight/2);

minY = max(1,Y-boxHeight);
maxY = min(size(frame,1),Y+boxHeight);

minX = max(1,X-boxWidth);
maxX = min(size(frame,2),X+boxWidth);

for curX = minX:maxX
    frame(minY,curX,:) = PointColor;
    frame(maxY,curX,:) = PointColor;
end

for curY = minY:maxY
    frame(curY,minX,:) = PointColor;
    frame(curY,maxX,:) = PointColor;
end

return
