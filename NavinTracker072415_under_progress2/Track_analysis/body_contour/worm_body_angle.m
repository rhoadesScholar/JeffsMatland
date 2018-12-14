function [body_angle, head_angle, tail_angle] = worm_body_angle(Track)

tracklength = length(Track.Frames);

body_angle = zeros(1,tracklength) + NaN;
head_angle = zeros(1,tracklength) + NaN;
tail_angle = zeros(1,tracklength) + NaN;

if(~isfield(Track, 'body_contour'))
    return;
end

for(i=1:tracklength)
    
    head = [];
    if(Track.body_contour(i).head>0)
        head = [Track.body_contour(i).x(Track.body_contour(i).head) Track.body_contour(i).y(Track.body_contour(i).head)];
    end
    
    midbody = [];
    if(Track.body_contour(i).midbody>0)
        midbody = [Track.body_contour(i).x(Track.body_contour(i).midbody) Track.body_contour(i).y(Track.body_contour(i).midbody)];
    end
    
    tail = [];
    if(Track.body_contour(i).tail>0)
        tail = [Track.body_contour(i).x(Track.body_contour(i).tail) Track.body_contour(i).y(Track.body_contour(i).tail)];
    end
    
    neck = [];
    if(Track.body_contour(i).neck>0)
        neck = [Track.body_contour(i).x(Track.body_contour(i).neck) Track.body_contour(i).y(Track.body_contour(i).neck)];
    end
    
    lumbar = [];
    if(Track.body_contour(i).lumbar>0)
        lumbar = [Track.body_contour(i).x(Track.body_contour(i).lumbar) Track.body_contour(i).y(Track.body_contour(i).lumbar)];
    end
    
    if(~isempty(head) && ~isempty(midbody) && ~isempty(tail))
        body_angle(i) = angle_between_three_points(head, midbody, tail);
    end
    
    if(~isempty(head) && ~isempty(neck) && ~isempty(midbody))
        head_angle(i) = angle_between_three_points(head, neck, midbody);
    end
    
    if(~isempty(midbody) && ~isempty(lumbar) && ~isempty(tail))
        tail_angle(i) = angle_between_three_points(midbody, lumbar, tail);
    end
    
end

return;
end
