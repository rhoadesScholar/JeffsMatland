function overlap_flag = do_these_worm_images_overlap(image1, bound_box_corner1, image2, bound_box_corner2)

overlap_flag = 0;

% if bounding boxes do not overlap, then the images cannot overlap
% vast majority should not overlap

size1 = size(image1);

if(bound_box_corner2(1) > (bound_box_corner1(1) + size1(1)))
    return;
end

if(bound_box_corner2(2) > (bound_box_corner1(2) + size1(2)))
    return;
end

size2 = size(image2);

if((bound_box_corner2(1) + size2(1)) < bound_box_corner1(1))
    return;
end

if((bound_box_corner2(2) + size2(2)) < bound_box_corner1(2))
    return;
end

% size1 = size(image1);
% min_x1 = bound_box_corner1(1);
% max_x1 = (bound_box_corner1(1) + size1(1));
% min_y1 = bound_box_corner1(2);
% max_y1 = (bound_box_corner1(2) + size1(2));
% 
% size2 = size(image2);
% min_x2 = bound_box_corner2(1);
% max_x2 = (bound_box_corner2(1) + size2(1));
% min_y2 = bound_box_corner2(2);
% max_y2 = (bound_box_corner2(2) + size2(2));
% 
% if(min_x2 > max_x1)
%     return;
% end
% if(max_x2 < min_x1)
%     return;
% end
% if(min_y2 > max_y1)
%     return;
% end
% if(max_y2 < min_y1)
%     return;
% end

[y,x] = find(image1==1);
x1 = x + bound_box_corner1(1);
y1 = y + bound_box_corner1(2);

[y,x] = find(image2==1);
x2 = x + bound_box_corner2(1);
y2 = y + bound_box_corner2(2);

for(i=1:length(x1))
    for(j=1:length(x2))
        if( x1(i) == x2(j) )
            if( y1(i) == y2(j) )
                overlap_flag = 1;
%                 figure(10);
%                 plot(x1,y1,'or'); hold on; plot(x2,y2,'.b'); 
%                 axis([(min([x1; x2])-10) (max([x1; x2])+10) (min([y1; y2])-10) (max([y1; y2])+10)]);
%                 hold off;
%                 pause
                return;
            end
        end
    end
end


return;
end
