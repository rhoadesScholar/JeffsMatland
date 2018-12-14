% sets the stimulus vector to lawncode when the track is in the lawn
% defined by lawn_edge

function Tracks = lawn_edge_to_stimulus_vector(Tracks, lawn_edge)

global Prefs;

for(i=1:length(Tracks))
    Tracks(i).stimulus_vector = zeros(1,length(Tracks(i).Frames));
    inlawn = [];
    if(Prefs.use_centroid_location_flag==1)
        inlawn = inpolygon(Tracks(i).SmoothX, Tracks(i).SmoothY, lawn_edge(:,2), lawn_edge(:,1));
    else
        head_x =[]; tail_x=[];
        head_y =[]; tail_y=[];
        for(j=1:length(Tracks(i).body_contour))
            if(Tracks(i).body_contour(j).head >  0) % head
                head_x = [head_x Tracks(i).body_contour(j).x(Tracks(i).body_contour(j).head)];
                head_y = [head_y Tracks(i).body_contour(j).y(Tracks(i).body_contour(j).head)];
            else  % or the centroid
                head_x = [head_x Tracks(i).SmoothX(j) ];
                head_y = [head_y Tracks(i).SmoothY(j) ];
            end
            if(Tracks(i).body_contour(j).tail >  0) % tail
                tail_x = [tail_x Tracks(i).body_contour(j).x(Tracks(i).body_contour(j).tail)];
                tail_y = [tail_y Tracks(i).body_contour(j).y(Tracks(i).body_contour(j).tail)];
            else  % or the centroid
                tail_x = [tail_x Tracks(i).SmoothX(j) ];
                tail_y = [tail_y Tracks(i).SmoothY(j) ];
            end
        end
        inlawn_h = inpolygon(head_x, head_y, lawn_edge(:,2), lawn_edge(:,1));
        inlawn_t = inpolygon(tail_x, tail_y, lawn_edge(:,2), lawn_edge(:,1));
        
        % considered in-lawn if either the head or tail are in the lawn
        inlawn = inlawn_h | inlawn_t;
        
        clear('head_x');
        clear('head_y');
    end
    
    Tracks(i).stimulus_vector(inlawn) = Prefs.LawnCode;
end


return;
end
