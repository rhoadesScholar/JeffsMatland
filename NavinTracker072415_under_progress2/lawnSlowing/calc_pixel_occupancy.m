function pixel_occupancy = calc_pixel_occupancy(Tracks)

pixel_occupancy = zeros(Tracks(1).Height, Tracks(1).Width);

for(i=1:length(Tracks))
    
    for(j=1:length(Tracks(i).Frames))
        
%         x = round(Tracks(i).Path(:,1));
%         y = round(Tracks(i).Path(:,2));
        
        [y_coord, x_coord] = find(Tracks(i).Image{j}==1);
        x = x_coord + floor(Tracks(i).bound_box_corner(j,1));
        y = y_coord + floor(Tracks(i).bound_box_corner(j,2));
        
%         x = Tracks(i).body_contour.x;
%         y = Tracks(i).body_contour.y;
        
        for(q=1:length(x))
            pixel_occupancy(y(q),x(q)) = pixel_occupancy(y(q),x(q)) + 1;
        end
        
    end
end

return;
end
