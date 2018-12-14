function frame = drawFrameDetails(frame, hfig)

movieData = get(hfig,'userdata');
TrackNum = movieData.TrackNum;
Track = movieData.Tracks(TrackNum);
WormLength = Track.Wormlength/Track.PixelSize; % Convert worm length from mm to pixels

% Display path if requested:
if ( strcmp(movieData.DisplayTrack, 'on') )
    if(isfield(movieData.Tracks(movieData.TrackNum),'SmoothX'))
        Path = [movieData.Tracks(movieData.TrackNum).SmoothX(:) movieData.Tracks(movieData.TrackNum).SmoothY(:)];
    else
        Path = [movieData.Tracks(movieData.TrackNum).Path(:,1) movieData.Tracks(movieData.TrackNum).Path(:,2)];
    end
    frame = DrawTrack(frame, Path, movieData.Tracks(movieData.TrackNum));
end



%Draw active worm box
if ( ~isnan(movieData.Tracks(movieData.TrackNum).SmoothX(movieData.TrackFrame)) || ...
        ~isnan(movieData.Tracks(movieData.TrackNum).SmoothY(movieData.TrackFrame)) )
    frame = createActiveWormBox(frame, movieData.Tracks(movieData.TrackNum).SmoothX(movieData.TrackFrame), ...
        movieData.Tracks(movieData.TrackNum).SmoothY(movieData.TrackFrame), WormLength);
    
    % by Navin
    if(isfield(movieData.Tracks,'body_contour'))
        frame = createHeadTail(frame, movieData.Tracks(movieData.TrackNum).body_contour(movieData.TrackFrame));
        frame( round(movieData.Tracks(movieData.TrackNum).SmoothY(movieData.TrackFrame)), round(movieData.Tracks(movieData.TrackNum).SmoothX(movieData.TrackFrame)) , :) = [0 0 0]; % black centroid
    end
    
    if(isfield(movieData.Tracks,'Q'))
        if(sum(movieData.Tracks(movieData.TrackNum).Q(movieData.TrackFrame,:))>0)
            frame(floor(movieData.Tracks(movieData.TrackNum).Q(movieData.TrackFrame,2)), floor(movieData.Tracks(movieData.TrackNum).Q(movieData.TrackFrame,1)), :) = [255 255 0]; 
        end
    end
end

% ActualFrameNum = Tracks(TrackNum).Frames(CurrentFrame);
% frame = createWormIndicators(frame, movieData.TrackNum, movieData.FrameNum, movieData.Tracks, show_body_contour_flag);

return;
end

