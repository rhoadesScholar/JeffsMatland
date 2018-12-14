function BoundingBoxes = CreateBoundingBoxes(Tracks, Frame, ...
    MaxWormHeight, MaxWormWidth)
BN = 1;

% BoundingBoxes = zeros(length(Tracks));

for TN = 1:length(Tracks)
%     if ( TN == TrackNum || ...
%             Tracks(TN).Frames(1) > ActualFrameNum || ...
%             Tracks(TN).Frames(Tracks(TN).NumFrames) < ActualFrameNum )
%         continue;
%     end
    for FN = 1:Tracks(TN).NumFrames
        if ( Tracks(TN).Frames(FN) == Frame && ...
                ~isnan(Tracks(TN).SmoothX(FN)) &&           ...
                ~isnan(Tracks(TN).SmoothY(FN)))
            centerX = round(Tracks(TN).SmoothX(FN));
            centerY = round(Tracks(TN).SmoothY(FN));
%             frame(centerY,centerX,:) = PointColor;
            BoundingBoxes(BN) = CreateBoundingBox(centerX, centerY, MaxWormHeight, MaxWormWidth, TN, FN);
            BN = BN + 1;
            break;
        end
    end
end
return
end
