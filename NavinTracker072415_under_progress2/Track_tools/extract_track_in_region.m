function outTrack = extract_track_in_region(inputTrack, region_polygon)
% outTrack = extract_track_in_region(inputTrack, region_polygon)

outTrack = [];

if(nargin<2)
    disp('outTrack = extract_track_segment(inputTrack, region_polygon)')
    disp('outTrack = track segment within region_polygon')
    return;
end

if(length(inputTrack)>1)
    for(i=1:length(inputTrack))
        outTrack = [outTrack extract_track_in_region(inputTrack(i), region_polygon)];
    end
    return;
end

% split track into contigious segments within the region of interest

% find frames within the region of interest
inside_flag = inpolygon(inputTrack.SmoothX, inputTrack.SmoothY, region_polygon(:,1),region_polygon(:,2));

idx = find(inside_flag==1);

if(~isempty(idx))
    
    j=1;
    while(j<length(idx))
        k = find_end_of_contigious_stretch(idx, j);
        
        % if j or k are during a reorientation event, move them so
        % the entire event is captured
        for(q=1:length(inputTrack.Reorientations))
            if(idx(j) >  inputTrack.Reorientations(q).start && idx(j) < inputTrack.Reorientations(q).end)
                idx(j) = inputTrack.Reorientations(q).start;
            end
            if(idx(k) >  inputTrack.Reorientations(q).start && idx(k) < inputTrack.Reorientations(q).end)
                idx(k) = inputTrack.Reorientations(q).end;
            end
        end
        
        % this segment must be at least 1 sec long
        if(k-j+1 > inputTrack.FrameRate)
            outTrack = extract_track_segment(inputTrack, idx(j), idx(k));
        end
        
        j = k+1;
    end
end

return;
end
