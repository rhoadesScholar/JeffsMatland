function min_dist = minimum_distance_between_objects(image1, bound_box_corner1, image2, bound_box_corner2)

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
            if(min_dist < 1e-4)
                min_dist = 0;
                return;
            end
        end
    end
end

if(min_dist<1e10)
    min_dist = sqrt(min_dist);
    if(min_dist <= 1e-4)
        min_dist = 0;
    end
end

return;
end
