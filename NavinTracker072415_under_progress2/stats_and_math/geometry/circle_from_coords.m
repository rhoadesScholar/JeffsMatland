function [radius, xc,yc] = circle_from_coords(x,y)

% Rewrite basic equation for a circle:
% (x-xc)^2 + (y-yc)^2 = radius^2,  where (xc,yc) is the center
% 
% in terms of parameters a, b, c as
% 
% x^2 + y^2 + a*x + b*y + c = 0,  where a = -2*xc, b = -2*yc, and
%                                       c = xc^2 + yc^2 - radius^2
% 
% Solve for parameters a, b, c, and use them to calculate the radius.


% solve for parameters a, b, and c in the least-squares sense by
% using the backslash operator
abc = [x y ones(length(x),1)] \ -(x.^2+y.^2);
a = abc(1); b = abc(2); c = abc(3);

% calculate the location of the center and the radius
xc = -a/2;
yc = -b/2;
radius  = sqrt((xc^2+yc^2)-c);

radius = double(radius);
xc = double(xc);
yc = double(yc);

return;
end
