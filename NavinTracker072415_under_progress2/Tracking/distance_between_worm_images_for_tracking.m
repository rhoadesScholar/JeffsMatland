function output_dist = distance_between_worm_images_for_tracking(max_dist, reject_code, image1, bound_box_corner1, image2, bound_box_corner2)
% output_dist = distance_between_worm_images_for_tracking(max_dist, reject_code, image1, bound_box_corner1, image2, bound_box_corner2)
% if worms not within max_dist of each other, return reject_code
% else, return the minimal distance between worm pixels

output_dist = reject_code;

try
    % bounding boxes must be within max_dist of each other for the worms to be
    % within max_dist of each other
    if(rectangle_overlap([ (bound_box_corner1(1)-2*max_dist) (bound_box_corner1(2)+2*max_dist) (4*max_dist+size(image1,2)) (4*max_dist+size(image1,1)) ], ...
            [ (bound_box_corner2(1)-2*max_dist) (bound_box_corner2(2)+2*max_dist) (4*max_dist+size(image2,2)) (4*max_dist+size(image2,1)) ]) == 0)
        return;
    end
catch
    return
end


% if(rectangle_overlap([ (bound_box_corner1(1)-max_dist) (bound_box_corner1(2)-max_dist) (2*max_dist+size(image1,1)) (2*max_dist+size(image1,2)) ], ...
%         [ bound_box_corner2(1)-max_dist bound_box_corner2(2)-max_dist 2*max_dist+size(image2,1) 2*max_dist+size(image2,2) ]) == 0)
%     return;
% end

[y,x] = find(image1==1);
x1 = x + bound_box_corner1(1);
y1 = y + bound_box_corner1(2);

[y,x] = find(image2==1);
x2 = x + bound_box_corner2(1);
y2 = y + bound_box_corner2(2);

min_dist = 1e10;
for(i=1:length(x1))
    for(j=1:length(x2))
        dist = ( x1(i) - x2(j) )^2 + ( y1(i) - y2(j) )^2;
        if(dist < min_dist)
            min_dist = dist;
            if(min_dist <= 1e-4)
                output_dist = 0;
                return;
            end
        end
    end
end

if(min_dist <= max_dist^2)
    output_dist = sqrt(min_dist);
    if(output_dist <= 1e-4)
        output_dist = 0;
    end
end

return;
end
