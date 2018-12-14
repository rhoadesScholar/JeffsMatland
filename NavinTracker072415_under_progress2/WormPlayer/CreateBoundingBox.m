function BoundingBox = CreateBoundingBox(X, Y, MaxWormHeight, MaxWormWidth, TrackNum, FrameNum)
X = round(X);
Y = round(Y);

MaxWormWidth = MaxWormWidth * 1.5;
MaxWormHeight = MaxWormHeight * 1.5;

boxWidth = round(MaxWormWidth/2);
boxHeight = round(MaxWormHeight/2);

BoundingBox.minY = max(1,Y-boxHeight);
BoundingBox.maxY = Y+boxHeight;

BoundingBox.minX = max(1,X-boxWidth);
BoundingBox.maxX = X+boxWidth;
BoundingBox.TrackNum = TrackNum;
BoundingBox.FrameNum = FrameNum;
return;
end
