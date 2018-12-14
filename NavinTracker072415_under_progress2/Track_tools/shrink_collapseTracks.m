function collapseTracks = shrink_collapseTracks(inTracks)

collapseTracks=[];

j=1;
while(j<=length(inTracks))
    t1 = inTracks(j);
    
    t2 = rmfield(t1,{'Image','bound_box_corner','body_contour',  ...
        'Path','Size',  ...
        'MajorAxes','RingDistance','Height','Width','PixelSize','Name',  ...
        'SmoothX','SmoothY','Wormlength' ,'Direction','original_track_indicies','curvature_vs_body_position_matrix' ...
        'Active'}); 

    collapseTracks = [collapseTracks rmfield(t2,'RingDistance') ]; % for some reason, RingDistance could not be included above
    
    clear('t1'); clear('t2');
    
    j=j+1;
end

collapseTracks = make_single(collapseTracks);

return;
end

