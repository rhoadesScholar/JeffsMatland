function [PixelSize, radius, xc,yc]  = calc_pixelsize_from_lawn_edge(lawn_edge, lawn_diameter)
% PixelSize = calc_pixelsize_from_lawn_edge(lawn_edge, lawn_diameter) in mm/pixel

[radius, xc,yc] = circle_from_coords(lawn_edge(:,1),lawn_edge(:,2));
diameter = radius*2;

PixelSize = lawn_diameter/diameter;

return;
end
