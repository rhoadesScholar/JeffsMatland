function frame = createWormIndicators(frame, TrackNum, ActualFrameNum, Tracks, show_body_contour_flag) %X, Y, MaxWormHeight, MaxWormWidth)

PointColor = [ 0 255 0 ];

for TN = 1:length(Tracks)
    if ( TN ~= TrackNum )
        
        
        FN = find(Tracks(TN).Frames == ActualFrameNum);
        if(~isempty(FN))
            %     for FN = 1:Tracks(TN).NumFrames
            %         if ( Tracks(TN).Frames(FN) == ActualFrameNum && ...
            %                 ~isnan(Tracks(TN).SmoothX(FN)) &&           ...
            %                 ~isnan(Tracks(TN).SmoothY(FN)))
            
            centerX = round(Tracks(TN).SmoothX(FN));
            centerY = round(Tracks(TN).SmoothY(FN));
            frame(centerY,centerX,:) = PointColor;
            % by Navin
            frame = createHeadTail(frame, Tracks(TN).body_contour(FN), show_body_contour_flag);
            
        end
    end
    %             break;
    %         end
    %     end
end




%         PointColor = [ 0 255 0 ];
%         X = round(X);
%         Y = round(Y);
%
%         MaxWormWidth = MaxWormWidth * 1.5;
%         MaxWormHeight = MaxWormHeight * 1.5;
%
%         boxWidth = round(MaxWormWidth/2);
%         boxHeight = round(MaxWormHeight/2);
%
%         minY = max(1,Y-boxHeight);
%         maxY = min(size(frame,1),Y+boxHeight);
%
%         minX = max(1,X-boxWidth);
%         maxX = min(size(frame,2),X+boxWidth);
%
%         for curX = minX:maxX
%             frame(minY,curX,:) = PointColor;
%             frame(maxY,curX,:) = PointColor;
%         end
%
%         for curY = minY:maxY
%             frame(curY,minX,:) = PointColor;
%             frame(curY,maxX,:) = PointColor;
%         end

return