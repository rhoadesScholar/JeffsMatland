function ClickedTrack = FindClickedTrack(ClickX, ClickY, BoundingBoxes)

prevDistance = NaN;

% ClickY = ClickY + 20;

ClickedTrack.TN = 0;
ClickedTrack.FN = 0;

for BN = 1:length(BoundingBoxes)
    if ( ClickX >= BoundingBoxes(BN).minX && ClickX <= BoundingBoxes(BN).maxX && ...
            ClickY >= BoundingBoxes(BN).minY && ClickY <= BoundingBoxes(BN).maxY )
        BoxMidX = round(median(BoundingBoxes(BN).minX, BoundingBoxes(BN).maxX));
        BoxMidY = round(median(BoundingBoxes(BN).minY, BoundingBoxes(BN).maxY));
        deltX = abs(BoxMidX - ClickX);
        deltY = abs(BoxMidY - ClickY);
        distance = sqrt((deltX*deltX)+(deltY*deltY));
        
        if ( isnan(prevDistance) || prevDistance > distance )
            prevDistance = distance;
            ClickedTrack.TN = BoundingBoxes(BN).TrackNum;
            ClickedTrack.FN = BoundingBoxes(BN).FrameNum;
        end
    end
end
return
end