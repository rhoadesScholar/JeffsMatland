function [area_explored, arena] = explored_area(Track, startFrame, endFrame)
% [area_explored, arena] = explored_area(Track)
% returns the unique area explored by the worm in Track
% in mm^2
% overlays pixels for all the worm images in the Track
% arena = image of the worm-explored area 
% (pixels=1 visited by the worm


if(nargin<2)
    startFrame=1;
    endFrame=length(Track.Frames);
end

arena(Track.Height, Track.Width) = 0;

for(i=startFrame:endFrame)
    [r,c] = find(Track.Image{i}==1);
    r = r + floor(Track.bound_box_corner(i,2));
    c = c + floor(Track.bound_box_corner(i,1));
    for(j=1:length(r))
       arena(r(j),c(j))=1; 
    end
end

area_explored = Track.PixelSize^2*sum(sum(arena));

return;
end