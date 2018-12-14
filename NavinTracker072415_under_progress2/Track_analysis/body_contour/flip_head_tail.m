function flip_head_tail_vector  = flip_head_tail(Track)

pixelWormLength_sqrd = ((Track.Wormlength/2)/Track.PixelSize)^2;

flip_head_tail_vector = zeros(1,length(Track.Frames));
for(i=2:length(Track.Frames))
    
    if(Track.body_contour(i).head > 0 && Track.body_contour(i-1).head > 0)
        
        dist_sqrd = (Track.body_contour(i).x(Track.body_contour(i).head) - Track.body_contour(i-1).x(Track.body_contour(i-1).head))^2 + ...
            (Track.body_contour(i).y(Track.body_contour(i).head) - Track.body_contour(i-1).y(Track.body_contour(i-1).head))^2;

        % head for i is very far from head for i-1
        if(dist_sqrd >= pixelWormLength_sqrd)
            flip_head_tail_vector(i) = 1;
        end
        
    end
end

return;
end
